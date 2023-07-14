import 'dart:convert';

import '../flutter_braintree.dart';

class BraintreeDropInResult {
  const BraintreeDropInResult({
    required this.paymentMethodNonce,
    required this.deviceData,
  });

  factory BraintreeDropInResult.fromJson(dynamic source) {
    return BraintreeDropInResult(
      paymentMethodNonce:
          BraintreePaymentMethodNonce.fromJson(source['paymentMethodNonce']),
      deviceData: source['deviceData'],
    );
  }

  /// The payment method nonce containing all relevant information for the payment.
  final BraintreePaymentMethodNonce paymentMethodNonce;

  /// String of device data. `null`, if `collectDeviceData` was set to false.
  final String? deviceData;
}

class BraintreePaymentMethodNonce {
  const BraintreePaymentMethodNonce({
    required this.nonce,
    required this.typeLabel,
    required this.description,
    required this.isDefault,
    required this.billingAddress,
    required this.email,
    this.paypalPayerId,
    this.info,
  });

  factory BraintreePaymentMethodNonce.fromJson(dynamic source) {
    String? info;
    try {
      Map<String, dynamic> sourceMap = Map<String, dynamic>.from(jsonDecode(jsonEncode(source)));
      sourceMap.remove('nonce');
      info = jsonEncode(sourceMap);
    } catch (e) {
      print('Error encoding source to JSON: $e');
      // You can assign a default value to 'info' here if you want.
      // Otherwise, it will remain 'null'.
    }
    return BraintreePaymentMethodNonce(
      nonce: source['nonce'],
      typeLabel: source['typeLabel'],
      description: source['description'],
      isDefault: source['isDefault'],
      billingAddress: BraintreeBillingAddress.fromJson(source['billingAddress']),
      email: source['email'],
      paypalPayerId: source['paypalPayerId'],
      info: info,
    );
  }

  /// The nonce generated for this payment method by the Braintree gateway. The nonce will represent
  /// this PaymentMethod for the purposes of creating transactions and other monetary actions.
  final String nonce;

  /// The type of this PaymentMethod for displaying to a customer, e.g. 'Visa'. Can be used for displaying appropriate logos, etc.
  final String typeLabel;

  /// The description of this PaymentMethod for displaying to a customer, e.g. 'Visa ending in...'.
  final String description;

  /// True if this payment method is the default for the current customer, false otherwise.
  final bool isDefault;

  /// Get Address info
  final BraintreeBillingAddress billingAddress;

  /// email address info
  final String email;

  /// PayPal payer id if requesting for paypal nonce
  final String? paypalPayerId;

  final String? info;
}
