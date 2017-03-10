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
import Accounts

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
    
    //MARK: Accounts Test
    var accounts = [Any]()
    var accountStore: ACAccountStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        oauth = OAuth2Swift(consumerKey: appDelegate.consumerID, consumerSecret: appDelegate.secret, authorizeUrl: "https://api.twitch.tv/kraken/oauth2/authorize", responseType: "token")
        
        loginBtn.layer.cornerRadius = 6
        
        //MARK: Accounts Test
        accountStore = ACAccountStore()
        let accountType: ACAccountType = accountStore!.accountType(withAccountTypeIdentifier: "IdentifierTwitch")
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted, error) in
            if granted{
                //Access account store and retrieves all accounts with this type
                self.accounts = self.accountStore!.accounts(with: accountType)
                
                //Check if the user has any stored accounts
                if self.accounts.count == 0{
                    self.twitchAuth()
                }else{
                    //Load the account's data
                    let account = self.accounts.first as! ACAccount
                    self.currentUser = User(authToken: account.credential.oauthToken)
                    self.getUser()
                }
            }
            
            if error != nil{
                print(error?.localizedDescription ?? "Mistakes were made")
            }
        }
        
        //load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitchAuth(){
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        let _ = oauth.authorize(withCallbackURL: appDelegate.redirectUrl, scope: "user_read+chat_login+user_subscriptions", state: generateState(withLength: 6), success: { (Credential, response, params) in
            self.currentUser = User(authToken: Credential.oauthToken)
            self.getUser()
        }, failure: nil)
    }
    
    //MARK: - Methods
    func getUser(){
        downloadandParse(urlString: "https://api.twitch.tv/kraken/user?oauth_token=\(currentUser.authToken)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)")
    }
    
    /*func save(){
        UserDefaults.standard.set(true, forKey: "LoggedIn")
        UserDefaults.standard.set(currentUser.authToken, forKey: "AuthToken")
        UserDefaults.standard.set(URL(string: "https://api.twitch.tv/kraken/users/\(currentUser.id)?oauth_token=\(currentUser.authToken)&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)") , forKey: "UserLink")
    }*/
    
    func save(){
        let accountType: ACAccountType = accountStore!.accountType(withAccountTypeIdentifier: "Twitch")
        let account = ACAccount(accountType: accountType)
        account?.credential = ACAccountCredential(oAuthToken: appDelegate.consumerID, tokenSecret: appDelegate.secret)
        account?.username = currentUser.username
        
        accountStore.saveAccount(account) { (Saved, error) in
            if Saved{
                print("Saved Twitch Account")
            }
            
            if error != nil{
                print(error?.localizedDescription ?? "Mistakes were made")
            }
        }
        
    }
    
    func load(){
        userLoggedIn = UserDefaults.standard.bool(forKey: "LoggedIn")
        if userLoggedIn == false {
            loginBtn.isHidden = false
        }
        currentUser = User(authToken: UserDefaults.standard.integer(forKey: "AuthKey").description)
        if let url = UserDefaults.standard.url(forKey: "UserLink"){
            downloadandParse(urlString: url.absoluteString)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFollowing" {
            let Tab = segue.destination as! UITabBarController
            let FVC = Tab.viewControllers?.first as! FollowingViewController
            FVC.userLoggedIn = true
        }
    }
    

}
