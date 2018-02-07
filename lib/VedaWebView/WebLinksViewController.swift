//
//  WebLinksViewController.swift
//  Sipradi
//
//  Created by shishir sapkota on 7/26/17.
//  Copyright © 2017 Ekbana. All rights reserved.
//



import Foundation
import UIKit
import Alamofire

class WebLinksViewController: UIViewController {

    // MARK: Properties

    // MARK: Outlets

    //    @IBOutlet weak var webView: UIWebView!
    //    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var navTitle: String = "More"
    var url: String = ""
    var titleString: String = ""
    // MARK: VC's Life cycle

    var webView: UIWebView?
    var activityIndicator: UIActivityIndicatorView?


    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
        super.viewDidLoad()
        webView = UIWebView(frame: self.view.frame)
        webView?.delegate = self
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator?.center = self.view.center
        self.view.addSubview(webView!)
        self.view.addSubview(activityIndicator!)
    }


    private func setupWebView() {
        self.webView?.delegate = self
    }

    // MARK: IBActions

    override func viewWillAppear(_ animated: Bool) {
        logger(titleString)
        self.navigationItem.title = titleString
        self.openURLInWebView()
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    func openURLInWebView() {
        if NetworkReachabilityManager()?.isReachable == true {
            if let url = URL.init(string: self.url) {
                let request = URLRequest(url: url)
                webView?.loadRequest(request)
            }
        }else {
            self.alert(message: GlobalConstants.Errors.internetConnectionOffline.localizedDescription, title: "")
        }
    }
}


// MARK: UIWebViewDelegate
extension WebLinksViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator?.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator?.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.activityIndicator?.stopAnimating()
        self.alert(message: error.localizedDescription)
    }
}
