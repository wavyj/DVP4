//
//  WatchViewController.swift
//  PerspecTV
//
//  Created by Justin Coleman on 3/12/17.
//  Copyright © 2017 Justin Coleman. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class WatchViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate{

    //MARK: - Outlets
    @IBOutlet weak var streamView: UIView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var rightArrow: UIButton!
    @IBOutlet weak var leftArrow: UIButton!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var streamName: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet var swipeGesture: UISwipeGestureRecognizer!
    @IBOutlet weak var hamMenuBtn: UIButton!
    //Ipad Outlets
    @IBOutlet var iPadStreamViews: [UIView]!
    @IBOutlet var iPadActivitySpinners: [UIActivityIndicatorView]!
    
    //MARK: - Variables
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var webView: UIWebView!
    var currentChannel: (type: String, content: Channel)!
    var streams = [(type: String, content: Channel)]()
    var selectedIndex = 0
    var shouldLoad = true
    var chatWebView: UIWebView!
    var isOpened = false
    var isMenuOpen = false
    lazy var ChatVC: ChatViewController = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var viewController = sb.instantiateViewController(withIdentifier: "ChatViewController")as! ChatViewController
        self.addChildAsViewController(viewController)
        return viewController
    }()
    var iPadStreams = [(content: Channel, view: UIView, spinner: UIActivityIndicatorView)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        if appDelegate.isPhone == false{
            self.splitViewController?.preferredDisplayMode = .primaryHidden
//            var frame = chatView.frame
//            frame.size.width = self.splitViewController!.primaryColumnWidth
//            chatView.frame = frame
            
            //iPad Stream View Setup
            var index = 0
            for i in iPadStreamViews{
                iPadStreams.append((content: Channel(), view: i, spinner: iPadActivitySpinners[index]))
                index += 1
            }
            
            //Add a web view to each iPad Stream view
            index = 2
            for i in iPadStreams{
                let webV = UIWebView(frame: i.view.frame)
                i.view.addSubview(webV)
                i.view.clipsToBounds = true
                webV.clipsToBounds = true
                webV.delegate = self
                webV.tag = index
                index += 1
            }
            
        }else{
            var frame = chatView.frame
            frame.size.height = frame.size.height - controlView.frame.height
            ChatVC.view.frame = frame
        }
        ChatVC.view.clipsToBounds = true
        
        //Chat Button setup
        //chatBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chatTapped(_:))))
        swipeGesture.delegate = self
        swipeGesture.addTarget(self, action: #selector(self.chatTapped(_:)))
        self.view.addGestureRecognizer(swipeGesture)
        
        //Stream Webview Setup
        webView = UIWebView(frame: streamView.frame)
        streamView.addSubview(webView)
        streamView.clipsToBounds = true
        webView.clipsToBounds = true
        webView.delegate = self
        webView.tag = 1
        streamName.text = "No Channel Selected"
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
            if appDelegate.isPhone == true{
                if streams.count > 1{
                    rightArrow.isHidden = false
                }
                if selectedIndex == streams.count - 1{
                    rightArrow.isHidden = true
                }
            }else{
                //Load each stream into each ipad stream view
                var index = 0
                for i in streams{
                    iPadStreams[index].content = i.content
                    index += 1
                }
            }
            shouldLoad = true
            if shouldLoad{
                loadStream()
            }
        }
        
        if streams.count == 0{
            if appDelegate.isPhone == true{
                streamView.isHidden = true
            }else{
                for i in iPadStreams{
                    i.view.isHidden = true
                }
            }
            menuBtn.isEnabled = false
            infoBtn.isEnabled = false
            self.view.gestureRecognizers?.first?.isEnabled = false
            streamName.text = "No Channel Selected"
            
        }else{
            if appDelegate.isPhone == true{
                streamName.text = currentChannel.content.username
                streamView.isHidden = false
            }else{
                var streams = ""
                var index = 0
                for i in iPadStreams{
                    if i.content.username != ""{
                        if index > iPadStreams.count - 1{
                        streams += "\(i.content.username),"
                        }else{
                            streams += i.content.username
                        }
                    }
                    index += 1
                }
                streamName.text = "Watching \(streams)"
            }
            menuBtn.isEnabled = true
            infoBtn.isEnabled = true
            self.view.gestureRecognizers?.first?.isEnabled = true
        }
    }
    
    //MARK: - Storyboard Actions
    @IBAction func hamMenuTapped(_ sender: UIButton){
        if isMenuOpen{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .primaryHidden
            }, completion: { (Bool) in
                self.leftArrow.isUserInteractionEnabled = true
                self.rightArrow.isUserInteractionEnabled = true
                self.streamView.isUserInteractionEnabled = true
                self.menuView.isUserInteractionEnabled = true
                self.isMenuOpen = false
            })
        }else{
            UIView.animate(withDuration: 0.5, animations: {
                self.splitViewController?.preferredDisplayMode = .allVisible
            }, completion: { (Bool) in
                self.leftArrow.isUserInteractionEnabled = false
                self.rightArrow.isUserInteractionEnabled = false
                self.streamView.isUserInteractionEnabled = false
                self.menuView.isUserInteractionEnabled = false
                self.isMenuOpen = true
            })
        }
    }
    
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
    
    @IBAction func infoTapped(_ sender: UIButton){
        
    }
    
    @IBAction func chatTapped(_ sender: UIButton){
        if isOpened{
            isOpened = false
            self.view.gestureRecognizers?.first?.isEnabled = true
            chatView.gestureRecognizers?.first?.isEnabled = false
        }else{
            isOpened = true
            self.view.gestureRecognizers?.first?.isEnabled = false
            chatView.gestureRecognizers?.first?.isEnabled = true
        }
        
        if appDelegate.isPhone == true{
            leftArrow.isEnabled = !isOpened
            rightArrow.isEnabled = !isOpened
        }
        updateChatDisplay()
    }
    
    @IBAction func menuTapped(_ sender: UIButton){
        performSegue(withIdentifier: "toMenu", sender: self)
    }
    
    @IBAction func unwindMenu(_ segue: UIStoryboardSegue){
        streams = appDelegate.streams
        if streams.count > 0{
            selectedIndex = 0
            let tempBtn = UIButton()
            tempBtn.tag = 2
            //Calls this method to load streams and index selected index
            btnTapped(tempBtn)
        }
    }
    
    @IBAction func unwindOther(_ segue: UIStoryboardSegue){
        //do nothing
    }

    //MARK: - Webview Callbacks
    func webViewDidFinishLoad(_ webView: UIWebView) {
        switch webView.tag {
        case 1:
            webView.isHidden = false
            webView.frame = streamView.bounds
            activitySpinner.stopAnimating()
            shouldLoad = false
        case 2:
            webView.isHidden = false
            webView.frame = iPadStreams[0].view.bounds
            iPadStreams[0].spinner.stopAnimating()
            shouldLoad = false
        case 3:
            webView.isHidden = false
            webView.frame = iPadStreams[1].view.bounds
            iPadStreams[1].spinner.stopAnimating()
            shouldLoad = false
        case 4:
            webView.isHidden = false
            webView.frame = iPadStreams[2].view.bounds
            iPadStreams[2].spinner.stopAnimating()
            shouldLoad = false
        case 5:
            webView.isHidden = false
            webView.frame = iPadStreams[3].view.bounds
            iPadStreams[3].spinner.stopAnimating()
            shouldLoad = false
        default:
            print("Mistakes were made.")
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked{
            return false
//        if shouldLoad{
//            return true
//        }else{
//            return false
//        }
        }
        return true
    }
    
    //MARK: - Methods
    func loadStream(){
        if appDelegate.isPhone == true{
            //Display Setup
            webView.isHidden = true
            activitySpinner.startAnimating()
            streamName.text = currentChannel.content.username
            
            //Stream Setup
            webView.allowsInlineMediaPlayback = true
            webView.scrollView.isScrollEnabled = false
            
            if currentChannel.type == "stream"{
                let stream = "<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><body><iframe src=\"https://player.twitch.tv/?channel=\(currentChannel.content.username)&autoplay=false&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)&playsinline=1\"width=\"\(streamView.frame.width)\" height=\"\(streamView.frame.height)\" frameborder=\"0\" scrolling=\"yes\" allowfullscreen=\"false\" webkit-playsinline></iframe></body></html>"
                webView.loadHTMLString(stream, baseURL: nil)
                self.view.gestureRecognizers?.first?.isEnabled = true
            }else{
                let stream = "<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><body><iframe src=\"https://player.twitch.tv/?video=\(currentChannel.content.id)&autoplay=false&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)&playsinline=1\"width=\"\(streamView.frame.width)\" height=\"\(streamView.frame.height)\" frameborder=\"0\" scrolling=\"yes\" allowfullscreen=\"false\" webkit-playsinline></iframe></body></html>"
                webView.loadHTMLString(stream, baseURL: nil)
                
                //Disable Chat
                self.view.gestureRecognizers?.first?.isEnabled = false
            }
        }else{
            for i in iPadStreams{
                if i.content.username != ""{
                    i.spinner.startAnimating()
                    if i.content.videoID == ""{
                        //Load Stream
                        let stream = "<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><body><iframe src=\"https://player.twitch.tv/?channel=\(i.content.username)&autoplay=false&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)&playsinline=1\"width=\"\(i.view.frame.width)\" height=\"\(i.view.frame.height)\" frameborder=\"0\" scrolling=\"yes\" allowfullscreen=\"false\" webkit-playsinline></iframe></body></html>"
                        //Find webview and load
                        for v in  i.view.subviews{
                            if v.isKind(of: UIWebView.self){
                                (v as! UIWebView).loadHTMLString(stream, baseURL: nil)
                            }
                        }
                    }else{
                        //Load Video
                        let stream = "<html><head><style type='text/css'>html,body {margin: 0;padding: 0;width: 100%;height: 100%;}</style></head><body><iframe src=\"https://player.twitch.tv/?channel=\(i.content.id)&autoplay=false&client_id=\(appDelegate.consumerID)&\(appDelegate.apiVersion)&playsinline=1\"width=\"\(i.view.frame.width)\" height=\"\(i.view.frame.height)\" frameborder=\"0\" scrolling=\"yes\" allowfullscreen=\"false\" webkit-playsinline></iframe></body></html>"
                        //Find webview and load
                        for v in  i.view.subviews{
                            if v.isKind(of: UIWebView.self){
                                (v as! UIWebView).loadHTMLString(stream, baseURL: nil)
                            }
                        }
                    }
                }
            }
        }
        
        //Chat update
        ChatVC.loadChat()
    }
    
    //MARK: - Container View Controller
    private func addChildAsViewController(_ childController: UIViewController) {
        addChildViewController(childController)
        
        self.view.addSubview(childController.view)
        childController.view.frame = chatView.frame
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.view.isHidden = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.chatTapped(_:)))
        swipeRight.direction = .right
        childController.view.addGestureRecognizer(swipeRight)
        childController.didMove(toParentViewController: self)
    }
    
    private func removeChildViewController(childViewController: UIViewController){
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
    
    func updateChatDisplay(){
        //Animation to open or close chat
        if isOpened{
            ChatVC.view.frame = ChatVC.view.frame.offsetBy(dx: chatView.frame.width, dy: 0)
            UIView.animate(withDuration: 0.7, animations: {
                self.ChatVC.view.frame = self.chatView.frame
                self.ChatVC.view.isHidden = false
            }, completion: { (Bool) in
    
            })
        }else{
            UIView.animate(withDuration: 0.7, animations: {
                var frame = self.chatView.frame
                frame = frame.offsetBy(dx: self.chatView.frame.width, dy: 0)
                self.ChatVC.view.frame = frame
            }, completion: { (Bool) in
                self.ChatVC.view.isHidden = true
                self.ChatVC.view.frame = self.chatView.frame
            
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toProfile"{
            let PVC = segue.destination as! ProfileViewController
            PVC.currentID = currentChannel.content.id
        }
    }
 

}
