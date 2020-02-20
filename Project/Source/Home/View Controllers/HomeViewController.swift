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
    var profileButtonManager: ProfileButtonManager?
    
    let restaurantsViewModel = ShopViewModel(api: BRApi.shared.api, store: BRApi.shared.store)
    let shopsViewModel = ShopViewModel(api: BRApi.shared.api, store: BRApi.shared.store)
    let attractionsViewModel = ShopViewModel(api: BRApi.shared.api, store: BRApi.shared.store)

    enum HomeSections: Int, CaseIterable {
        case shops
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navBar = navigationController?.navigationBar {
            profileButtonManager = ProfileButtonManager(navBar: navBar)
            profileButtonManager?.delegate = self
        }
        
        tableView?.separatorStyle = .none
        tableView?.register(HomeHorizontalCollectionCellLarge.nib,
                            forCellReuseIdentifier: HomeHorizontalCollectionCellLarge.identifier)
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
        case .shops:
            let cell = largeCollectionScroller(in: tableView, for: indexPath)
            cell.titleLabel.text = NSLocalizedString("Shopping", comment: "Section title")
            cell.viewModel = shopsViewModel
            cell.separatorView.isHidden = false
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
    
    func userTapped(dataItem: Shop, sender: UITableViewCell) {
        print("User tapped shop")
    }
}


extension HomeViewController: ProfileButtonDelegate {
    
    func profileButtonTapped() {
        if let vc = UIStoryboard.preAuth(), let preAuthVC = vc.viewControllers.first as? PreAuthViewController {
            preAuthVC.signUpFlow = false
            present(vc, animated: true, completion:nil)
        }
    }
}


// Protocol extension implementaion for purchased tickets
extension HomeViewController: TableViewCoreDataItemUpdate {}

