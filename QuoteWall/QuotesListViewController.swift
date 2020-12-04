//
//  QuotesListViewController.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 11/29/20.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseUI
import GoogleSignIn

class QuotesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
//    var quotes = ["Hey", "Try", "This", "TableView"]
    var quotes: Quotes!
    var authUI: FUIAuth!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        quotes = Quotes()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        quotes.loadData {
            self.tableView.reloadData()
        }
    }
    
    // Be sure to call this from viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowQuote" {
            let destination = segue.destination as! QuoteDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            destination.quote = quotes.quoteArray[selectedIndexPath!.row]
        }
        else if segue.identifier == "PodiumDetail" {
            let destination = segue.destination as! PodiumViewController
            destination.quotes = quotes.quoteArray
        }
        else if segue.identifier == "ProfileDetail" {
            let destination = segue.destination as! ProfileViewController
            destination.quotes = quotes.quoteArray
        }
    }

    // VITAL: This gist includes key changes to make sure "cancel" works with iOS 13.
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }

    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
}

extension QuotesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.quoteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        cell.textLabel?.text = "\(quotes.quoteArray[indexPath.row].person) on \(quotes.quoteArray[indexPath.row].title)"
        return cell
    }
}

extension QuotesListViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
            if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
                return true
            }
            // other URL handling goes here.
            return false
        }
        
        func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
            if let user = user {
                // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
                tableView.isHidden = false
                print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
            }
        }
}
