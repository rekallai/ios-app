//
//  OffSiteMapViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 16/08/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import MapKit

class OffSiteMapViewController: UIViewController {

    @IBOutlet weak var tableView: MapOffsiteTableView!
    let openMapsSheet = OpenMapsSheet()
    let dataSource = OffsiteMapDataSource()
    var selectedRoute: MKRoute?
    let mapImageSegueIdentifier = "MapImageSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = NSLocalizedString("Map", comment: "Title on map screen")
        openMapsSheet.delegate = self
        dataSource.delegate = self
        tableView.delegate = dataSource
        tableView.dataSource = dataSource
        dataSource.loadRoutes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mapImageSegueIdentifier {
            if let vc = segue.destination as? MapImageViewController {
                vc.viewModel = self.dataSource.viewModel
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let mallOverview = tableView?.headerView(forSection: 0) as? MapOffsiteMallOverview {
            mallOverview.setAnimating(on: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let mallOverview = tableView?.headerView(forSection: 0) as? MapOffsiteMallOverview {
            mallOverview.setAnimating(on: true)
        }
    }
}

extension OffSiteMapViewController: OffsiteMapDataSourceDelegate {
    
    func directionTapped(cell: DirectionsCell) {
        if let ip = tableView.indexPath(for: cell) {
            if !dataSource.viewModel.routes.isEmpty {
                selectedRoute = dataSource.viewModel.routes[ip.row]
            }
        }
        present(openMapsSheet.sheet, animated: true, completion: nil)
    }
    
    func settingsTapped() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:])
        }
    }
    
    func routesFinishedLoading(error: String?) {
        tableView.reloadData()
        hideProgress()
        
        // Silently fail, user may not be in a routable location.
        /*if let error = error {
            showError(error: error)
        }*/
    }
    
    func routesStartedLoading() {
        showProgress()
    }
    
    func mapImageTapped(sender: MapOffsiteHeaderView) {
        performSegue(withIdentifier: mapImageSegueIdentifier, sender: self)
    }
    
}

extension OffSiteMapViewController: OpenMapsSheetDelegate {
    
    func openMapsActionTapped(openMapsType: OpenMapsType) {
        if openMapsType == .openMaps {
            var opts:[String:Any] = [:]
            if let mode = selectedRoute?.directionsMode() {
                opts = [MKLaunchOptionsDirectionsModeKey:mode]
            }
            let mapItems = dataSource.viewModel.mapItems()
            MKMapItem.openMaps(with: mapItems, launchOptions: opts)
        }
    }
    
}
