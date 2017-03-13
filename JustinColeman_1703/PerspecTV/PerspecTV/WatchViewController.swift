//
//  WatchViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit

class WatchViewController: UIViewController, UIWebViewDelegate{

    //MARK: - Outlets
    @IBOutlet weak var streamView: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var streamName: UILabel!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var webView: UIWebView!
    var currentChannel: Channel!
    var streams = [Channel]()
    var selectedIndex = 0
    var shouldLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        //Webview Setup
        webView = UIWebView(frame: streamView.frame)
        streamView.addSubview(webView)
        streamView.clipsToBounds = true
        webView.contentMode = .scaleAspectFit
        webView.clipsToBounds = true
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        streams = appDelegate.streams
        if streams.count >= 1{
            //Load stream
            currentChannel = streams[0]
            if shouldLoad{
                loadStream()
            }
        }
        
        if streams.count > 1{
            rightArrow.isHidden = false
        }
    }
    
    //MARK: - Storyboard Actions
    @IBAction func btnTapped(_ sender: UIButton){
        switch sender.tag {
        case 1:
            //Increases currentInt until it is the last Person in people array
            //If it is the last Person, it goes back to the first Person
            if selectedIndex < streams.count - 1{
                selectedIndex += 1
                leftArrow.isHidden = false
            }
            if selectedIndex == streams.count - 1{
                rightArrow.isHidden = true
            }
            currentChannel = streams[selectedIndex]
        case 2:
            //Decreases currentInt until it is the first Person in the people array
            //If it is the first Person, it goes back to the last Person
            if selectedIndex > 0{
                selectedIndex -= 1
                rightArrow.isHidden = false
            }
            if selectedIndex == 0{
                leftArrow.isHidden = true
            }
            currentChannel = streams[selectedIndex]
        default:
            print("Unknown button accessed.")
        }
        shouldLoad = true
        //Calls method to update labels to the current Person
        loadStream()
    }

    //MARK: - Webview Callbacks
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.isHidden = false
        webView.frame = streamView.bounds
        activitySpinner.stopAnimating()
        shouldLoad = false
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if shouldLoad{
            return true
        }else{
            return false
        }
    }
    
    //MARK: - Methods
    func loadStream(){
        //Display Setup
        webView.isHidden = true
        activitySpinner.startAnimating()
        streamName.text = currentChannel.username
        
        //Stream Setup
        webView.allowsInlineMediaPlayback = true
        webView.scrollView.isScrollEnabled = false
        let stream = "<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><body><iframe src=\"https://player.twitch.tv/?channel=\(currentChannel.username)&autoplay=false&client_id=i6upsqp6ugslfdqk87z7t1ghxpf9dz&api_version=5&playsinline=1\"width=\"\(streamView.frame.width)\" height=\"\(streamView.frame.height)\" frameborder=\"0\" scrolling=\"yes\" allowfullscreen=\"false\" webkit-playsinline></iframe></body></html>"
        webView.loadHTMLString(stream, baseURL: nil)
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
