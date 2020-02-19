//
//  UIStoryboard+Instantiate.swift
//  Rekall
//
//  Created by Steve on 7/9/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

extension UIStoryboard {
        
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
}
