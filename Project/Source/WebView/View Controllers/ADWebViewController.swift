//
//  ADWebViewController.swift
//  Rekall
//
//  Created by Ray Hunter on 20/10/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import WebKit

class ADWebViewController: UIViewController {

    var initialUrl: URL?
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let initialUrl = initialUrl {
            let urlRequest = URLRequest(url: initialUrl)
            webView.load(urlRequest)
        }
    }
    


}
