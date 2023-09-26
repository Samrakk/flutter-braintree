import Foundation
import PassKit
import Flutter
import Braintree

open class BaseFlutterBraintreePlugin: NSObject {
    internal var isHandlingResult = false;

    /**
     Will get the authorization for the current method call. This will basically check for a  *clientToken*, *tokenizationKey* or *authorization* property on the call.
     This does not take care about sending the error to the Flutter result.
     */
    internal func getAuthorization(call: FlutterMethodCall) -> String? {
        let clientToken = string(for: "clientToken", in: call)
        let tokenizationKey = string(for: "tokenizationKey", in: call)
        let authorizationKey = string(for: "authorization", in: call)

        guard let authorization = clientToken
            ?? tokenizationKey
            ?? authorizationKey else {
            return nil
        }

        return authorization
    }
    
    internal func buildPaymentNonceDict(nonce: BTPaymentMethodNonce?) -> [String: Any?] {
        var dict = [String: Any?]()
        dict["nonce"] = nonce?.nonce
        dict["typeLabel"] = nonce?.type
        dict["isDefault"] = nonce?.isDefault
        dict["description"] = nonce?.nonce
        if let paypalNonce = nonce as? BTPayPalAccountNonce {
            dict["paypalPayerId"] = paypalNonce.payerID
            dict["description"] = paypalNonce.email
            dict["email"] = paypalNonce.email
            dict["billingAddress"] = paypalNonce.billingAddress
        }
        return dict
    }

    internal func buildPaymentNonceDict(nonce: BTPaymentMethodNonce?, payment: PKPayment) -> [String: Any?] {
        var dict = [String: Any?]()
        dict["nonce"] = nonce?.nonce
        dict["typeLabel"] = nonce?.type
        dict["isDefault"] = nonce?.isDefault
        dict["description"] = nonce?.nonce
        dict["email"] = payment.shippingContact?.emailAddress
        dict["billingAddress"] = getAddressMap(
            firstName: payment.billingContact?.name?.givenName ?? "",
            lastName: payment.billingContact?.name?.familyName ?? "",
            phoneNumber: payment.shippingContact?.phoneNumber?.stringValue,
            streetAddress: payment.billingContact?.postalAddress?.street,
            locality: payment.billingContact?.postalAddress?.city,
            region: payment.billingContact?.postalAddress?.state,
            postalCode: payment.billingContact?.postalAddress?.postalCode,
            countryCodeAlpha2: payment.billingContact?.postalAddress?.isoCountryCode
        )
        return dict
    }

    internal func buildPayPalPaymentNonceDict(nonce: BTPayPalNativeCheckoutAccountNonce?) -> [String: Any?] {
        var dict = [String: Any?]()
        dict["nonce"] = nonce?.nonce
        dict["typeLabel"] = nonce?.type
        dict["isDefault"] = nonce?.isDefault
        dict["description"] = nonce?.email
        dict["email"] = nonce?.email
        dict["paypalPayerId"] = nonce?.payerID
        dict["billingAddress"] = getAddressMap(
            firstName: nonce?.firstName,
            lastName: nonce?.lastName,
            phoneNumber: nonce?.phone,
            streetAddress: nonce?.billingAddress?.streetAddress,
            locality: nonce?.billingAddress?.locality,
            region: nonce?.billingAddress?.region,
            postalCode: nonce?.billingAddress?.postalCode,
            countryCodeAlpha2: nonce?.billingAddress?.countryCodeAlpha2
        )

        return dict
    }
    
    internal func getAddressMap(firstName:String?,
                          lastName:String?,
                          phoneNumber:String?,
                          streetAddress:String?,
                          locality:String?,
                          region:String?,
                          postalCode:String?,
                          countryCodeAlpha2:String?
    )-> [String: Any?] {
        var name = (firstName ?? " ") + " " + (lastName ?? " ");
        return [
            "givenName": firstName,
            "surname": lastName,
            "recipientName": name,
            "phoneNumber": phoneNumber,
            "streetAddress": streetAddress,
            "extendedAddress": "",
            "locality": locality,
            "region": region,
            "postalCode": postalCode,
            "countryCodeAlpha2": countryCodeAlpha2,
        ];
    }
    
    
    internal func returnAuthorizationMissingError (result: FlutterResult) {
        result(FlutterError(code: "braintree_error", message: "Authorization not specified (no clientToken or tokenizationKey)", details: nil))
    }
    
    internal func returnBraintreeError(result: FlutterResult, error: Error) {
        result(FlutterError(code: "braintree_error", message: error.localizedDescription, details: nil))
    }
    
    internal func returnAlreadyOpenError(result: FlutterResult) {
        result(FlutterError(code: "drop_in_already_running", message: "Cannot launch another Drop-in activity while one is already running.", details: nil));
    }

    internal func string(for key: String, in call: FlutterMethodCall) -> String? {
        return (call.arguments as? [String: Any])?[key] as? String
    }


    internal func bool(for key: String, in call: FlutterMethodCall) -> Bool? {
        return (call.arguments as? [String: Any])?[key] as? Bool
    }


    internal func dict(for key: String, in call: FlutterMethodCall) -> [String: Any]? {
        return (call.arguments as? [String: Any])?[key] as? [String: Any]
    }
}
