import Foundation
import Moya

class AuthViewModel: ViewModel {
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFailure: ((APIError) -> Void)?
    
    var onLoginSuccess: (() -> Void)?
    var onLoginFailure: ((String) -> Void)?
    
    var onUpdateSuccess:(() -> Void)?
    var onUpdateFailure: ((String) -> Void)?
    
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    
    func performRegistrationForPayment(firstName: String, lastName: String, email: String, password: String, paymentMethodId: String?){
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        
        submitRegister()
    }
    
    func submitRegister() {
        let regRequest = AuthRequestRegister()
        regRequest.firstName = firstName
        regRequest.lastName = lastName
        regRequest.email = email
        regRequest.password = password
        
        request(regRequest) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    print("success")
                    self.processAuthResponseRegister(response: response)
                    self.onRegisterSuccess?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failure: \(error)")
                    self.onRegisterFailure?(error)
                }
            }
        }
    }
    
    func submitLogin(email: String, password: String) {
        let loginRequest = AuthRequestLogin()
        loginRequest.email = email
        loginRequest.password = password
        
        request(loginRequest) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let error = self.processAuthResponseLogin(response: response) {
                        self.onLoginFailure?(error.localizedDescription)
                    } else {
                        self.onLoginSuccess?()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failure: \(error)")
                    self.onLoginFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUser(){
        let updateRequest = UserUpdateRequest()
        updateRequest.firstName = firstName
        updateRequest.lastName = lastName
        updateRequest.email = email
        updateRequest.password = password
        
        request(updateRequest) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.onUpdateSuccess?()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Failure: \(error)")
                    self.onUpdateFailure?(error.localizedDescription)
                }
            }
        }
    }
    
    func processAuthResponseRegister(response: Moya.Response){
        do {
            let result = try decodeResponse(AuthResponseRegister.self, response: response, moc: nil)
            store.storeToken(newToken: result.data.token)
            print("Result: \(result)")
        } catch {
            print("Failed: \(error)")
        }
    }

    // Return nil if there is no error
    func processAuthResponseLogin(response: Moya.Response) -> Error? {
        do {
            let result = try decodeResponse(AuthResponseLogin.self, response: response, moc: nil)
            store.storeToken(newToken: result.data.token)
            return nil
        } catch {
            print("Failed: \(error)")
            return error
        }
    }
    
}
