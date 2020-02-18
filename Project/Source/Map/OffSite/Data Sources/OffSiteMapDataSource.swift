//
//  OffsiteMapDataSource.swift
//  Rekall
//
//  Created by Steve on 8/21/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol OffsiteMapDataSourceDelegate: class {
    func directionTapped(cell: DirectionsCell)
    func settingsTapped()
    func routesStartedLoading()
    func routesFinishedLoading(error: String?)
    func mapImageTapped(sender: MapOffsiteHeaderView)
}

class OffsiteMapDataSource: NSObject {
    weak var delegate: OffsiteMapDataSourceDelegate?
    let viewModel = OffsiteMapViewModel()
    
    override init() {
        super.init()
        viewModel.onUpdateStarted = { [weak self] in
            self?.delegate?.routesStartedLoading()
        }
        viewModel.onUpdateSuccess = { [weak self] in
            self?.delegate?.routesFinishedLoading(error: nil)
        }
        viewModel.onUpdateFailure = { [weak self] err in
            self?.delegate?.routesFinishedLoading(error: err)
        }
        viewModel.onLocationGranted = { [weak self] in
            self?.delegate?.routesStartedLoading()
            self?.viewModel.loadRoutes()
        }
        viewModel.onLocationDenied = { [weak self] in
            self?.delegate?.routesFinishedLoading(error: nil)
        }
    }
    
    func loadRoutes() {
        viewModel.loadRoutes()
    }
    
}

extension OffsiteMapDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 0 } else {
            if viewModel.locationAuthorized() {
                let count = viewModel.routes.count
                return (count > 0) ? count : 1
            } else {
                return 1 //for requesting location
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DirectionsCell.identifier, for: indexPath) as! DirectionsCell
        cell.delegate = self
        
        if viewModel.locationAuthorized() {
            if !viewModel.routes.isEmpty {
                let route = viewModel.routes[indexPath.row]
                cell.titleLabel.text = "\(route.transportName()) (\(route.name))"
                cell.subTitleLabel.text = NSLocalizedString("\(route.miles()) miles", comment: "Label title")
                cell.button.setTitle(NSLocalizedString("Directions", comment: "Button title"), for: .normal)
            } else {
                cell.titleLabel.text = NSLocalizedString("No Directions", comment:"Label title")
                cell.subTitleLabel.text = NSLocalizedString("Open Maps for directions?", comment:"Label title")
                cell.button.setTitle(NSLocalizedString("Maps", comment:"Button title"), for: .normal)
            }
        } else {
            configLocationRequest(cell: cell)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            let offsiteHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: MapOffsiteMallOverview.identifier) as? MapOffsiteMallOverview
            //view?.delegate = self
            return offsiteHeader
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: DirectionsHeaderView.identifier) as? DirectionsHeaderView
            return view
        }
    }
    
    func configLocationRequest(cell:DirectionsCell) {
        cell.titleLabel.text = NSLocalizedString("Allow Location Services?", comment:"Title label")
        if viewModel.locationNotDetermined() {
            cell.subTitleLabel.text = NSLocalizedString("So we can provide you an enhanced \(Environment.shared.projectName) experience!", comment:"Title label")
            cell.button.setTitle(NSLocalizedString("Allow", comment:"Button title"), for: .normal)
        } else {
            cell.subTitleLabel.text = NSLocalizedString("Change your location settings in the system settings app", comment:"Title label")
            cell.button.setTitle(NSLocalizedString("Settings", comment:"Button title"), for: .normal)
        }
    }
    
}

extension OffsiteMapDataSource: DirectionsCellDelegate {
    
    func tappedDirection(cell: DirectionsCell) {
        if viewModel.locationAuthorized() {
            delegate?.directionTapped(cell: cell)
        } else if viewModel.locationNotDetermined() {
            viewModel.requestLocation()
        } else {
            delegate?.settingsTapped()
        }
    }
    
}

extension OffsiteMapDataSource: MapOffsiteHeaderViewDelegate {
    
    func mapImageViewTapped(sender: MapOffsiteHeaderView) {
        delegate?.mapImageTapped(sender: sender)
    }
    
}
