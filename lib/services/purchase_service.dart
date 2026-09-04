import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IDs des produits Google Play.
/// Ces IDs doivent correspondre exactement à ce qui sera créé sur la Play Console.
class KomikoProducts {
  static const String proMonthly = 'komiko_pro_monthly';
  static const String proAnnual = 'komiko_pro_annual';
  static const String boostPost = 'komiko_boost_post';

  static const Set<String> all = {proMonthly, proAnnual, boostPost};
  static const Set<String> subscriptions = {proMonthly, proAnnual};
}

/// États possibles du service d'achat.
enum PurchaseStatus {
  idle,
  loading,
  purchasedPro,
  purchasedBoost,
  restored,
  error,
  pending,
}

/// Service wrapping Google Play Billing via [in_app_purchase].
///
/// NOTE : Les produits Google Play ne sont pas encore créés en production.
/// Le paywall est VISIBLE mais BLOQUANT. Le billing sera activé une fois
/// les produits configurés sur la Play Console avant la promo utilisateurs.
class PurchaseService extends ChangeNotifier {
  static const _prefKeyIsPro = 'komiko_is_pro';
  static const _prefKeyProExpiry = 'komiko_pro_expiry';

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;
  bool _isPro = false;
  DateTime? _proExpiry;
  List<ProductDetails> _products = [];
  PurchaseStatus _status = PurchaseStatus.idle;
  String? _errorMessage;

  bool get isAvailable => _isAvailable;
  bool get isPro => _isPro && (_proExpiry == null || _proExpiry!.isAfter(DateTime.now()));
  DateTime? get proExpiry => _proExpiry;
  List<ProductDetails> get products => _products;
  PurchaseStatus get status => _status;
  String? get errorMessage => _errorMessage;

  ProductDetails? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // Charger l'état Pro depuis les préférences locales
    await _loadLocalProStatus();

    // Vérifier la disponibilité du Store
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('[PurchaseService] Store non disponible.');
      return;
    }

    // Écouter les mises à jour de purchase
    _iap.purchaseStream.listen(_handlePurchaseUpdate, onError: (e) {
      debugPrint('[PurchaseService] purchaseStream error: $e');
    });

    // Charger les produits
    await _loadProducts();
  }

  Future<void> _loadLocalProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_prefKeyIsPro) ?? false;
    final expiryMs = prefs.getInt(_prefKeyProExpiry);
    if (expiryMs != null) {
      _proExpiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    }
  }

  Future<void> _saveLocalProStatus(bool isPro, DateTime? expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPro, isPro);
    if (expiry != null) {
      await prefs.setInt(_prefKeyProExpiry, expiry.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_prefKeyProExpiry);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final response = await _iap.queryProductDetails(KomikoProducts.all);
      if (response.error != null) {
        debugPrint('[PurchaseService] Erreur produits: ${response.error?.message}');
      }
      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      debugPrint('[PurchaseService] Exception loadProducts: $e');
    }
  }

  // ── Achats ─────────────────────────────────────────────────────────────────

  Future<void> buySubscription(ProductDetails product) async {
    if (!_isAvailable) return;
    _status = PurchaseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    late PurchaseParam purchaseParam;
    if (Platform.isAndroid && product is GooglePlayProductDetails) {
      purchaseParam = GooglePlayPurchaseParam(productDetails: product);
    } else {
      purchaseParam = PurchaseParam(productDetails: product);
    }

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _status = PurchaseStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> buyBoost(ProductDetails product) async {
    if (!_isAvailable) return;
    _status = PurchaseStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _status = PurchaseStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    _status = PurchaseStatus.loading;
    notifyListeners();
    await _iap.restorePurchases();
  }

  // ── Gestion des mises à jour ───────────────────────────────────────────────

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _processPurchase(purchase);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending as dynamic) {
      _status = PurchaseStatus.pending;
      notifyListeners();
      return;
    }

    // Vérification des erreurs
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    final isSubscription = KomikoProducts.subscriptions.contains(purchase.productID);

    if (_isPurchaseValid(purchase)) {
      if (isSubscription) {
        // Abonnement Pro activé
        DateTime? expiry;
        if (purchase.productID == KomikoProducts.proMonthly) {
          expiry = DateTime.now().add(const Duration(days: 31));
        } else if (purchase.productID == KomikoProducts.proAnnual) {
          expiry = DateTime.now().add(const Duration(days: 366));
        }
        _isPro = true;
        _proExpiry = expiry;
        await _saveLocalProStatus(true, expiry);

        // Mise à jour de Firestore pour attribuer tous les avantages Pro au compte utilisateur
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'isPro': true,
              'proExpiry': expiry != null ? Timestamp.fromDate(expiry) : null,
            }, SetOptions(merge: true));
            debugPrint('[PurchaseService] Profil Firestore $uid mis à jour avec le statut Pro !');
          } catch (e) {
            debugPrint('[PurchaseService] Erreur mise à jour Firestore: $e');
          }
        }

        _status = PurchaseStatus.purchasedPro;
      } else if (purchase.productID == KomikoProducts.boostPost) {
        _status = PurchaseStatus.purchasedBoost;
      }
    } else {
      _status = PurchaseStatus.error;
      _errorMessage = purchase.error?.message ?? 'Achat échoué';
    }
    notifyListeners();
  }

  bool _isPurchaseValid(PurchaseDetails purchase) {
    return purchase.status.name == 'purchased' || purchase.status.name == 'restored';
  }

  /// Accorder le Pro manuellement (admin Komiko uniquement via Firestore).
  Future<void> grantProManually({DateTime? expiry}) async {
    _isPro = true;
    _proExpiry = expiry;
    await _saveLocalProStatus(true, expiry);
    notifyListeners();
  }

  /// Révoquer le Pro (admin uniquement).
  Future<void> revokeProManually() async {
    _isPro = false;
    _proExpiry = null;
    await _saveLocalProStatus(false, null);
    notifyListeners();
  }

  /// Réinitialise le statut après traitement d'un achat.
  void resetStatus() {
    _status = PurchaseStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

