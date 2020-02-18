//
//  MapViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 26/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import JMapCoreKit
import JMapRenderingKit
import JMapControllerKit
import JMapUIKit
import CoreLocation

let USER_IS_ONSITE = false

class MapViewController: UIViewController {

    @IBOutlet var mapDebugView: UIView?
    @IBOutlet var mapDbgFloorLabel: UILabel?
    private var debugLocation: CLLocationCoordinate2D? = nil

    private weak var currentVC: UIViewController?
    private var onsiteOffsiteDetector = OnsiteOffsiteDetector()
    private var haveShownOnsiteWarning = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        onsiteOffsiteDetector.delegate = self
        
        if Environment.shared.currentPlatform == .build {
            mapDebugView?.isHidden = false
        }

        if #available(iOS 13, *) {} else {
            showOffsiteMap()
            if onsiteOffsiteDetector.currentlyInsideMall {
                showiOS13Required()
                haveShownOnsiteWarning = true
            }
            
            return
        }
        
        if onsiteOffsiteDetector.currentlyInsideMall {
            showOnsiteMap()
        } else {
            showOffsiteMap()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func showOffsiteMapTapped(_ sender: UIButton) {
        showOffsiteMap()
    }
    
    @IBAction func showOnsiteMapTapped(_ sender: UIButton) {
        showOnsiteMap()
    }
    
    private func showOffsiteMap() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        showChildFromStoryboard(name: "OffSiteMap")
    }
    
    private func showOnsiteMap() {
        if #available(iOS 13, *) {} else {
            if !haveShownOnsiteWarning {
                showiOS13Required()
            }
            haveShownOnsiteWarning = true
            return
        }
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        showChildFromStoryboard(name: "OnSiteMap")
    }
    
    func showChildFromStoryboard(name: String) {
        let sb = UIStoryboard(name: name, bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else {
            print("ERROR: Failed to instantiate VC from SB")
            return
        }
        
        currentVC = vc
                
        navigationController?.popToRootViewController(animated: false)
        navigationController?.pushViewController(vc, animated: false)
        
        if let mapDebugView = mapDebugView {
            mapDebugView.removeFromSuperview()
            navigationController?.view.addSubview(mapDebugView)
        }
        
        if #available(iOS 13.0, *) {
            if let onsiteVC = currentVC as? OnSiteMapViewController {
                onsiteVC.mapDbgFloorLabel = mapDbgFloorLabel
            }
        }

    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            debugLocation = CLLocationCoordinate2D(latitude: 40.809911, longitude: -74.071408)
            showOnsiteMap()
            
            if #available(iOS 13, *) {
                if let onsiteVC = currentVC as? OnSiteMapViewController {
                    onsiteVC.debugSetLocation(newCoordinate: debugLocation, level: 0)
                }
            }
        } else {
            debugLocation = nil
            showOffsiteMap()
        }
    }

    @IBAction func floorEditingChanged(_ sender: UITextField) {
        guard let text = sender.text, let newFloor = Int(text) else {
            return
        }
        
        sender.resignFirstResponder()
        
        print("Floor changed to: \(newFloor)")
        
        if #available(iOS 13, *) {
            
            if let onsiteVC = currentVC as? OnSiteMapViewController {
                onsiteVC.debugSetLocation(newCoordinate: debugLocation, level: newFloor)
            }
        }
    }
    
    @IBAction func dbgPolyChanged(_ sender: UISwitch) {
        if #available(iOS 13, *) {

            guard let onsiteVC = currentVC as? OnSiteMapViewController else {
                return
            }
            
            onsiteVC.debugOnsitePolygon = sender.isOn ? onsiteOffsiteDetector.mapPolygon() : nil
        }
    }
}


extension MapViewController: OnsiteOffsiteDetectorDelegate {
    func deviceIsNow(onsite: Bool, sender: OnsiteOffsiteDetector) {
        if onsite {
            showOnsiteMap()
        } else {
            showOffsiteMap()
        }
    }
}
