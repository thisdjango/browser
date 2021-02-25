//
//  HistoryViewController.swift
//  browser
//
//  Created by Diana Tsarkova on 25.02.2021.
//  Copyright © 2021 thisdjango. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {

    var data: [NSManagedObject]? {
        didSet {
            historyView.data = data?.map({ $0.value(forKeyPath: "url") as? String })
        }
    }
    var onShowPast: ((String?)->Void)? {
        didSet {
            historyView.onShowPast = onShowPast
        }
    }

    private let historyView = HistoryView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
        configureUI()
    }
    
    private func commonInit() {
        fetch()
    }
    
    private func configureUI() {
        view.addSubview(historyView)
        historyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            historyView.topAnchor.constraint(equalTo: view.topAnchor),
            historyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            historyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            historyView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Core Data Fetch
extension HistoryViewController {
    func fetch() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Query")
        do {
            data = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
