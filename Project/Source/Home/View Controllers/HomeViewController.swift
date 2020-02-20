//
//  FirstViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 04/06/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView?
    var profileButtonManager:ProfileButtonManager?
    
    let restaurantsViewModel = ShopViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let shopsViewModel = ShopViewModel(api: ADApi.shared.api, store: ADApi.shared.store)
    let attractionsViewModel = ShopViewModel(api: ADApi.shared.api, store: ADApi.shared.store)

    enum HomeSections: Int, CaseIterable {
        case attractions
        case shops
        case restaurants
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.separatorStyle = .none
        tableView?.register(HomeHorizontalCollectionCellLarge.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellLarge.identifier)
        tableView?.register(HomeHorizontalCollectionCellSmall.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellSmall.identifier)
    }
                
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileButtonManager?.shouldDisplay(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        profileButtonManager?.shouldDisplay(false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        profileButtonManager?.moveResize()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = HomeSections(rawValue: indexPath.section) else {
            fatalError("Unsupported Home Section")
        }
        
        switch section {
        case .attractions:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Don't Miss Out", comment: "Section title")
            cell.viewModel = attractionsViewModel
            cell.separatorView.isHidden = false
            cell.layoutStyle = .allBigItems
            return cell
        case .restaurants:
            let cell = smallCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Dining", comment: "Section title")
            cell.viewModel = restaurantsViewModel
            cell.seperatorLine.isHidden = true
            return cell
        case .shops:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Shopping", comment: "Section title")
            cell.viewModel = shopsViewModel
            cell.separatorView.isHidden = false
            cell.layoutStyle = .allBigItems
            return cell
        }
    }
}


extension HomeViewController: HomeHorizontalCollectionDelegate {
    
    func largeCollectionScroller(in tableView: UITableView, for indexPath: IndexPath) -> HomeHorizontalCollectionCellLarge {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellLarge.identifier,
                                                       for: indexPath) as? HomeHorizontalCollectionCellLarge else {
                                                        fatalError("Bad cell type")
        }
        
        cell.delegate = self
        return cell
    }
    
    
    func smallCollectionScroller(in tableView: UITableView, for indexPath: IndexPath) -> HomeHorizontalCollectionCellSmall {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeHorizontalCollectionCellSmall.identifier,
                                                       for: indexPath) as? HomeHorizontalCollectionCellSmall else {
                                                        fatalError("Bad cell type")
        }
        
        cell.delegate = self
        return cell
    }
    
    func userTapped(dataItem: Shop, sender: UITableViewCell) {
    }
}


// Protocol extension implementaion for purchased tickets
extension HomeViewController: TableViewCoreDataItemUpdate {}

