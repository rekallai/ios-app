//
//  UIStoryboard+Instantiate.swift
//  Rekall
//
//  Created by Steve on 7/9/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func ticketForm()->OrderVenueTicketsViewController? {
        let sb = UIStoryboard(name: "Payment", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? OrderVenueTicketsViewController else {
            return nil
        }
        return vc
    }
    
    static func preAuth()->UINavigationController? {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        guard let navCon = sb.instantiateViewController(
            withIdentifier: "PreAuth"
        ) as? UINavigationController else {
            return nil
        }
        return navCon
    }
    
    static func auth()->AuthRootViewController? {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "AuthRootViewController") as? AuthRootViewController else { return nil }
        return vc
    }
    
    static func venueDetail()->VenueDetailViewController? {
        let sb = UIStoryboard(name: "Venue", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? VenueDetailViewController else { return nil }
        return vc
    }
    
    static func ticketDetail()->TicketDetailViewController? {
        let sb = UIStoryboard(name: "Tickets", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? TicketDetailViewController else { return nil }
        return vc
    }
    
    static func eventDetail()->EventDetailViewController? {
        let sb = UIStoryboard(name: "Event", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? EventDetailViewController else { return nil }
        return vc
    }
    
    static func onboarding()->WelcomeViewController? {
        let sb = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? WelcomeViewController else { return nil }
        return vc
    }
    
    static func interests()->InterestsViewController? {
        let sb = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "InterestsViewController") as? InterestsViewController else { return nil }
        return vc
    }
    
    static func webView()->ADWebViewController? {
        let sb = UIStoryboard(name: "WebView", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() as? ADWebViewController else { return nil }
        return vc
    }
}
