//
//  PaymentViewModel.swift
//  Rekall
//
//  Created by Ray Hunter on 26/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import PassKit


class PaymentViewModel: ViewModel {

    var onTicketOptionsSuccess: (() -> Void)?
    var onTicketOptionsFailure: ((String) -> Void)?

    var onTicketInventorySuccess: (() -> Void)?
    var onTicketInventoryFailure: ((String) -> Void)?

    var onOrderSuccess: (() -> Void)?
    var onOrderFailure: ((String) -> Void)?
    var onOrderEmailAlreadyInUse: (() -> Void)?
    var onOrderCancelled: (() -> Void)?
    
    var applePayCompleted: (() -> Void)?
    
    private var confirmedOrder: ConfirmedOrder?
    var paymentClient: StripeClient?
    
    var ticketPriceCalculator = TicketPriceCalculator()
    
    private(set) var authViewModel: AuthViewModel?
    
    // Payment info
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var cardNumber: String?
    var securityCode: String?
    var month: String?
    var year: String?
    var zipCode: String?
    var saveCardDetails = true
    
    // Ticket info
    var venue: Venue?
    static var sessionTicketDate = Date()
    var ticketDate = { () -> Date in
        let minDate = DateFormatter.yearMonthDayGmt.date(from: "2019-10-28")!
        return (Date() < minDate) ? minDate : Date()
    }() {
        didSet {
            PaymentViewModel.sessionTicketDate = ticketDate
        }
    }
    var ticketOptions: [TicketOption]?
    private var ticketInventory: [TicketInventoryItem]?     // Bundled tickets must be last

    private(set) var applePayEmail: String?
    private var applePayFirstName: String?
    private var applePayLastName: String?
    
    var ticketOptionsCount: Int {
        return self.ticketOptions?.count ?? 0
    }
    
    public func ticketOption(at index:Int) -> TicketOption? {
        guard ticketOptions?.count ?? 0 > index else {
            return nil
        }
        
        return ticketOptions?[index]
    }
     
    var regularTicketInventoryCount: Int {
        guard let ticketInventory = ticketInventory else { return 0 }
        var count = 0
        ticketInventory.forEach{ if !$0.bundled {count += 1} }
        return count
    }
    
    var bundledTicketInventoryCount: Int {
        guard let ticketInventory = ticketInventory else { return 0 }
        var count = 0
        ticketInventory.forEach{ if $0.bundled {count += 1} }
        return count
    }
    
    public func regularTicketInventoryItem(at index:Int) -> TicketInventoryItem? {
        guard ticketInventory?.count ?? 0 > index else {
            return nil
        }
        
        return ticketInventory?[index]
    }
    
    public func bundledTicketInventoryItem(at index:Int) -> TicketInventoryItem? {
        let nrRegularTickets = regularTicketInventoryCount
        
        guard ticketInventory?.count ?? 0 > index + nrRegularTickets else {
            return nil
        }
        
        return ticketInventory?[index + nrRegularTickets]
    }
    
    public func isBundledTicketQuantityValid() -> Bool {
        guard let ticketInventory = ticketInventory else { return true }

        var nrRegularTickets = 0
        var nrBundledTickets = 0
        for ticket in ticketInventory {
            if ticket.bundled {
                nrBundledTickets += ticket.orderQuantity ?? 0
            } else {
                nrRegularTickets += ticket.orderQuantity ?? 0
            }
        }
        
        return nrBundledTickets <= nrRegularTickets * 2
    }

    func errorMessageForTicketQuantity() -> String? {
        guard ticketOrderCount() > 0 else {
            return NSLocalizedString("Please select at least 1 ticket to proceed.",
                                     comment: "Error message")
        }
        
        guard isBundledTicketQuantityValid() else {
            return NSLocalizedString("You can buy 2x the number of non-ferry tickets you are purchasing.",
                                     comment: "Error message")
        }

        return nil
    }
    
    /// Return nil if we have all required payment information, or a string describing the
    /// current error
    func errorMessageForPaymentDetails() -> String? {
        guard firstName?.count ?? 0 > 0 else {
            return NSLocalizedString("Please enter your first name", comment: "ErrorMessage")
        }
        guard lastName?.count ?? 0 > 0 else {
            return NSLocalizedString("Please enter your last name", comment: "ErrorMessage")
        }
        guard email?.isValidEmailAddress() ?? false else {
            return NSLocalizedString("Please enter a valid email address", comment: "ErrorMessage")
        }
        if !store.isLoggedIn {
            guard password?.count ?? 0 >= 6 else {
                return NSLocalizedString("Please enter at least 6 characters for your password",
                                         comment: "ErrorMessage")
            }
        }
        guard cardNumber?.count ?? 0 > 0 else {
            return NSLocalizedString("Please enter your credit card number", comment: "ErrorMessage")
        }
        guard securityCode?.count ?? 0 > 0 else {
            return NSLocalizedString("Please enter your security code", comment: "ErrorMessage")
        }
        guard let monthStr = month,
              let monthInt = Int(monthStr),
              1 <= monthInt && monthInt <= 12 else {
            return NSLocalizedString("Please enter your credit card expiry month", comment: "ErrorMessage")
        }
        guard let yearStr = year,
              let yearInt = Int(yearStr),
              (19 <= yearInt && yearInt <= 99 ) || (2019 <= yearInt && yearInt <= 2099)  else {
            return NSLocalizedString("Please enter your credit card expiry year", comment: "ErrorMessage")
        }
        guard zipCode?.count ?? 0 > 0 else {
            return NSLocalizedString("Please enter your zipcode", comment: "ErrorMessage")
        }
        
        return nil
    }
    
    
    public func displayableCardNumber() -> String? {
        if let cn = cardNumber?.suffix(4) {
            return "••••\(cn)"
        }
        
        return nil
    }
    
    
    public func setIndexedTicketQuantity(quantity: Int, for item: Int) {
        guard let ticketInventory = ticketInventory else {
            preconditionFailure("Cannot set ticket quantity - there are no tickets")
        }
        
        ticketInventory[item].orderQuantity = quantity
        ticketPriceCalculator.update(quantity: quantity, at: item)
    }
    
    
    public func setRegularTicketQuantity(quantity: Int, for item: Int) {
        guard let ticketInventory = ticketInventory else {
            preconditionFailure("Cannot set ticket quantity - there are no tickets")
        }
        
        assert(!ticketInventory[item].bundled)
        
        ticketInventory[item].orderQuantity = quantity
        ticketPriceCalculator.update(quantity: quantity, at: item)
    }
    
    
    public func setBundledTicketQuantity(quantity: Int, for item: Int) {
        guard let ticketInventory = ticketInventory else {
            preconditionFailure("Cannot set ticket quantity - there are no tickets")
        }
        
        let nrRegularTickets = regularTicketInventoryCount
        let bundledIndex = item + nrRegularTickets
        
        assert(ticketInventory[bundledIndex].bundled)
        
        ticketInventory[bundledIndex].orderQuantity = quantity
        ticketPriceCalculator.update(quantity: quantity, at: bundledIndex)
    }

    public func getTicketQuantities() -> [Int] {
        return ticketInventory?.map{ return $0.orderQuantity ?? 0 } ?? []
    }
    
    
    public func ticketOrderCount() -> Int {
        guard let ticketInventory = ticketInventory else {
            return 0
        }

        var totalTicketCount = 0
        
        for inventoryItem in ticketInventory {
            guard let quantity = inventoryItem.orderQuantity, quantity > 0 else {
                continue
            }
            
            totalTicketCount += quantity
        }
        
        return totalTicketCount
    }
    
    
    public func payWithApplePay(hostViewController: UIViewController) {
        guard let purchase = getPurchase() else {
            print("ERROR: payWithApplePay: failed to getPurchase()")
            return
        }
        
        let paymentClient = StripeClient(hostViewController: hostViewController, payment: purchase)
        payWithApplePay(paymentClient: paymentClient)
    }
    
    
    public func payWithCreditCard(hostViewController: UIViewController) {
        guard let purchase = getPurchase() else {
            print("ERROR: payWithCreditCard: failed to getPurchase()")
            return
        }
        
        let paymentClient = StripeClient(hostViewController: hostViewController, payment: purchase)
        payWithCreditCard(paymentClient: paymentClient)
    }
    
    
    public func payWithSavedPaymentMethod(hostViewController: UIViewController, stripeMethodId: String) {
        guard let purchase = getPurchase() else {
            print("ERROR: payWithSavedPaymentMethod: failed to getPurchase()")
            return
        }
        
        paymentClient = StripeClient(hostViewController: hostViewController, payment: purchase)
        paymentClient?.delegate = self
        
        reserveTicketsOnServer(stripeMethodPaymentToken: stripeMethodId)
    }
    
    
    public func getPurchase() -> ADPurchase? {
        guard let ticketInventory = ticketInventory else {
            return nil
        }
        
        let purchase = ADPurchase()
        for inventoryItem in ticketInventory {
            guard let quantity = inventoryItem.orderQuantity, quantity > 0 else {
                continue
            }
            
            purchase.addItem(item: ADPurchase.Item(itemId: inventoryItem.ticketOptionId,
                                                   name: inventoryItem.name,
                                                   quantity: quantity,
                                                   priceUsd: inventoryItem.itemPriceIncludingTax()))
        }
        
        return purchase
    }
    
    
    public func loadTicketOptions() {
        let ticketsRequest = TicketOptionRequest()
        ticketsRequest.venueId = venue?.id
        performTicketOptionsRequest(ticketsRequest)
    }
    
    public func loadTicketInventory() {
        guard let venueId = venue?.id else {
            print("ERROR: Did not have a venue ID")
            return
        }
        
        let ticketsRequest = APIRequestTicketInventory(venueId: venueId, date: ticketDate)
        performTicketInventoryRequest(ticketsRequest)
    }
    
    
    private func performTicketOptionsRequest(_ ticketsRequest:ADBaseRequest) {
        request(ticketsRequest) { [weak self] result in
            switch result {
            case .success(let response):
                self?.processTicketOptionsResponse(response)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onTicketOptionsFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func performTicketInventoryRequest(_ ticketsRequest:ADBaseRequest) {
        request(ticketsRequest) { [weak self] result in
            switch result {
            case .success(let response):
                self?.processTicketInventoryResponse(response)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onTicketInventoryFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func processTicketOptionsResponse(_ response: Moya.Response) {
        do {
            let ticketResult = try self.decodeResponse(
                TicketOptionResponse.self, response: response
            )
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    strongSelf.ticketOptions = ticketResult.data
                    self?.onTicketOptionsSuccess?()
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                print("ERROR: TicketOptionViewModel: processTicketOptionsResponse: \(error)")
                self?.onTicketOptionsFailure?(error.localizedDescription)
            }
        }
    }
    
    
    private func processTicketInventoryResponse(_ response: Moya.Response) {
        do {
            let ticketResult = try self.decodeResponse(
                APIResponseTicketInventory.self, response: response
            )
            DispatchQueue.main.async { [weak self] in
                if let strongSelf = self {
                    
                    var nonBundled = [TicketInventoryItem]()
                    var bundled = [TicketInventoryItem]()
                    for ticket in ticketResult.data.ticketInventory {
                        if ticket.bundled {
                            bundled.append(ticket)
                        } else {
                            nonBundled.append(ticket)
                        }
                    }
                    strongSelf.ticketInventory = nonBundled + bundled
                    
                    if strongSelf.ticketInventory != nil {
                        strongSelf.ticketPriceCalculator.setTickets(tickets: strongSelf.ticketInventory!)
                    }
                    self?.onTicketInventorySuccess?()
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                print("ERROR: TicketOptionViewModel: processTicketInventoryResponse: \(error)")
                self?.onTicketInventoryFailure?(error.localizedDescription)
            }
        }
    }
}


//
//  Payment and order finalization
//
extension PaymentViewModel {
    private func reserveTicketsOnServer(stripeMethodPaymentToken: String) {
        guard let items = paymentClient?.payment.items else {
            print("ERROR: OrderViewModel: Cannot finalize payment as the shopping cart was empty")
            onOrderCancelled?()
            return
        }
                
        let ticketDateStr = DateFormatter.yearMonthDayGmt.string(from: ticketDate)
        var orderItems = [APIRequestOrderReserve.TicketOrderOption]()
        for item in items {
            orderItems.append(APIRequestOrderReserve.TicketOrderOption(ticketOptionId: item.itemId,
                                                                       quantity: item.quantity,
                                                                       reservationDate: ticketDateStr))
        }
        
        let orderRequest = APIRequestOrderReserve(items: orderItems,
                                                  paymentToken: stripeMethodPaymentToken,
                                                  saveCardDetails: saveCardDetails)
        
        request(orderRequest) { result in
            switch result {
            case .success(let response):
                self.processServerOrderReservationResponse(response)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onOrderFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func createNewUserAccount(stripeMethodPaymentToken: String) {
        assert(!store.isLoggedIn)
        
        authViewModel = AuthViewModel(api: api, store: store)
        authViewModel?.onRegisterSuccess = { [weak self] in
            self?.reserveTicketsOnServer(stripeMethodPaymentToken: stripeMethodPaymentToken)
        }
        
        authViewModel?.onRegisterFailure = { [weak self] error in
            self?.authViewModel = nil
            
            if let apiError = error as? APIError, case .emailAlreadyUsed = apiError {
                self?.onOrderEmailAlreadyInUse?()
            } else {
                self?.onOrderFailure?(error.localizedDescription)
            }
        }
        
        if let applePayEmail = applePayEmail, let applePayFirstName = applePayFirstName, let applePayLastName = applePayLastName {
            authViewModel?.performRegistrationForPayment(firstName: applePayFirstName,
                                                         lastName: applePayLastName,
                                                         email: applePayEmail,
                                                         password: nil,
                                                         paymentMethodId: stripeMethodPaymentToken)
        } else if let firstName = firstName, let lastName = lastName, let email = email, let password = password {
            authViewModel?.performRegistrationForPayment(firstName: firstName,
                                                         lastName: lastName,
                                                         email: email,
                                                         password: password,
                                                         paymentMethodId: nil)
        } else {
            print("ERROR: Fullname or email was nil but we're in the middle of the payment process already.")
            authViewModel = nil
            self.onOrderFailure?("Unable to sign user up")
        }
    }
    
    
    private func processServerOrderReservationResponse(_ response: Moya.Response) {
        do {
            
            let reservationResult = try self.decodeResponse(
                APIResponseOrderReserve.self, response: response, moc: nil
            )
            
            guard let paymentIntentClientSecret = reservationResult.data.intent?.client_secret else {
                //
                // If we don't get an intent back, the order has completed
                //
                confirmedOrder = reservationResult.data.order
                try addPurchasedOrdersToCoreData(orderResult: reservationResult.data.order)
                
                DispatchQueue.main.async {
                    UserViewModel.shared.loadUser()
                    self.onOrderSuccess?()
                }

                return
            }
            
            paymentClient?.confirmPaymentIntent(paymentIntentClientSecret: paymentIntentClientSecret,
                                                completion: { completedPaymentIntent, errorStr in
                guard let completedPaymentIntentId = completedPaymentIntent?.stripeId else {
                    DispatchQueue.main.async {
                        if let errorStr = errorStr {
                            self.onOrderFailure?(errorStr)
                        } else {
                            self.onOrderCancelled?()
                        }
                    }
                    
                    return
                }
                
                self.confirmOrderOnServer(orderId: reservationResult.data.order.id,
                                          paymentIntentId: completedPaymentIntentId)
            })
        } catch {
            print("ERROR: Decoding response: \(error)")
            DispatchQueue.main.async {
                self.onOrderFailure?(error.localizedDescription)
            }
        }
    }
    
    
    func didCreatePasswordlessAccountDuringPurchase() -> Bool {
        return authViewModel != nil && (password == nil || password?.count == 0)
    }
    
    
    private func confirmOrderOnServer(orderId: String, paymentIntentId: String) {
        let confirmRequest = APIRequestOrderConfirm(orderId: orderId,
                                                    paymentIntentId: paymentIntentId,
                                                    saveCard: saveCardDetails)
                
        request(confirmRequest) { result in
            switch result {
            case .success(let response):
                self.processServerConfirmationResponse(response)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onOrderFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    private func processServerConfirmationResponse(_ response: Moya.Response) {
        do {
            
            //let strResponse = String(data: response.data, encoding: .utf8)
            
            let orderResult = try self.decodeResponse(
                APIResponseOrderConfirm.self, response: response, moc: nil
            )
            
            confirmedOrder = orderResult.data.order
            
            try addPurchasedOrdersToCoreData(orderResult: orderResult.data.order)
            
            DispatchQueue.main.async {
                UserViewModel.shared.loadUser()
                self.onOrderSuccess?()
            }
        } catch {
            print("ERROR: Decoding response: \(error)")
            DispatchQueue.main.async {
                self.onOrderFailure?(error.localizedDescription)
            }
        }
    }
    
    
    private func addPurchasedOrdersToCoreData(orderResult: ConfirmedOrder) throws {
        assert(!Thread.isMainThread)
        
        let workMoc = ADPersistentContainer.shared.childContext
        
        guard let venue = venue else {
            print("ERROR: Vanue was nil but we're trying to add purchased tickets for it.")
            return
        }
        
        let order = PurchasedOrder(context: workMoc,
                                   venue: venue,
                                   confirmedOrder: orderResult)

        LocalNotificationManager.shared.scheduleNotificationFor(order: order)

        try workMoc.save()
        
        DispatchQueue.main.async {
            ADPersistentContainer.shared.save()
        }
    }
}


extension PaymentViewModel: ADPaymentDelegate {
    
    private func payWithApplePay(paymentClient: StripeClient){
        self.paymentClient = paymentClient
        paymentClient.delegate = self
        paymentClient.authorizeWithApplePay(requestEmailAndName: !store.isLoggedIn)
    }
    
    
    private func payWithCreditCard(paymentClient: StripeClient){
        self.paymentClient = paymentClient
        paymentClient.delegate = self
        
        guard let cardNumber = cardNumber,
              let month = month,
              let monthInt = Int(month),
              let year = year,
              let yearInt = Int(year),
              let securityCode = securityCode else {
                print("ERROR: Missing card payment details")
                return
        }
        paymentClient.createPaymentMethodWithCreditCardDetails(cardNumber: cardNumber,
                                                               expiryMonth: monthInt,
                                                               expiryYear: yearInt,
                                                               cvc: securityCode)
    }
    
    
    func applePayProvided(email: String?, firstName: String?, lastName: String?) {
        applePayEmail = email
        applePayFirstName = firstName
        applePayLastName = lastName
        applePayCompleted?()
    }
    
    
    func paymentMethodCreated(sender: StripeClient, paymentToken: String) {
        if store.isLoggedIn {
            reserveTicketsOnServer(stripeMethodPaymentToken: paymentToken)
        } else {
            createNewUserAccount(stripeMethodPaymentToken: paymentToken)
        }
    }
    
    
    func paymentMethodCreationError(sender: StripeClient, error: Error?) {
        onOrderFailure?(error?.localizedDescription ??
            NSLocalizedString("Payment auth failed", comment: "Fallback error message") )
    }
    
    
    func paymentMethodCreationCancelled(sender: StripeClient) {
        onOrderCancelled?()
    }
}

extension PaymentViewModel {
    func getPassesIdsAndAuthTokens() -> [(String, String)]? {
        guard let tickets = confirmedOrder?.tickets, tickets.count > 0 else {
            return nil
        }
        
        var codes = [(String, String)]()
        for ticket in tickets {
            codes.append((ticket.id, ticket.passkitAuthorizationToken))
        }
        
        return codes
    }
}
