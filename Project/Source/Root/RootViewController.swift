//
//  RootViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 06/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Network

//
//  The root view controller of the whole app
//
class RootViewController: UIViewController {
    
    var networkMonitor: NWPathMonitor?
    var lastStatus: NWPath.Status?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(apiTokenExpired(_:)),
                                               name: Notification.apiTokenExpired,
                                               object: nil)
        networkMonitor = NWPathMonitor()
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            //print("Network status: \(path.status)")
            if path.status == .satisfied && path.status != self?.lastStatus {
                DispatchQueue.main.async {
                    self?.networkNowAvailable()
                }
            }
            
            self?.lastStatus = path.status
        }
        networkMonitor?.start(queue: DispatchQueue.global(qos: .background))
        
        showMainUI()
    }
    
    func showMainUI(){
        reloadData(onlyIfPreviouslyFailed: false)
        showNextChildVC()
    }
    
    @objc func apiTokenExpired(_ notification: Notification){
        showNextChildVC()
    }
    
    func showNextChildVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateInitialViewController() else {
            print("ERROR: Failed to instantiate VC from SB")
            return
        }
        
        removeChildViewControllers()
        addNew(vc:vc)
    }
    
    func removeChildViewControllers() {
        for c in self.children {
            c.willMove(toParent: nil)
            c.view.removeFromSuperview()
            c.removeFromParent()
        }
    }
    
    func addNew(vc:UIViewController) {
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    private func networkNowAvailable() {
        reloadData(onlyIfPreviouslyFailed: true)
    }
    
    func appWillEnterForeground() {
        reloadData(onlyIfPreviouslyFailed: false)
    }
    
    func reloadData(onlyIfPreviouslyFailed: Bool) {
        reloadVenues(onlyIfPreviouslyFailed: onlyIfPreviouslyFailed)
    }
    
    var lastVenueLoadFailed = false
    private let venueVm = ShopViewModel(api: BRApi.shared.api, store: BRApi.shared.store)
    func reloadVenues(onlyIfPreviouslyFailed: Bool) {
        venueVm.onUpdateSuccess = { [weak self] in
            self?.lastVenueLoadFailed = false
            CoreDataContext.shared.shopsUpdated()
            BRPersistentContainer.shared.save()
        }
        
        venueVm.onUpdateFailure = { [weak self] errorStr in
            self?.lastVenueLoadFailed = true
        }
        
        guard onlyIfPreviouslyFailed else {
            if CoreDataContext.shared.shopsNeedUpdated() {
                venueVm.loadVenues()
            }
            return
        }
        
        if lastVenueLoadFailed {
            venueVm.loadVenues()
        }
    }
}
