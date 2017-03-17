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
    @IBOutlet weak var chatSpinner: UIActivityIndicatorView!
    
    //MARK: - Variables
    var currentChannel: Channel!
    var webView: UIWebView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Setup
        webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        webView.delegate = self
        webView.clipsToBounds = true
        webView.isHidden = true
        chatSpinner.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func backTapped(_ sender: UIButton){
        if appDelegate.isPhone == true{
            performSegue(withIdentifier: "goBack", sender: self)
        }else{
            performSegue(withIdentifier: "toDetail", sender: self)
        }
    }
    
    //MARK: - WebView Callbacks
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.frame = (self.parent as! WatchViewController).chatView.bounds
        webView.isHidden = false
        chatSpinner.stopAnimating()
    }
    
    //MARK: - Methods
    func loadChat(){
        let parent = self.parent as! WatchViewController
        currentChannel = parent.currentChannel
        webView.scrollView.isScrollEnabled = false
        webView.keyboardDisplayRequiresUserAction = true
        if appDelegate.isPhone == true{
            webView.loadHTMLString("<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><iframe frameborder=\"0\"scrolling=\"yes\"id=\"\(currentChannel.username)\"src=\"https://twitch.tv/\(currentChannel.username)/chat\"width=\"\(parent.chatView.frame.width)\"height=\"\(self.view.frame.height)\"></iframe>", baseURL: nil)
        }else{
            webView.loadHTMLString("<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><iframe frameborder=\"0\"scrolling=\"yes\"id=\"\(currentChannel.username)\"src=\"https://twitch.tv/\(currentChannel.username)/chat\"width=\"\(parent.chatView.frame.width)\"height=\"\(parent.chatView.frame.height)\"></iframe>", baseURL: nil)
        }
    }

    
    /*// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }*/
 

}
