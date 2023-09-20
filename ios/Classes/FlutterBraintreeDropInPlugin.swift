import Flutter
import UIKit
import Braintree
import PassKit

func makePaymentSummaryItems(from: Dictionary<String, Any>) -> [PKPaymentSummaryItem]? {
    guard let paymentSummaryItems = from["paymentSummaryItems"] as? [Dictionary<String, Any>] else {
        return nil;
    }

    var outList: [PKPaymentSummaryItem] = []
    for paymentSummaryItem in paymentSummaryItems {
        guard let label = paymentSummaryItem["label"] as? String else {
            return nil;
        }
        guard let amount = paymentSummaryItem["amount"] as? Double else {
            return nil;
        }
        guard let type = paymentSummaryItem["type"] as? UInt else {
            return nil;
        }
        guard let pkType = PKPaymentSummaryItemType.init(rawValue: type) else {
            return nil;
        }
        outList.append(PKPaymentSummaryItem(label: label, amount: NSDecimalNumber(value: amount), type: pkType));
    }

    return outList;
}

public class FlutterBraintreeDropInPlugin: BaseFlutterBraintreePlugin, FlutterPlugin {
    

    
    private var completionBlock: FlutterResult!
    private var applePayInfo = [String : Any]()
    private var authorization: String!
    
    // public func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult result: BTThreeDSecureResult, next: @escaping () -> Void) {
    //     next();
    // }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_braintree.drop_in", binaryMessenger: registrar.messenger())
        
        let instance = FlutterBraintreeDropInPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        completionBlock = result
        
        if call.method == "startApplePay" {

            if let applePayInfo = dict(for: "applePayRequest", in: call) {
                self.applePayInfo = applePayInfo
            }

            guard let authorization = getAuthorization(call: call) else {
                returnAuthorizationMissingError(result: result)
                return
            }

            self.authorization = authorization

            let paymentRequest = PKPaymentRequest()
            paymentRequest.supportedNetworks = [.visa, .masterCard, .amex, .discover]
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.countryCode = applePayInfo["countryCode"] as! String
            paymentRequest.currencyCode = applePayInfo["currencyCode"] as! String
            paymentRequest.merchantIdentifier = applePayInfo["merchantIdentifier"] as! String
            paymentRequest.requiredBillingContactFields = [.postalAddress, .name]
            paymentRequest.requiredShippingContactFields = [.emailAddress, .phoneNumber]

            guard let paymentSummaryItems = makePaymentSummaryItems(from: applePayInfo) else {
                return;
            }
            paymentRequest.paymentSummaryItems = paymentSummaryItems;

            guard let applePayController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
                return
            }

            applePayController.delegate = self

            UIApplication.shared.keyWindow?.rootViewController?.present(applePayController, animated: true, completion: nil)
        }
    }
    
    private func setupApplePay(flutterResult: FlutterResult) {
        let paymentRequest = PKPaymentRequest()
        if let supportedNetworksValueArray = applePayInfo["supportedNetworks"] as? [Int] {
            paymentRequest.supportedNetworks = supportedNetworksValueArray.compactMap({ value in
                return PKPaymentNetwork.mapRequestedNetwork(rawValue: value)
            })
        }
        paymentRequest.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = applePayInfo["countryCode"] as! String
        paymentRequest.currencyCode = applePayInfo["currencyCode"] as! String
        paymentRequest.merchantIdentifier = applePayInfo["merchantIdentifier"] as! String
        paymentRequest.requiredBillingContactFields = [.postalAddress, .name]
        paymentRequest.requiredShippingContactFields = [.emailAddress, .phoneNumber]
        
        guard let paymentSummaryItems = makePaymentSummaryItems(from: applePayInfo) else {
            return;
        }
        paymentRequest.paymentSummaryItems = paymentSummaryItems;

        guard let applePayController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            return
        }
        
        applePayController.delegate = self
        
        UIApplication.shared.keyWindow?.rootViewController?.present(applePayController, animated: true, completion: nil)
    }
    
    // private func handleResult(result: BTDropInResult?, error: Error?, flutterResult: FlutterResult, deviceData: String?) {
    //     if error != nil {
    //         returnBraintreeError(result: flutterResult, error: error!)
    //     } else if result?.isCanceled ?? false {
    //         flutterResult(nil)
    //     } else {
    //         if let result = result, result.paymentMethodType == .applePay {
    //             setupApplePay(flutterResult: flutterResult)
    //         } else {
    //             flutterResult(["paymentMethodNonce": buildPaymentNonceDict(nonce: result?.paymentMethod), "deviceData": deviceData])
    //         }
    //     }
    // }
    
    private func handleApplePayResult(payment: PKPayment, result: BTPaymentMethodNonce, flutterResult: FlutterResult) {
        var baseNonce = buildPaymentNonceDict(nonce: result)
        var name = payment.billingContact?.name?.givenName ?? "";
        name += " ";
        name += payment.billingContact?.name?.familyName ?? "";
        baseNonce["billingAddress"] = [
            "givenName": payment.billingContact?.name?.givenName ?? "",
            "surname": payment.billingContact?.name?.familyName ?? "",
            "recipientName": name ?? "",
            "phoneNumber": payment.shippingContact?.phoneNumber?.stringValue,
            "streetAddress": payment.billingContact?.postalAddress?.street,
            "extendedAddress": "",
            "locality": payment.billingContact?.postalAddress?.city,
            "region": payment.billingContact?.postalAddress?.state,
            "postalCode": payment.billingContact?.postalAddress?.postalCode,
            "countryCodeAlpha2": payment.billingContact?.postalAddress?.isoCountryCode,
        ]
        baseNonce["email"] = payment.shippingContact?.emailAddress;
        flutterResult([
            "paymentMethodNonce": baseNonce
        ])
    }
}

// MARK: PKPaymentAuthorizationViewControllerDelegate
extension FlutterBraintreeDropInPlugin: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return }
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        
        applePayClient.tokenize(payment) { (tokenizedPaymentMethod, error) in
            guard let paymentMethod = tokenizedPaymentMethod, error == nil else {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                return
            }
            
            //print(paymentMethod.nonce)
            self.handleApplePayResult(payment: payment, result: paymentMethod, flutterResult: self.completionBlock)
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard let apiClient = BTAPIClient(authorization: authorization) else { return }
        let applePayClient = BTApplePayClient(apiClient: apiClient)
        
        applePayClient.tokenize(payment) { (tokenizedPaymentMethod, error) in
            guard let paymentMethod = tokenizedPaymentMethod, error == nil else {
                completion(.failure)
                return
            }
            
            //print(paymentMethod.nonce)
            self.handleApplePayResult(payment: payment, result: paymentMethod, flutterResult: self.completionBlock)
            completion(.success)
        }
    }
}
