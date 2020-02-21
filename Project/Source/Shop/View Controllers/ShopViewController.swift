//
//  ShopViewController.swift
//  Project
//
//  Created by Ray Hunter on 20/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController {

    var shop: Shop?
    
    @IBOutlet var tableView: UITableView?
    
    private var productsViewModel = ProductsViewModel(api: BRApi.shared.api, store: BRApi.shared.store)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.separatorStyle = .none
        tableView?.register(ProductHorizontalCollectionCellSmall.nib,
                            forCellReuseIdentifier: ProductHorizontalCollectionCellSmall.identifier)
        
        if let shopId = shop?.id {
            productsViewModel.shopId = shopId
            productsViewModel.loadProducts()
        }
    }
}

extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductHorizontalCollectionCellSmall.identifier,
                                                       for: indexPath) as? ProductHorizontalCollectionCellSmall else {
                                                        fatalError("Bad cell type")
        }
        
        cell.titleLabel.text = NSLocalizedString("Products", comment: "Section title")
        cell.viewModel = productsViewModel
        return cell
    }
}
