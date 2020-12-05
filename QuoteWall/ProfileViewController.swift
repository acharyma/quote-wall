//
//  ProfileViewController.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 12/4/20.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var quotes: [Quote]!
    var likedQuotes: [Quote]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        if quotes == nil {
            quotes = [Quote()]
        }
        
        quotes.sort(by: { $0.createdOn > $1.createdOn })
        
        for quote in quotes {
            if quote.likedBy.contains(Auth.auth().currentUser!.uid) {
                likedQuotes.append(quote)
            }
        }

        // Do any additional setup after loading the view.
    }
    
    
    

}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedQuotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
        cell.quote = likedQuotes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
