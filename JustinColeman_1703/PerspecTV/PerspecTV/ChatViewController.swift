//
//  ChatViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/15/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit

class ChatViewController: UIViewController, UIWebViewDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var chatView: UIView!
    
    //MARK: - Variables
    var currentChannel: Channel!
    var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Setup
        channelName.text = currentChannel.username
        webView = UIWebView(frame: chatView.frame)
        webView.delegate = self
        webView.allowsInlineMediaPlayback = true
        webView.scrollView.isScrollEnabled = false
        webView.keyboardDisplayRequiresUserAction = true
        webView.loadHTMLString("<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><iframe frameborder=\"0\"scrolling=\"yes\"id=\"\(currentChannel.username)\"src=\"https://twitch.tv/\(currentChannel.username)/chat\"height=\"\(chatView.frame.height)\"width=\"\(chatView.frame.width)\" webkit-playsinline></iframe>", baseURL: nil)
        chatView.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - WebView Callbacks
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = chatView.bounds
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
