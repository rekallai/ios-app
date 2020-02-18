//
//  StepsViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import CoreLocation

enum OnboardingSteps: Int, CaseIterable {
    case interests
    case location
    case pushNotifications
}

class StepsViewController: UIViewController {
    
    @IBOutlet weak var topButton: FillButton!
    @IBOutlet weak var bottomButton: BorderButton!
    var pageVC: OnboardPageViewController?
    var currentPage = 0
    var pushRequested = false
    var locationRequested = false
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        stateChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stateChange()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        title = NSLocalizedString("Back", comment: "Button title")
    }
    
    @IBAction func topButtonTapped(_ sender: Any) {
        guard let page = OnboardingSteps(rawValue: currentPage) else { return }
        switch page {
        case .interests:
            pageVC?.toNextPage()
        case .location:
            locationRequested ? pageVC?.toNextPage() : requestLocation()
        case .pushNotifications:
            requestPush()
        }
    }
    
    @IBAction func bottomButtonTapped(_ sender: Any) {
        guard let page = OnboardingSteps(rawValue: currentPage) else { return }
        switch page {
        case .interests:
            break
        case .location:
            pageVC?.toNextPage()
        case .pushNotifications:
            performSegue(withIdentifier: "FinishSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OnboardPageSegue" {
            if let vc = segue.destination as? OnboardPageViewController {
                vc.pageDelegate = self
                pageVC = vc
            }
        }
    }
    
    func stateChange() {
        guard let page = OnboardingSteps(rawValue: currentPage) else { return }
        switch page {
        case .interests:
            configInterests()
        case .location:
            configLocation()
        case .pushNotifications:
            configPush()
        }
    }
    
    func requestPush() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            self.pushRequested = true
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "FinishSegue", sender: self)
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

}

extension StepsViewController {
    
    func configInterests() {
        title = NSLocalizedString("Select Your Interests", comment: "Title")
        let buttonTitle = NSLocalizedString("Next Step", comment: "Button title")
        topButton.setTitle(buttonTitle, for: .normal)
        bottomButton.alpha = 0.0
        bottomButton.isEnabled = false
    }
    
    func configLocation() {
        let topTitle = locationRequested ? NSLocalizedString("Next Step", comment: "Title") : NSLocalizedString("Allow Access", comment: "Title")
        let bottomTitle = locationRequested ? "" : NSLocalizedString("Not Now", comment: "Title")
        title = NSLocalizedString("Opt-in", comment: "Title")
        topButton.setTitle(topTitle, for: .normal)
        bottomButton.setTitle(bottomTitle, for: .normal)
        bottomButton.alpha = locationRequested ? 0.0 : 1.0
        bottomButton.isEnabled = !locationRequested
    }
    
    func configPush() {
        let topTitle = pushRequested ? NSLocalizedString("Next Step", comment: "Title") : NSLocalizedString("Allow Push Notifications", comment: "Title")
        let bottomTitle = pushRequested ? "" : NSLocalizedString("Not Now", comment: "Title")
        title = NSLocalizedString("Opt-in", comment: "Title")
        topButton.setTitle(topTitle, for: .normal)
        bottomButton.setTitle(bottomTitle, for: .normal)
        bottomButton.alpha = pushRequested ? 0.0 : 1.0
        bottomButton.isEnabled = !pushRequested
    }
    
}

extension StepsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let section = OnboardingSteps(rawValue: currentPage)
        locationRequested = !(status == .notDetermined)
        if locationRequested && section == .location {
            DispatchQueue.main.async {
                self.pageVC?.toNextPage()
            }
        }
    }
    
}

extension StepsViewController: OnboardPageDelegate {
    
    func changedPage(_ page: Int) {
        currentPage = page
        stateChange()
    }
    
}
