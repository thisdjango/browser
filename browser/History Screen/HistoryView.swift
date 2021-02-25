//
//  HistoryView.swift
//  browser
//
//  Created by Diana Tsarkova on 25.02.2021.
//  Copyright © 2021 thisdjango. All rights reserved.
//

import UIKit

class HistoryView: UIView {
    static let rowId = "cell"
    var data: [String?]? {
        didSet {
            tableView.reloadData()
        }
    }
    var onShowPast: ((String?)->Void)? {
        didSet {
            tableView.delegate = self
            tableView.reloadData()
        }
    }
    
    private let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: HistoryView.rowId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HistoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryView.rowId, for: indexPath)
        cell.textLabel?.text = data?[indexPath.row]
        return cell
    }
}


extension HistoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onShowPast?(data?[indexPath.row])
    }
}
