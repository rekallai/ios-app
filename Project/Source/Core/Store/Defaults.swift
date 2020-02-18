//
//  Defaults.swift
//  Rekall
//
//  Created by Steve on 6/28/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation

class Defaults {
    static let userKey = "UserKey"
    static let onboardKey = "OnboardKey"
    static let termsAccepted = "TermsKey"
    
    static func storeUser(_ user:User) {
        if let encoded = try? JSONEncoder().encode(user) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: userKey)
        }
    }
    
    static func getUser()->User {
        if let userData = UserDefaults.standard.object(forKey: userKey) as? Data {
            if let loadedUser = try? JSONDecoder().decode(User.self, from: userData) {
                return loadedUser
            }
        }
        return User.anonymous()
    }
    
    static func setOnboarded() {
        UserDefaults.standard.set(true, forKey: onboardKey)
    }
    
    static func hasOnboarded()->Bool {
        if let onboarded = UserDefaults.standard.object(forKey: onboardKey) as? Bool {
            return onboarded
        }
        return false
    }
    
    static func setTermsAccepted(_ accepted: Bool = true) {
        UserDefaults.standard.set(accepted, forKey: termsAccepted)
    }
    
    static func hasAcceptedTerms()->Bool {
        if let accepted = UserDefaults.standard.object(forKey: termsAccepted) as? Bool {
            return accepted
        }
        return false
    }
    
    static func resetDefaults() {
        UserDefaults.standard.removeObject(forKey: userKey)
        UserDefaults.standard.removeObject(forKey: onboardKey)
        UserDefaults.standard.removeObject(forKey: termsAccepted)
    }
}
