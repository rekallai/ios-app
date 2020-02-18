//
//  TopLevelItemViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 03/07/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class TopLevelItemViewController: UIViewController {

    var lastHoursFetchDate: Date?
    var timer: Timer?
    var openingClosingTimeLabel: VerticalAlignLabel?
    let hoursViewModel = PropertyHoursViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    override func viewDidLoad() {
        super.viewDidLoad()

        openingClosingTimeLabel = VerticalAlignLabel(frame: CGRect(x: 0, y: 0, width: 130, height: 44))
        openingClosingTimeLabel?.font = UIFont(name: "SFProText-Semibold", size: 13)
        openingClosingTimeLabel?.adjustsFontSizeToFitWidth = true
        openingClosingTimeLabel?.baselineAdjustment = .alignBaselines
        openingClosingTimeLabel?.verticalAlignment = .middle
        openingClosingTimeLabel?.textColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: openingClosingTimeLabel!)
        
        fetchHoursFromApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else { return }
            if strongSelf.lastHoursFetchDate != nil && Date().timeIntervalSince(strongSelf.lastHoursFetchDate!) > 5 * 60 {
                strongSelf.fetchHoursFromApi()
            } else {
                strongSelf.updateOpeningClosingTimeLabel()
            }
        }
        
        updateOpeningClosingTimeLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    private func fetchHoursFromApi(){
        hoursViewModel.onSuccess = { [weak self] in
            self?.lastHoursFetchDate = Date()
            self?.updateOpeningClosingTimeLabel()
        }
        hoursViewModel.fetchHours()
    }
    
    private func updateOpeningClosingTimeLabel() {
        
        if let hoursStr = hoursViewModel.openingHours?.getNextOpeningOrClosingEventTime().uppercased() {
            openingClosingTimeLabel?.text = hoursStr
        } else {
            openingClosingTimeLabel?.text = ""
        }
    }
}
