import Flutter
import UIKit
import Braintree


public class FlutterBraintreeCustomPlugin: BaseFlutterBraintreePlugin, FlutterPlugin {
    var driver: BTPayPalNativeCheckoutClient?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_braintree.custom", binaryMessenger: registrar.messenger())
        
        let instance = FlutterBraintreeCustomPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard !isHandlingResult else {
            returnAlreadyOpenError(result: result)
            return
        }
        
        isHandlingResult = true
        
        guard let authorization = getAuthorization(call: call) else {
            returnAuthorizationMissingError(result: result)
            isHandlingResult = false
            return
        }
        
        let client = BTAPIClient(authorization: authorization)
        
        if call.method == "requestPaypalNonce" {
//            guard let flutterVC = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController else {
//                    result(FlutterError(code: "UNAVAILABLE", message: "FlutterViewController not available.", details: nil))
//                    return
//                }
            debugPrint("#paypal start")
            driver = BTPayPalNativeCheckoutClient(apiClient: client!)
            
            guard let requestInfo = dict(for: "request", in: call) else {
                isHandlingResult = false
                return
            }
            
            if let amount = requestInfo["amount"] as? String {
                debugPrint("#paypal BTPayPalNativeCheckoutRequest")
                let paypalRequest = BTPayPalNativeCheckoutRequest(amount: "20.35")
                paypalRequest.currencyCode = "USD"
                paypalRequest.intent = BTPayPalRequestIntent.sale
                // paypalRequest.currencyCode = requestInfo["currencyCode"] as? String
                 paypalRequest.displayName = requestInfo["displayName"] as? String
                // paypalRequest.billingAgreementDescription = requestInfo["billingAgreementDescription"] as? String
                // paypalRequest.isShippingAddressRequired = requestInfo["shippingAddressRequired"] as! Bool
                // paypalRequest.isShippingAddressEditable = requestInfo["shippingAddressEditable"] as! Bool
                 paypalRequest.localeCode = BTPayPalLocaleCode.en_US
                // paypalRequest.merchantAccountID = requestInfo["merchantAccountId"] as? String
                // if let intent = requestInfo["payPalPaymentIntent"] as? String {
                //     switch intent {
                //     case "order":
                //         paypalRequest.intent = BTPayPalRequestIntent.order
                //     case "sale":
                //         paypalRequest.intent = BTPayPalRequestIntent.sale
                //     case "authorize":
                //         paypalRequest.intent = BTPayPalRequestIntent.authorize
                //     default:
                //         paypalRequest.intent = BTPayPalRequestIntent.authorize
                //     }
                // }
                debugPrint("#paypal if driver.tokenizePayPalAccount")
                driver?.tokenize(paypalRequest) { payPalNativeCheckoutNonce, error in
                    debugPrint("driver.tokenize(paypalRequest)")
                    self.handlePayPalResult(nonce: payPalNativeCheckoutNonce, error: error, flutterResult: result)
                    self.isHandlingResult = false
                    self.driver = nil
                }
//                driver.tokenize(paypalRequest) { (nonce, error) in
//                    debugPrint("driver.tokenize(paypalRequest)")
//                     self.handlePayPalResult(nonce: nonce, error: error, flutterResult: result)
//                     self.isHandlingResult = false
//                }
            }
            
        }
        else {
            result(FlutterMethodNotImplemented)
            self.isHandlingResult = false
        }
    }
    
    private func handleResult(nonce: BTPaymentMethodNonce?, error: Error?, flutterResult: FlutterResult) {
        if error != nil {
            returnBraintreeError(result: flutterResult, error: error!)
        } else if nonce == nil {
            flutterResult(nil)
        } else {
            flutterResult(buildPaymentNonceDict(nonce: nonce));
        }
    }

    private func handlePayPalResult(nonce: BTPayPalNativeCheckoutAccountNonce?, error: Error?, flutterResult: FlutterResult) {
        print("Error: \(error?.localizedDescription)")
        print("#paypal: handlePayPalResult")
        print(nonce?.email)
        if error != nil {
            returnBraintreeError(result: flutterResult, error: error!)
        } else if nonce == nil {
            flutterResult(nil)
        } else {
            flutterResult(buildPayPalPaymentNonceDict(nonce: nonce));
        }
    }
    
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
}
