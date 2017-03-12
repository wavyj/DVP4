//
//  WatchViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit

class WatchViewController: UITabBarController {

    //MARK: - Outlets
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var streamView: UIView!
    
    //MARK: - Variables
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        let configuaration = WKWebViewConfiguration()
        configuaration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: streamView.frame, configuration: configuaration)
        streamView.clipsToBounds = true
        webView.contentMode = .scaleToFill
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
