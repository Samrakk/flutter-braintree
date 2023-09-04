class BraintreeDropInRequest {
  BraintreeDropInRequest({
    this.clientToken,
    this.tokenizationKey,
    this.amount,
    this.billingAddress,
    this.email,
    this.collectDeviceData = false,
    this.requestThreeDSecureVerification = false,
    this.googlePaymentRequest,
    this.paypalRequest,
    this.creditCardRequest,
    this.applePayRequest,
    this.venmoEnabled = true,
    this.cardEnabled = true,
    this.paypalEnabled = true,
    this.maskCardNumber = false,
    this.maskSecurityCode = false,
    this.vaultManagerEnabled = false,
  });

  /// Authorization allowing this client to communicate with Braintree.
  /// Either [clientToken] or [tokenizationKey] must be set.
  String? clientToken;

  /// Authorization allowing this client to communicate with Braintree.
  /// Either [clientToken] or [tokenizationKey] must be set.
  String? tokenizationKey;

  ///Additional Information about the user to trigger 3ds 2.0
  BraintreeBillingAddress? billingAddress;

  /// Amount for the transaction. This is only used for 3D secure verfications.
  String? amount;

  /// Email of the user. this is used to icnrease the possibilities of success of 3ds 2.0
  String? email;

  /// Whether the Drop-in should collect and return device data for fraud prevention.
  bool collectDeviceData;

  /// If 3D Secure has been enabled in the control panel and an amount is specified in
  /// [amount], Drop-In will request a 3D Secure verification for any new cards added by the user.
  bool requestThreeDSecureVerification;

  /// Google Payment request. Google Pay will be disabled if this is set to `null`.
  BraintreeGooglePaymentRequest? googlePaymentRequest;

  /// PayPal request. PayPal will be disabled if this is set to `null`.
  BraintreePayPalRequest? paypalRequest;

  /// Credit Card request. Cred,t card will be disabled if this is set to `null`.
  BraintreeCreditCardRequest? creditCardRequest;

  /// Whether Venmo should be enabled.
  bool venmoEnabled;

  /// Whether cards should be enabled.
  bool cardEnabled;

  /// Whether paypal should be enabled.
  bool paypalEnabled;

  /// Whether the card number should be masked if the field is not focused.
  bool maskCardNumber;

  /// Whether the security code should be masked during input.
  bool maskSecurityCode;

  /// Whether customers should be allowed to manage their vaulted payment methods.
  bool vaultManagerEnabled;

  /// ApplePay request. ApplePay will be disabled if this is set to `null`.
  /// The ApplePay option will not be visible in the drop-in UI if the setup in
  /// Xcode, App Store Connect or Braintree control panel was done incorrectly.
  BraintreeApplePayRequest? applePayRequest;

  /// Converts this request object into a JSON-encodable format.
  Map<String, dynamic> toJson() =>
      {
        if (clientToken != null) 'clientToken': clientToken,
        if (tokenizationKey != null) 'tokenizationKey': tokenizationKey,
        if (email != null) 'email': email,
        if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
        if (amount != null) 'amount': amount,
        'collectDeviceData': collectDeviceData,
        'requestThreeDSecureVerification': requestThreeDSecureVerification,
        if (googlePaymentRequest != null)
          'googlePaymentRequest': googlePaymentRequest!.toJson(),
        if (paypalRequest != null) 'paypalRequest': paypalRequest!.toJson(),
        if (applePayRequest != null)
          'applePayRequest': applePayRequest!.toJson(),
        if (creditCardRequest != null)
          'creditCardRequest': creditCardRequest!.toJson(),
        'venmoEnabled': venmoEnabled,
        'cardEnabled': cardEnabled,
        'paypalEnabled': cardEnabled,
        'maskCardNumber': maskCardNumber,
        'maskSecurityCode': maskSecurityCode,
        'vaultManagerEnabled': vaultManagerEnabled,
      };
}

class BraintreeBillingAddress {
  final String? givenName;
  final String? surname;
  final String? recipientName;
  final String? phoneNumber;
  final String? streetAddress;
  final String? extendedAddress;
  final String? locality;
  final String? region;
  final String? sortingCode;
  final String? postalCode;
  final String? countryCodeAlpha2;

  BraintreeBillingAddress({this.givenName,
    this.surname,
    this.recipientName,
    this.phoneNumber,
    this.streetAddress,
    this.extendedAddress,
    this.locality,
    this.region,
    this.postalCode,
    this.sortingCode,
    this.countryCodeAlpha2});

  factory BraintreeBillingAddress.fromJson(dynamic source) {
    return BraintreeBillingAddress(
        givenName: source['givenName'],
        surname: source['surname'],
        recipientName: source['recipientName'],
        phoneNumber: source['phoneNumber'],
        streetAddress: source['streetAddress'],
        extendedAddress: source['extendedAddress'],
        locality: source['locality'],
        region: source['region'],
        postalCode: source['postalCode'],
        sortingCode: source['postalCode'],
        countryCodeAlpha2: source['countryCodeAlpha2']);
  }

  Map<String, dynamic> toJson() =>
      {
        'address1': streetAddress,
        'phoneNumber': phoneNumber,
        'postalCode': postalCode,
        'countryCode': countryCodeAlpha2,
        'city': locality,
        'name': recipientName,
        'state': region,
        'address2': extendedAddress
      };
}

class BraintreeCreditCardRequest {
  BraintreeCreditCardRequest({
    required this.cardNumber,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv,
    this.cardholderName,
  });

  /// Number shown on the credit card.
  String cardNumber;

  /// Two didgit expiration month, e.g. `'05'`.
  String expirationMonth;

  /// Four didgit expiration year, e.g. `'2021'`.
  String expirationYear;

  /// A 3 or 4 digit card verification value assigned to credit cards.
  String cvv;

  /// Cardholder name
  String? cardholderName;

  Map<String, dynamic> toJson() =>
      {
        'cardNumber': cardNumber,
        'expirationMonth': expirationMonth,
        'expirationYear': expirationYear,
        'cvv': cvv,
        'cardholderName': cardholderName
      };
}

class BraintreeGooglePaymentRequest {
  BraintreeGooglePaymentRequest({
    required this.totalPrice,
    required this.currencyCode,
    this.billingAddressRequired = true,
    this.allowPrepaidCards = false,
    this.paypalEnabled = false,
    this.phoneNumberRequired = true,
    this.emailRequired = true,
    required this.environment,
    this.googleMerchantID,
  });

  /// Total price of the payment.
  String totalPrice;

  /// Currency code of the transaction.
  String currencyCode;

  /// Prepaid Card allow of the transaction.
  bool allowPrepaidCards;

  /// Paypal Enabled of the transaction.
  bool paypalEnabled;

  /// Whether billing address information should be collected and passed.
  bool billingAddressRequired;

  /// Phone Number required of the transaction.
  bool phoneNumberRequired;

  /// environment required of the transaction.
  String environment;

  /// email required of the transaction.
  bool emailRequired;

  /// Google Merchant ID. Optional in sandbox, but if set, must be a valid production Google Merchant ID.
  String? googleMerchantID;

  /// Converts this request object into a JSON-encodable format.
  Map<String, dynamic> toJson() =>
      {
        'totalPrice': totalPrice,
        'currencyCode': currencyCode,
        'allowPrepaidCards': allowPrepaidCards,
        'paypalEnabled': paypalEnabled,
        'billingAddressRequired': billingAddressRequired,
        'environment': environment,
        'phoneNumberRequired': phoneNumberRequired,
        'emailRequired': emailRequired,
        if (googleMerchantID != null) 'googleMerchantID': googleMerchantID,
      };
}

class BraintreePayPalRequest {
  BraintreePayPalRequest({
    required this.amount,
    required this.currencyCode,
    required this.displayName,
    required this.billingAgreementDescription,
    this.returnURL,
    this.merchantAccountId,
    required this.localeCode,
    this.shippingAddressRequired = false,
    this.shippingAddressEditable = false,
    this.payPalPaymentIntent = PayPalPaymentIntent.sale,
    this.payPalPaymentUserAction = PayPalPaymentUserAction.default_,
  });

  /// Amount of the transaction. If [amount] is `null`, PayPal will use the billing agreement (Vault) flow.
  /// If [amount] is set, PayPal will follow the one time payment (Checkout) flow.
  String amount;

  /// Currency code. If set to `null`, PayPal will choose it based on the active merchant account in the client token.
  String currencyCode;

  /// The merchant name displayed in the PayPal flow. If set to `null`, PayPal will use the company name in your Braintree account.
  String displayName;

  /// Description for the billing agreement for the Vault flow.
  String? billingAgreementDescription;

  /// Description for return URL.
  String? returnURL;

  /// Description for merchant Account ID.
  String? merchantAccountId;

  /// Description for local code.
  String localeCode;

  /// Description for Shipping Address Required.
  bool shippingAddressRequired;

  /// Description for Shipping Address Editable.
  bool shippingAddressEditable;

  /// The payment intent in the PayPal Checkout flow.
  PayPalPaymentIntent payPalPaymentIntent;

  /// The user action in the PayPal Checkout flow. See [PayPalPaymentUserAction]
  /// for additional documentation.
  PayPalPaymentUserAction payPalPaymentUserAction;

  /// Converts this request object into a JSON-encodable format.
  Map<String, dynamic> toJson() =>
      {
        if (amount != null) 'amount': amount,
        if (currencyCode != null) 'currencyCode': currencyCode,
        'displayName': displayName,
        'billingAgreementDescription': billingAgreementDescription,
        if (returnURL != null) 'returnURL': returnURL,
        if (merchantAccountId != null) 'merchantAccountId': merchantAccountId,
        'localeCode': localeCode,
        'shippingAddressRequired': shippingAddressRequired,
        'shippingAddressEditable': shippingAddressEditable,
        'payPalPaymentIntent': payPalPaymentIntent.name,
        'payPalPaymentUserAction': payPalPaymentUserAction.name,
      };
}

enum PayPalPaymentUserAction {
  /// Shows the default call-to-action text on the PayPal Express Checkout page.
  /// This option indicates that a final confirmation will be shown on the
  /// merchant checkout site before the user's payment method is charged.
  default_,

  /// Shows a deterministic call-to-action. This option indicates to the user
  /// that their payment method will be charged when they click the
  /// call-to-action button on the PayPal Checkout page, and that no final
  /// confirmation page will be shown on the merchant's checkout page. This
  /// option works for both checkout and vault flows.
  commit,
}

enum PayPalPaymentIntent {
  /// Payment intent to create an order.
  order,

  /// Payment intent for immediate payment.
  sale,

  /// Payment intent to authorize a payment for capture later.
  authorize,
}

enum ApplePaySummaryItemType {
  /// The amount is final.
  final_,
  // The amount is not known at the time (e.g. taxi fare).
  pending,
}

extension ApplePaySummaryItemTypeExtension on ApplePaySummaryItemType {
  int get rawValue {
    switch (this) {
      case ApplePaySummaryItemType.final_:
        return 0;
      case ApplePaySummaryItemType.pending:
        return 1;
    }
  }
}

enum ApplePaySupportedNetworks {
  visa, // ios >= 8.0
  masterCard, // ios >= 8.0
  amex, // ios >= 8.0
  discover, // ios >= 9.0
}

extension ApplePaySupportedNetworksExtension on ApplePaySupportedNetworks {
  int get rawValue {
    switch (this) {
      case ApplePaySupportedNetworks.visa:
        return 0;
      case ApplePaySupportedNetworks.masterCard:
        return 1;
      case ApplePaySupportedNetworks.amex:
        return 2;
      case ApplePaySupportedNetworks.discover:
        return 3;
    }
  }
}

class ApplePaySummaryItem {
  ApplePaySummaryItem({
    required this.label,
    required this.amount,
    required this.type,
  });

  /// Payment summary item label (name).
  final String label;

  /// Payment summary item amount (price).
  final double amount;

  /// Payment summary item type.
  final ApplePaySummaryItemType type;

  /// Converts this summary item object into a JSON-encodable format.
  Map<String, dynamic> toJson() =>
      {
        'label': label,
        'amount': amount,
        'type': type.rawValue,
      };
}

class BraintreeApplePayRequest {
  BraintreeApplePayRequest({
    required this.paymentSummaryItems,
    required this.displayName,
    required this.currencyCode,
    required this.countryCode,
    required this.merchantIdentifier,
    this.supportedNetworks = const [
      ApplePaySupportedNetworks.visa,
      ApplePaySupportedNetworks.masterCard,
      ApplePaySupportedNetworks.amex,
      ApplePaySupportedNetworks.discover,
    ],
  });

  /// A summary of the payment.
  final List<ApplePaySummaryItem> paymentSummaryItems;

  /// Short description of the item.
  final String displayName;

  /// The three-letter ISO 4217 currency code.
  final String currencyCode;

  /// The three-letter ISO 4217 currency code.
  final String countryCode;

  /// Apple merchant identifier.
  final String merchantIdentifier;

  /// Supported Networks
  final List<ApplePaySupportedNetworks> supportedNetworks;

  /// Converts this request object into a JSON-encodable format.
  Map<String, dynamic> toJson() =>
      {
        'paymentSummaryItems':
        paymentSummaryItems.map((item) => item.toJson()).toList(),
        'currencyCode': currencyCode,
        'displayName': displayName,
        'countryCode': countryCode,
        'merchantIdentifier': merchantIdentifier,
        'supportedNetworks': supportedNetworks.map((e) => e.rawValue).toList(),
      };
}
