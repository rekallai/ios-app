//
//  Environment.swift
//  Rekall
//
//  Created by Ray Hunter on 29/11/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class Environment {

    static let shared = Environment()
    
    enum Platform: String {
        case build
        case staging
        case production
    }
    
    var apiBaseUrl = ""
    var shareBaseUrl = ""
    
    #error("Please configure staging and production hostnames")
    let stagingDomain = "yoursite.dev"
    let productionDomain = "yoursite.com"
    
    #warning("Also configure the following")
    let projectName = "Bedrock ios-app"
    let termsUrl = "https://bedrock.io/terms"
    let privacyUrl = "https://bedrock.io/privacy"

    private let currentEnvironmentKey = "CurrentEnvironment"
    
    var currentPlatform: Platform = .production {
        didSet {
            Self.resetAppState()
            configureForPlatform(platform: currentPlatform)
            UserDefaults.standard.set(currentPlatform.rawValue, forKey: currentEnvironmentKey)
        }
    }
        
    private init() {
        if let storedEnvStr = UserDefaults.standard.string(forKey: currentEnvironmentKey),
        let storedEnv = Platform(rawValue: storedEnvStr) {
            currentPlatform = storedEnv
            configureForPlatform(platform: storedEnv)
        } else {
            currentPlatform = .production
            configureForPlatform(platform: currentPlatform)
        }
    }
    
    func configureForPlatform(platform: Platform) {
        switch platform {
            case .build:
                let infoDict = Bundle.main.infoDictionary
                let targetIp: String = {
                    if let buildIp = (infoDict?["BUILD_SERVER_IP"] as? String),
                    buildIp.count > 0 {
                        return buildIp
                    } else {
                        return "0.0.0.0"
                    }
                }()
                apiBaseUrl = "http://" + targetIp + ":2300"
                shareBaseUrl = "http://" + targetIp + ":2200"
            case .staging:
                apiBaseUrl = "https://api.\(stagingDomain)"
                shareBaseUrl = "https://www.\(stagingDomain)"
            case .production:
                apiBaseUrl = "https://api.\(productionDomain)"
                shareBaseUrl = "https://www.\(productionDomain)"
        }
    }
    
    class func resetAppState() {
        BRApi.shared.store.signOut()
        BRPersistentContainer.resetContainer()
        CoreDataContext.resetCoreDataContext()
    }    
}
