package com.example.flutter_braintree;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;

import com.braintreepayments.api.BraintreeClient;
import com.braintreepayments.api.Card;
import com.braintreepayments.api.GooglePayClient;
import com.braintreepayments.api.CardClient;
import com.braintreepayments.api.CardNonce;
import com.braintreepayments.api.GooglePayListener;
import com.braintreepayments.api.PayPalAccountNonce;
import com.braintreepayments.api.PayPalClient;
import com.braintreepayments.api.PayPalListener;
import com.braintreepayments.api.PayPalNativeCheckoutAccountNonce;
import com.braintreepayments.api.PayPalNativeCheckoutClient;
import com.braintreepayments.api.PayPalNativeCheckoutListener;
import com.braintreepayments.api.PayPalNativeCheckoutPaymentIntent;
import com.braintreepayments.api.PayPalNativeCheckoutRequest;
import com.braintreepayments.api.PayPalNativeCheckoutVaultRequest;
import com.braintreepayments.api.PaymentMethodNonce;
import com.braintreepayments.api.PostalAddress;
import com.braintreepayments.api.UserCanceledException;

import com.braintreepayments.api.GooglePayCardNonce;
import com.braintreepayments.api.GooglePayRequest;
import com.google.android.gms.wallet.TransactionInfo;
import com.google.android.gms.wallet.WalletConstants;


import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

public class FlutterBraintreeCustom
        extends AppCompatActivity
        implements GooglePayListener, PayPalNativeCheckoutListener, PayPalListener {
    private BraintreeClient braintreeClient;
    private PayPalClient payPalClient;

    private PayPalNativeCheckoutClient payPalNativeClient;
    private GooglePayClient googlePayClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_flutter_braintree_custom);
    }

    @Override
    protected void onNewIntent(Intent newIntent) {
        super.onNewIntent(newIntent);
        setIntent(newIntent);
    }

    @Override
    protected void onStart() {
        super.onStart();
        try {
            Intent intent = getIntent();
            braintreeClient = new BraintreeClient(this, intent.getStringExtra("authorization"));
            String type = intent.getStringExtra("type");
            if (type.equals("tokenizeCreditCard")) {
                tokenizeCreditCard();
            } else if (type.equals("requestPaypalNonce")) {
                payPalClient = new PayPalClient(this, braintreeClient);
                payPalClient.setListener(this);
                payPalNativeClient = new PayPalNativeCheckoutClient(braintreeClient);
                payPalNativeClient.setListener(this);
                requestPaypalNonce();
            } else if (type.equals("requestGooglePayment")) {
                googlePayClient = new GooglePayClient(this, braintreeClient);
                googlePayClient.setListener(this);
                requestGooglePayment();
            } else {
                throw new Exception("Invalid request type: " + type);
            }
        } catch (Exception e) {
            Intent result = new Intent();
            result.putExtra("error", e);
            setResult(2, result);
            finish();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    protected void tokenizeCreditCard() {
        Intent intent = getIntent();
        Card card = new Card();
        card.setExpirationMonth(intent.getStringExtra("expirationMonth"));
        card.setExpirationYear(intent.getStringExtra("expirationYear"));
        card.setCvv(intent.getStringExtra("cvv"));
        card.setCardholderName(intent.getStringExtra("cardholderName"));
        card.setNumber(intent.getStringExtra("cardNumber"));

        CardClient cardClient = new CardClient(braintreeClient);
        cardClient.tokenize(card, (cardNonce, error) -> {
            if (cardNonce != null) {
                onPaymentMethodNonceCreated(cardNonce);
            }
            if (error != null) {
                onError(error);
            }
        });
    }

    protected void requestPaypalNonce() {
        Intent intent = getIntent();
        if (intent.getStringExtra("amount") == null) {
            // Vault flow
            PayPalNativeCheckoutVaultRequest request = new PayPalNativeCheckoutVaultRequest();
            request.setDisplayName(intent.getStringExtra("displayName"));
            request.setBillingAgreementDescription(intent.getStringExtra("billingAgreementDescription"));
            request.setLocaleCode(intent.getStringExtra("localeCode"));
            request.setShippingAddressRequired(intent.getBooleanExtra("shippingAddressRequired", false));
            request.setShippingAddressEditable(intent.getBooleanExtra("shippingAddressEditable", false));
            request.setReturnUrl(intent.getStringExtra("returnURL"));
            request.setMerchantAccountId(intent.getStringExtra("merchantAccountId"));
            payPalNativeClient.launchNativeCheckout(this, request);

        } else {
            PayPalNativeCheckoutRequest request = new PayPalNativeCheckoutRequest(intent.getStringExtra("amount"));
            request.setCurrencyCode(intent.getStringExtra("currencyCode"));
            request.setDisplayName(intent.getStringExtra("displayName") + "_paypal_test");
            request.setBillingAgreementDescription(intent.getStringExtra("billingAgreementDescription"));
            request.setLocaleCode(intent.getStringExtra("localeCode"));
            request.setShippingAddressRequired(intent.getBooleanExtra("shippingAddressRequired", false));
            request.setShippingAddressEditable(intent.getBooleanExtra("shippingAddressEditable", false));
            request.setMerchantAccountId(intent.getStringExtra("merchantAccountId"));
            request.setReturnUrl(intent.getStringExtra("returnURL"));
            switch (intent.getStringExtra("payPalPaymentIntent")){
                case PayPalNativeCheckoutPaymentIntent.SALE:
                    request.setIntent(PayPalNativeCheckoutPaymentIntent.SALE);
                    break;
                case PayPalNativeCheckoutPaymentIntent.AUTHORIZE:
                    request.setIntent(PayPalNativeCheckoutPaymentIntent.AUTHORIZE);
                    break;
                case PayPalNativeCheckoutPaymentIntent.ORDER:
                    request.setIntent(PayPalNativeCheckoutPaymentIntent.ORDER);
                    break;
            }

            switch (intent.getStringExtra("payPalPaymentUserAction")){
                case "commit":
                    request.setUserAction(PayPalNativeCheckoutRequest.USER_ACTION_COMMIT);
                    break;
                case "default_":
                    request.setUserAction(PayPalNativeCheckoutRequest.USER_ACTION_DEFAULT);
                    break;
            }
            System.out.println("payPalPaymentUserAction (come) :" + intent.getStringExtra("payPalPaymentUserAction"));
            System.out.println("payPalPaymentUserAction ():" + request.getUserAction());
            System.out.println("payPalPaymentIntent :" + request.getIntent());
            System.out.println("amount :" + request.getAmount());
            System.out.println("localcode :" + request.getLocaleCode());
            payPalNativeClient.launchNativeCheckout(this, request);

        }
    }

    public void requestGooglePayment() throws Exception {
        try {
            Intent intent = getIntent();
            GooglePayRequest googlePaymentRequest = new GooglePayRequest();
            googlePaymentRequest.setTransactionInfo(TransactionInfo.newBuilder()
                    .setTotalPrice(intent.getStringExtra("totalPrice"))
                    .setCurrencyCode(intent.getStringExtra("currencyCode"))
                    .setTotalPriceStatus(WalletConstants.TOTAL_PRICE_STATUS_FINAL)
                    .build());
            googlePaymentRequest.setAllowPrepaidCards(intent.getBooleanExtra("allowPrepaidCards", false));
            googlePaymentRequest.setPayPalEnabled(intent.getBooleanExtra("paypalEnabled", false));
            googlePaymentRequest.setBillingAddressRequired(intent.getBooleanExtra("billingAddressRequired", false));
            googlePaymentRequest.setBillingAddressFormat(WalletConstants.BILLING_ADDRESS_FORMAT_FULL);
            googlePaymentRequest.setPhoneNumberRequired(intent.getBooleanExtra("phoneNumberRequired", false));
            googlePaymentRequest.setEnvironment(intent.getStringExtra("environment"));
            googlePaymentRequest.setEmailRequired(intent.getBooleanExtra("emailRequired", false));
            googlePaymentRequest.setGoogleMerchantName(intent.getStringExtra("merchantID"));
            googlePayClient.requestPayment(this, googlePaymentRequest);
        } catch (Exception e) {
            throw e;
        }
    }

    public void onPaymentMethodNonceCreated(PaymentMethodNonce paymentMethodNonce) {
        HashMap<String, Object> nonceMap = new HashMap<String, Object>();
        nonceMap.put("nonce", paymentMethodNonce.getString());
        nonceMap.put("isDefault", paymentMethodNonce.isDefault());
        if (paymentMethodNonce instanceof PayPalNativeCheckoutAccountNonce) {
            PayPalNativeCheckoutAccountNonce paypalAccountNonce = (PayPalNativeCheckoutAccountNonce) paymentMethodNonce;
            nonceMap.put("paypalPayerId", paypalAccountNonce.getPayerId());
            nonceMap.put("typeLabel", "PayPal");
            nonceMap.put("description", paypalAccountNonce.getEmail());
            nonceMap.put("email", paypalAccountNonce.getEmail());
            nonceMap.put("billingAddress", getBillingAddress(paypalAccountNonce.getBillingAddress()));
        } else if (paymentMethodNonce instanceof CardNonce) {
            CardNonce cardNonce = (CardNonce) paymentMethodNonce;
            nonceMap.put("typeLabel", cardNonce.getCardType());
            nonceMap.put("description", "ending in ••" + cardNonce.getLastTwo());
        } else if (paymentMethodNonce instanceof GooglePayCardNonce) {
            GooglePayCardNonce googlePaymentCardNonce = (GooglePayCardNonce) paymentMethodNonce;
            nonceMap.put("typeLabel", googlePaymentCardNonce.getCardType());
            nonceMap.put("description", googlePaymentCardNonce.getCardType() + "****" + googlePaymentCardNonce.getLastFour());
            nonceMap.put("email", googlePaymentCardNonce.getEmail());
            nonceMap.put("billingAddress", getBillingAddress(googlePaymentCardNonce.getBillingAddress()));
        }
        Intent result = new Intent();
        result.putExtra("type", "paymentMethodNonce");
        result.putExtra("paymentMethodNonce", nonceMap);
        setResult(RESULT_OK, result);
        finish();
    }

    HashMap<String, Object> getBillingAddress(PostalAddress postalAddress) {
        HashMap<String, Object> data = new HashMap<>();
        data.put("recipientName", postalAddress.getRecipientName());
        data.put("phoneNumber", postalAddress.getPhoneNumber());
        data.put("streetAddress", postalAddress.getStreetAddress());
        data.put("extendedAddress", postalAddress.getExtendedAddress());
        data.put("locality", postalAddress.getLocality());
        data.put("region", postalAddress.getRegion());
        data.put("postalCode", postalAddress.getPostalCode());
        data.put("sortingCode", postalAddress.getPostalCode());
        data.put("countryCodeAlpha2", postalAddress.getCountryCodeAlpha2());
        data.put("info", getInfo(postalAddress));
        return data;
    }

    String getInfo(PostalAddress postalAddress) {
        String info = "";
        info += "\n" + postalAddress.getRecipientName();
        info += "\n" + postalAddress.getPhoneNumber();
        info += "\n" + postalAddress.getStreetAddress();
        info += "\n" + postalAddress.getExtendedAddress();
        info += "\n" + postalAddress.getLocality();
        info += "\n" + postalAddress.getRegion();
        info += "\n" + postalAddress.getPostalCode();
        info += "\n" + postalAddress.getCountryCodeAlpha2();

        return info;
    }

    public void onCancel() {
        System.out.println("FlutterBraintreeCustom.onCancel");
        setResult(RESULT_CANCELED);
        finish();
    }

    public void onError(Exception error) {
        System.out.println("FlutterBraintreeCustom.onError");
        Intent result = new Intent();
        result.putExtra("error", error);
        setResult(2, result);
        finish();
    }

    @Override
    public void onGooglePaySuccess(@NonNull PaymentMethodNonce paymentMethodNonce) {
        onPaymentMethodNonceCreated(paymentMethodNonce);
    }

    @Override
    public void onGooglePayFailure(@NonNull Exception error) {
        if (error instanceof UserCanceledException) {
            if (((UserCanceledException) error).isExplicitCancelation()) {
                onCancel();
            }
        } else {
            onError(error);
        }
    }


    @Override
    public void onPayPalSuccess(@NonNull PayPalNativeCheckoutAccountNonce paymentMethodNonce) {
        System.out.println("native_param_payPalAccountNonce :" + paymentMethodNonce.getFirstName());
        onPaymentMethodNonceCreated(paymentMethodNonce);
    }

    @Override
    public void onPayPalSuccess(@NonNull PayPalAccountNonce payPalAccountNonce) {
        System.out.println("param_payPalAccountNonce :" + payPalAccountNonce.getFirstName());
        onPaymentMethodNonceCreated(payPalAccountNonce);
    }

    @Override
    public void onPayPalFailure(@NonNull Exception error) {
        System.out.println("param_PayPalFailure :" + error.getMessage());
        if (error instanceof UserCanceledException) {
            if (((UserCanceledException) error).isExplicitCancelation()) {
                onCancel();
            }
        } else {
            onError(error);
        }
    }
}