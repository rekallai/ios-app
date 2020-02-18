//
//  ArrivalConfirmationViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 19/09/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit


@available(iOS 13, *)
class ArrivalConfirmationViewController: PersistentDrawerContentViewController {

    var route: Route?
    
    @IBOutlet var arrivedAtDestinationLabel: UILabel!
    @IBOutlet var openUntilLabel: UILabel!
    @IBOutlet var topArrivalDetailsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collapsedSize = 110
        expandedSize = 110
        
        if let destinationTitle = route?.destinationTitle {
            arrivedAtDestinationLabel.text = NSLocalizedString("Arrived at \(destinationTitle)",
                comment: "Arrival confirmation text")
        }
        
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] timer in
            self?.performSegue(withIdentifier: "UnwindToDrawerRoot", sender: self)
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topArrivalDetailsView.removeFromSuperview()
        
        guard let sv = view.superview?.superview else {
            return
        }
        
        sv.addSubview(topArrivalDetailsView)
        topArrivalDetailsView.topAnchor.constraint(equalTo: sv.topAnchor).isActive = true
        topArrivalDetailsView.leftAnchor.constraint(equalTo: sv.leftAnchor).isActive = true
        topArrivalDetailsView.rightAnchor.constraint(equalTo: sv.rightAnchor).isActive = true
        sv.layoutIfNeeded()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        topArrivalDetailsView.removeFromSuperview()
    }
}
