//
//  PodiumViewController.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 12/4/20.
//

import UIKit

class PodiumViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var quotes: [Quote]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        
        if quotes == nil {
            quotes = [Quote()]
        }
        
        quotes.sort(by: { $0.numOfLikes > $1.numOfLikes })
    }
}

extension PodiumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodiumCell", for: indexPath) as! PodiumTableViewCell
        cell.quote = quotes[indexPath.row]
        cell.updateTitleLabel = indexPath.row + 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
