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
    var intercomApiKey = ""
    var intercomAppId = ""
    var imageResizeProxyUrl = ""
    var stripePublishableKey = ""
    
    #error("Please configure staging and production hostnames")
    let stagingDomain = "something.dev"
    let productionDomain = "something.com"
    
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
                intercomApiKey = "ios_sdk-d4ca423bb4baba2c4b3c3627f8ff5aee6f6787d1"
                intercomAppId = "apnna7l5"
                imageResizeProxyUrl = "http://" + targetIp + ":8085/img"
                stripePublishableKey = "pk_test_gdAwzS5ZFLgraXVv9t1tvEKC003VxrSiso"
            case .staging:
                apiBaseUrl = "https://api.\(stagingDomain)"
                shareBaseUrl = "https://www.\(stagingDomain)"
                intercomApiKey = "ios_sdk-d4ca423bb4baba2c4b3c3627f8ff5aee6f6787d1"
                intercomAppId = "apnna7l5"
                imageResizeProxyUrl = "https://images.\(stagingDomain)/img"
                stripePublishableKey = "pk_test_gdAwzS5ZFLgraXVv9t1tvEKC003VxrSiso"
            case .production:
                apiBaseUrl = "https://api.\(productionDomain)"
                shareBaseUrl = "https://www.\(productionDomain)"
                intercomApiKey = "ios_sdk-4a798d6131ea75dc47fbf3c285f283f0bfd0061c"
                intercomAppId = "mgbej7a6"
                imageResizeProxyUrl = "https://images.\(productionDomain)/img"
                stripePublishableKey = "pk_live_NZNIoCFUSAbJAeGVtPOn1evZ006qjpFEd7"
        }
        
        StripeClient.configureStripe(publishableKey: stripePublishableKey, appleMerchantId: appleMerchantId, projectName: projectName)
        IntercomManager.shared.configure(apiKey: intercomApiKey, appId: intercomAppId)
    }
    
    class func resetAppState() {
        ADApi.shared.store.signOut()
        ADPersistentContainer.resetContainer()
        CoreDataContext.resetCoreDataContext()
    }    
}
