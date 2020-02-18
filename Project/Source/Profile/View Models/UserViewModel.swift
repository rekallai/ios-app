//
//  UserViewModel.swift
//  Rekall
//
//  Created by Steve on 6/25/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Moya
import Stripe

class UserViewModel: ViewModel {
    
    static let shared = UserViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    private override init(api: APIProvider, store: Store) {
        super.init(api: api, store: store)
    }
    
    var onUpdateUserSuccess: (() -> Void)?
    var onUpdateUserFailure: ((String) -> Void)?
    
    var onDeleteCardSuccess: (() -> Void)?
    var onDeleteCardFailure: ((String) -> Void)?

    var user = Defaults.getUser()
    var isRegisterRequest = false
    
    private var stripeCustomerContext: STPCustomerContext?
    private var stripePaymentContext: STPPaymentContext?
    
    // We want to refresh the users' tickets once a user refresh has occurred
    private let purchasedOrdersViewModel = PurchasedOrdersViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    
    private var existingPaymentMethods = [PaymentMethodsResponse.PaymentMethod]()
    private var selectedExistingPaymentMethodIndex = 0
    
    private var dataLoadFailed = false
    
    public func loadUser() {
        runUserRequest(UserRequest())
    }
    
    public func loadUserIfPreviouslyFailed() {
        guard dataLoadFailed else {
            return
        }
        
        runUserRequest(UserRequest())
    }
    
    public func updateInterest(_ interestName:String) {
        user.updateInterest(interestName)
        Defaults.storeUser(user)
        if userLoggedIn() {
            let userRequest = UserUpdateRequest()
            userRequest.interestTopics = user.interestTopics
            runUserRequest(userRequest)
        }
    }
    
    public func updateFavorite(_ venueId:String) {
        user.updateFavorite(venueId)
        Defaults.storeUser(user)
        if userLoggedIn() {
            let userRequest = UserUpdateRequest()
            userRequest.favoriteVenueIds = user.favoriteVenueIds
            runUserRequest(userRequest)
        }
    }
    
    public func updateTermsAccepted() {
        if userLoggedIn() {
            let userRequest = UserUpdateRequest()
            userRequest.optIns = OptIns(termsAccepted: true)
            runUserRequest(userRequest)
        }
    }
    
    public func updateDetails(firstName: String, lastName: String, email: String) {
        let userRequest = UserUpdateRequest()
        userRequest.firstName = firstName
        userRequest.lastName = lastName
        userRequest.email = email
        runUserRequest(userRequest)
    }
    
    public func update(favoriteIds: [String], interestIds: [String]) {
        let userRequest = UserUpdateRequest()
        userRequest.favoriteVenueIds = favoriteIds
        userRequest.interestTopics = interestIds
        runUserRequest(userRequest)
    }
    
    public func haveSavedPaymentMethod() -> Bool {
        if existingPaymentMethods.count > 0,
            existingPaymentMethods[0].card != nil {
                return true
        }
        
        return false
    }
    
    func numberOfSavedPaymentMethods() -> Int {
        return existingPaymentMethods.count
    }
    
    func deleteSavedPaymentMethodAt(index: Int) {
        guard existingPaymentMethods.count > index else {
            return
        }
        
        let deleteRequest = APIRequestDeletePaymentMethod(methodId: existingPaymentMethods[index].id)
        request(deleteRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.existingPaymentMethods.remove(at: index)
                    if self.selectedExistingPaymentMethodIndex >= self.existingPaymentMethods.count {
                        self.selectedExistingPaymentMethodIndex = 0
                    }
                    self.onDeleteCardSuccess?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onDeleteCardFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func savedPaymentSummaryDetailsAt(index: Int) -> String {
        guard existingPaymentMethods.count > index,
            let card = existingPaymentMethods[index].card else {
                return "NO CARD"
        }
                
        return "\(card.brand.capitalized) ••••\(card.last4)"
    }
    
    func setSelectedExistingPaymentCard(index: Int){
        selectedExistingPaymentMethodIndex = index
    }
    
    public func savedCardPaymentSummaryDetails() -> String {
        guard existingPaymentMethods.count > selectedExistingPaymentMethodIndex,
            let card = existingPaymentMethods[selectedExistingPaymentMethodIndex].card else {
                return "NO CARD"
        }
        
        return "\(card.brand.capitalized) ••••\(card.last4)"
    }
    
    public func savedCardStripeId() -> String? {
        guard existingPaymentMethods.count > selectedExistingPaymentMethodIndex else {
            return nil
        }
        
        return existingPaymentMethods[selectedExistingPaymentMethodIndex].id
    }
    
    public func isLiked(_ interestName:String)->Bool {
        return user.isInterested(interestName)
    }
    
    public func isFavorited(_ venueId:String)->Bool {
        return user.isFavorited(venueId)
    }
    
    public func signOut() {
        resetUser()
        store.signOut()
        PurchasedOrder.removeAllStoredTickets(moc: ADPersistentContainer.shared.viewContext)
        LocalNotificationManager.shared.removePendingNotifications()
        existingPaymentMethods = []
    }
    
    private func resetUser() {
        let newUser = User.anonymous()
        Defaults.storeUser(newUser)
        user = newUser
        Defaults.setTermsAccepted(false)
    }
    
    private func userLoggedIn()->Bool {
        return ADApi.shared.store.isLoggedIn
    }
    
    private func runUserRequest(_ userRequest: ADBaseRequest) {
        request(userRequest) { result in
            switch result {
            case .success(let response):
                self.dataLoadFailed = false
                self.processUserResponse(response)
            case .failure(let error):
                self.dataLoadFailed = true
                DispatchQueue.main.async { [weak self] in
                    if case APIError.tokenExpired = error {
                        self?.signOut()
                    }
                    
                    self?.onUpdateUserFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    private func processUserResponse(_ response:Moya.Response) {
        do {
            let userResult = try self.decodeResponse(
                UserResponse.self, response: response
            )
            var newUser = userResult.data
            if isRegisterRequest {
                newUser.interestTopics = user.interestTopics
                newUser.favoriteVenueIds = user.favoriteVenueIds
                isRegisterRequest = false
                update(favoriteIds: user.favoriteVenueIds, interestIds: user.interestTopics)
            }
            user = newUser
            Defaults.storeUser(newUser)
            DispatchQueue.main.async { [weak self] in
                self?.notifyLoggedIn(user: newUser)
                self?.getPaymentMethods()
            }
        } catch {
            print("ERROR: Failed to decode user response: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.onUpdateUserFailure?(error.localizedDescription)
            }
        }
    }
    
    private func notifyLoggedIn(user:User) {
        let userInfo: [String: User] = ["user": user]
        NotificationCenter.default.post(name: Notification.userLoggedIn, object: nil, userInfo: userInfo)
    }
}


//
//  Payment methods on server
//
extension UserViewModel {
    
    private func getPaymentMethods(){
        let req = APIRequestPaymentMethods()
        
        request(req) { [weak self] result in
            switch result {
            case .success(let response):
                self?.processPaymentMethodsResponse(response: response)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.onUpdateUserFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    
    private func processPaymentMethodsResponse(response: Moya.Response) {
        do {
            let response = try decodeResponse(PaymentMethodsResponse.self, response: response)
            existingPaymentMethods = response.data
            DispatchQueue.main.async { [weak self] in
                self?.onUpdateUserSuccess?()
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.onUpdateUserFailure?(error.localizedDescription)
            }
        }
    }
}
