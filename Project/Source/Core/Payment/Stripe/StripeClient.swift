//
//  StripeManager.swift
//  Rekall
//
//  Created by Ray Hunter on 09/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Stripe
import Alamofire

protocol ADPaymentDelegate: class {
    /// paymentToken is a payment method token that has passed authorization
    func applePayProvided(email: String?, firstName: String?, lastName: String?)
    func paymentMethodCreated(sender: StripeClient, paymentToken: String)
    func paymentMethodCreationError(sender: StripeClient, error: Error?)
    func paymentMethodCreationCancelled(sender: StripeClient)
}

enum ADPaymentError: Error {
    case missingId
    case incompleteImplementation
}

extension ADPaymentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingId:
            return NSLocalizedString("Missing data field", comment: "Error String")
        case .incompleteImplementation:
            return NSLocalizedString("Waiting for code to be completed", comment: "Error String")
        }
    }
}

///
///  This class authorizes a payment with either Apple Pay or CC.
///
class StripeClient: NSObject {

    weak var delegate: ADPaymentDelegate?
    
    private let hostViewController: UIViewController
    let payment: ADPurchase
    private weak var applePayVC: PKPaymentAuthorizationViewController?

    init(hostViewController: UIViewController, payment: ADPurchase) {
        self.hostViewController = hostViewController
        self.payment = payment
        super.init()
    }


    static func configureStripe(publishableKey: String, appleMerchantId: String, projectName: String) {
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = publishableKey
        config.appleMerchantIdentifier = appleMerchantId
        config.companyName = projectName
    }


    var addCardNavigationController: UINavigationController?

    func createPaymentMethodWithCreditCardDetails(cardNumber: String, expiryMonth: Int,
                                                  expiryYear: Int, cvc: String) {
        let cardParams = STPPaymentMethodCardParams()
        cardParams.number = cardNumber
        cardParams.expMonth = NSNumber(value: expiryMonth)
        cardParams.expYear = NSNumber(value: expiryYear)
        cardParams.cvc = cvc

        //let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)

        createPaymentMethodFromCardParams(paymentMethodCardParams: cardParams) { token, error in
            if let error = error {
                self.delegate?.paymentMethodCreationError(sender: self, error: error)
                return
            }

            if let token = token {
                self.delegate?.paymentMethodCreated(sender: self, paymentToken: token)
                return
            }

            print("ERROR: No payment token and no error")
        }
    }


    func authorizeWithApplePay(requestEmailAndName: Bool) {
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: Environment.shared.appleMerchantId,
                                                   country: "US",
                                                   currency: "USD")

        paymentRequest.paymentSummaryItems = payment.getSummaryItems()
        
        if requestEmailAndName {
            paymentRequest.requiredShippingContactFields = [.emailAddress, .name]
        }

        guard let auth = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else {
            print("Unable to init PKPaymentAuthorizationViewController")
            return
        }

        applePayVC = auth
        auth.delegate = self
        hostViewController.present(auth, animated: true, completion: nil)
    }


    private func createPaymentMethodFromStpToken(token: STPToken,
                                                 completion: @escaping (String?, Error?) -> ()){
        let paymentMethodCardParams = STPPaymentMethodCardParams()
        paymentMethodCardParams.token = token.tokenId

        createPaymentMethodFromCardParams(paymentMethodCardParams: paymentMethodCardParams,
                                          completion: completion)
    }


    private func createPaymentMethodFromCardParams(paymentMethodCardParams: STPPaymentMethodCardParams,
                                                   completion: @escaping (String?, Error?) -> ()) {

        let paymentMethodParams = STPPaymentMethodParams(card: paymentMethodCardParams,
                                                         billingDetails: nil,
                                                         metadata: nil)

        STPAPIClient.shared().createPaymentMethod(with: paymentMethodParams) { (paymentMethod, error) in
            guard error == nil else {
                print("STRIPE: ERROR: STPAPIClient.shared().createPaymentMethod error: \(String(describing: error))")
                completion(nil, error)
                return
            }

            guard let token = paymentMethod?.stripeId else {
                print("STRIPE: ERROR: No payment method card params token")
                completion(nil, ADPaymentError.missingId)
                return
            }

            completion(token, nil)
        }
    }
}

extension StripeClient: STPAuthenticationContext {

    func confirmPaymentIntent(paymentIntentClientSecret: String, completion: @escaping (STPPaymentIntent?, String?) -> ()) {

        STPPaymentHandler.shared().handleNextAction(forPayment: paymentIntentClientSecret,
                                                    authenticationContext: self,
                                                    returnURL: nil) { (status, paymentIntent, error) in
            switch status {
            case .succeeded:
                completion(paymentIntent, nil)
            case .failed:
                completion(nil, error?.localizedDescription)
            case .canceled:
                completion(nil, nil)
            @unknown default:
                print("@unknown default in StripeClient.confirmPaymentIntent()")
                completion(nil, nil)
            }
        }
    }

    func authenticationPresentingViewController() -> UIViewController {
        return hostViewController
    }

    func prepare(forPresentation completion: @escaping STPVoidBlock) {
        guard let applePay = applePayVC else {
            completion()
            return
        }

        applePayVC = nil
        applePay.dismiss(animated: true) {
            completion()
        }
    }
}


extension StripeClient: PKPaymentAuthorizationViewControllerDelegate {

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        print("Did finish")
        applePayVC = nil
        controller.dismiss(animated: true, completion: nil)
        delegate?.paymentMethodCreationCancelled(sender: self)
    }


    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        print("Will auth")
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {


        print("Did auth")

        if let emailAddress = payment.shippingContact?.emailAddress,
           let nameContact = payment.shippingContact?.name {
            let firstName = nameContact.givenName
            let lastName = nameContact.familyName

            delegate?.applePayProvided(email: emailAddress, firstName: firstName, lastName: lastName)
        } else {
            delegate?.applePayProvided(email: nil, firstName: nil, lastName: nil)
        }

        STPAPIClient.shared().createToken(with: payment) { (stpToken, error) in
            if let error = error {
                print("ERROR: STPAPIClient.shared().createToken payment failed: \(error)")
                completion(PKPaymentAuthorizationResult(status: .failure,
                                                        errors: [error]))
                self.delegate?.paymentMethodCreationError(sender: self, error: error)
                return
            }

            guard let stpToken = stpToken else {
                print("ERROR: paymentAuthorizationViewController had no stpToken")
                completion(PKPaymentAuthorizationResult(status: .failure,
                                                        errors: [ADPaymentError.missingId]))
                self.delegate?.paymentMethodCreationError(sender: self, error: ADPaymentError.missingId)
                return
            }

            self.createPaymentMethodFromStpToken(token: stpToken) { paymentToken, error in
                assert(Thread.isMainThread)

                self.applePayVC = nil
                controller.dismiss(animated: true, completion: nil)
                completion(PKPaymentAuthorizationResult(status: error == nil ? .success : .failure,
                                                        errors: error == nil ? nil : [error!]))

                if let e = error {
                    self.delegate?.paymentMethodCreationError(sender: self, error: e)
                } else {
                    if let pt = paymentToken {
                        self.delegate?.paymentMethodCreated(sender: self, paymentToken: pt)
                    } else {
                        self.delegate?.paymentMethodCreationError(sender: self, error: ADPaymentError.incompleteImplementation)
                    }
                }
            }
        }
    }
}
