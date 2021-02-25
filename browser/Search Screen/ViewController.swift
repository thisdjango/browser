//
//  ViewController.swift
//  browser
//
//  Created by thisdjango on 25.02.2021.
//  Copyright © 2020 thisdjango. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class ViewController: UIViewController {
    // MARK: - private vars
    private var searchTextField = UISearchBar()
    private var webView = WKWebView()
    private var progressView = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        configureUI()
        commonInit()
    }

    // MARK: - private methods
    private func configureUI() {
        // 0 - toolbar config
        configToolBar()
        // 1 - search text field
        view.addSubview(searchTextField.prepare())
        searchTextField.delegate = self
        searchTextField.text = "https://www.google.com/"
        searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        // 2 - progress bar
        view.addSubview(progressView.prepare())
        progressView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor).isActive = true
        // 3 - web view
        view.addSubview(webView.prepare())
        webView.topAnchor.constraint(equalTo: progressView.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func commonInit() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.load(with: "https://www.google.com/")
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    private func configToolBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.isToolbarHidden = false
        // 4 - tool bar and history
        let back = UIBarButtonItem(image: UIImage(named: "back"),
                                   style: .plain, target: webView,
                                   action: #selector(webView.goBack))
        back.width = 100
        let history = UIBarButtonItem(image: UIImage(named: "history"),
                                      style: .plain, target: self,
                                      action: #selector(showHistory))
        history.width = 100
        let forward = UIBarButtonItem(image: UIImage(named: "next"),
                                      style: .plain, target: webView,
                                      action: #selector(webView.goForward))
        forward.width = 100
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 30
        let items = [ space,
                      back,
                      history,
                      forward,
                      space]

        setToolbarItems(items, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
        progressView.isHidden = !webView.isLoading
    }
    
    @objc func showHistory() {
        let vc = HistoryViewController()
        
        vc.onShowPast = { [weak self] str in
            vc.dismiss(animated: true)
            self?.webView.load(with: str)
        }
        
        navigationController?.present(vc, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        webView.load(with: searchBar.text)
        print("OMG")
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 0
        progressView.isHidden = true
        guard let string = webView.url?.absoluteString else { return }
        save(string: string)
    }
}

extension ViewController: WKUIDelegate {
    
}

extension UIViewController {
    func save(string: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      guard let entity = NSEntityDescription.entity(forEntityName: "Query", in: managedContext) else { return }
      
      let queryString = NSManagedObject(entity: entity, insertInto: managedContext)
      
      queryString.setValue(string, forKeyPath: "url")

      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
}

extension UIView {
    func prepare() -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

extension WKWebView {
    func load(with string: String?) {
        if var str = string {
            str = str.validateUrl() ? str : "https://www.google.com/search?q=\(str.replacingOccurrences(of: " ", with: "+"))"
            if let url = URL(string: str) {
                load(NSURLRequest(url: url) as URLRequest)
            }
        }
    }
}

extension String {
func validateUrl () -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
}
