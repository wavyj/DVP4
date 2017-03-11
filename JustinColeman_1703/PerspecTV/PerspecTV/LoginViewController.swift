//
//  ViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/8/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import SafariServices
import OAuthSwift

class LoginViewController: UIViewController, UIWebViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var svc: SFSafariViewController!
    var oauth: OAuth2Swift!
    var currentUser: User!
    var userLoggedIn: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        oauth = OAuth2Swift(consumerKey: appDelegate.consumerID, consumerSecret: appDelegate.secret, authorizeUrl: "https://api.twitch.tv/kraken/oauth2/authorize?force_verify=true", responseType: "token")
        
        loginBtn.layer.cornerRadius = 6
        
        load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Storyboard Actions
    @IBAction func twitchAuth(){
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(withCallbackURL: appDelegate.redirectUrl, scope: "user_read+chat_login+user_subscriptions", state: generateState(withLength: 100), success: { (Credential, response, params) in
            self.currentUser = User(authToken: Credential.oauthToken)
            self.getUser()
        }, failure: nil)
    }
    
    @IBAction func userLoggedOut(for segue: UIStoryboardSegue){
        //Calls Authentication to login user
        loginBtn.isHidden = false
        twitchAuth()
    }
    
    //MARK: - Methods
    func getUser(){
        downloadandParse(urlString: "https://api.twitch.tv/kraken/user?oauth_token=\(currentUser.authToken)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
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
        }else{
            currentUser = User(authToken: UserDefaults.standard.integer(forKey: "AuthKey").description)
            if let url = UserDefaults.standard.url(forKey: "UserLink"){
                downloadandParse(urlString: url.absoluteString)
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFollowing" {
            let Tab = segue.destination as! UITabBarViewController
            let FVC = Tab.viewControllers?.first as! FollowingViewController
            FVC.userLoggedIn = true
        }
    }
    

}
