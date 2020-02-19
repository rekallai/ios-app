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
    var imageResizeProxyUrl = ""
    
    //#error("Please configure staging and production hostnames")
    let stagingDomain = "americandream.dev"
    let productionDomain = "americandream.com"
    
    #warning("Also configure the following")
    let appleMerchantId = "<apple merchant ID>"
    let applePasskitTypeIdentifier = "<apple passkit ID>"
    let jibeStreamHost = "https://api.jibestream.com"
    let jibeStreamClientId = "<jibestream client ID>"
    let jibeStreamClientSecret = "<jibestream client secret>"
    let jibeStringCustomerId: Int32 = 0
    let jibeStreamVenueId: Int32 = 0
    let projectName = "Rekall ios-app"
    let termsUrl = "https://rekall.ai/terms"
    let privacyUrl = "https://rekall.ai/privacy"
    let segmentWriteKey = "<segment write key>"

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
            configureForPlatform(platform: .production)
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
                imageResizeProxyUrl = "http://" + targetIp + ":8085/img"
            case .staging:
                apiBaseUrl = "https://api.\(stagingDomain)"
                shareBaseUrl = "https://www.\(stagingDomain)"
                imageResizeProxyUrl = "https://images.\(stagingDomain)/img"
            case .production:
                apiBaseUrl = "https://api.\(productionDomain)"
                shareBaseUrl = "https://www.\(productionDomain)"
                imageResizeProxyUrl = "https://images.\(productionDomain)/img"
        }
    }
    
    class func resetAppState() {
        ADApi.shared.store.signOut()
        ADPersistentContainer.resetContainer()
        CoreDataContext.resetCoreDataContext()
    }    
}
