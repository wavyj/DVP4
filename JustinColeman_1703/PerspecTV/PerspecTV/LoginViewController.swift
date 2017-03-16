//
//  ViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, UIWebViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var taglineTextView: UITextView!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var webView: UIWebView!
    var currentUser: User!
    var userLoggedIn: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loginBtn.layer.cornerRadius = 6
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func twitchAuth(){
        
        //Clears cache
        for c in HTTPCookieStorage.shared.cookies!{
            HTTPCookieStorage.shared.deleteCookie(c)
        }
        
        webView = UIWebView(frame: self.view.frame)
        webView.loadRequest(URLRequest(url: URL(string: "https://api.twitch.tv/kraken/oauth2/authorize?force_verify=false&response_type=token&client_id=\(appDelegate.consumerID)&redirect_uri=\(appDelegate.redirectUrl)&scope=user_read+chat_login+user_subscriptions")!))
        self.view.addSubview(webView)
    }
    
    @IBAction func userLoggedOut(for segue: UIStoryboardSegue){
        //Calls Authentication to login user
        loginBtn.isHidden = false
        taglineTextView.isHidden = false
    }
    
    //MARK: - Webview callbacks
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    //MARK: - Methods
    func getUser(){
        downloadandParse(urlString: "https://api.twitch.tv/kraken/user?oauth_token=\(currentUser.authToken)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)", downloadTask: "User")
    }
    
    func save(){
        UserDefaults.standard.set(true, forKey: "LoggedIn")
        UserDefaults.standard.set(currentUser.authToken, forKey: "AuthToken")
        UserDefaults.standard.set(URL(string: "https://api.twitch.tv/kraken/users/\(currentUser.id)?oauth_token=\(currentUser.authToken)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)") , forKey: "UserLink")
    }
    
    func load(){
        userLoggedIn = UserDefaults.standard.bool(forKey: "LoggedIn")
        if userLoggedIn == false {
            loginBtn.isHidden = false
            welcomeView.isHidden = false
            taglineTextView.isHidden = false
        }else{
            currentUser = User(authToken: UserDefaults.standard.integer(forKey: "AuthKey").description)
            if let url = UserDefaults.standard.url(forKey: "UserLink"){
                downloadandParse(urlString: url.absoluteString, downloadTask: "User")
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFollowing" {
            let Tab = segue.destination as! UITabBarViewController
            let nav = Tab.viewControllers?.first as! UINavigationController
            let FVC = nav.viewControllers.first as! FollowingViewController
            FVC.userLoggedIn = true
            FVC.channelsToDownload.append(currentUser.id)
        }else if segue.identifier == "ipadToSplitView"{
            let split = segue.destination as! UISplitViewController
            let nav = split.viewControllers.last as! UINavigationController
            let detailView = nav.viewControllers.first as! DetailViewController
            detailView.currentUser = currentUser
            detailView.segueTo = "ipadToFollowing"
        }
    }
    

}
