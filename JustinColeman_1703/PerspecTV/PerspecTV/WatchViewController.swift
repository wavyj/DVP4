//
//  WatchViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit

class WatchViewController: UIViewController, WKNavigationDelegate{

    //MARK: - Outlets
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var streamView: UIView!
    
    //MARK: - Variables
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
//        let configuration = WKWebViewConfiguration()
//        configuration.allowsInlineMediaPlayback = true
//        webView = WKWebView(frame: streamView.frame, configuration: configuration)
//        streamView.addSubview(webView)
//        streamView.clipsToBounds = true
//        webView.contentMode = .scaleAspectFill
//        webView.clipsToBounds = true
//        webView.navigationDelegate = self
//        
//        //Load Stream
//        webView.scrollView.isScrollEnabled = false
//        let stream = "<html><body><iframe src=\"https://player.twitch.tv/?channel=monstercat&client_id=i6upsqp6ugslfdqk87z7t1ghxpf9dz&api_version=5\"&playsinline=1\" autoplay=\"false\" width=\"\(streamView.frame.size.width)\" height=\"\(streamView.frame.size.height)\" frameborder=\"0\" scrolling=\"no\" allowfullscreen=\"false\"></iframe></body></html>"
//        webView.loadHTMLString(stream, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - WK Navigation Callbacks
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        print("Success")
//        
//    }
    
    /*func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
    }*/
    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        print(error.localizedDescription)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
