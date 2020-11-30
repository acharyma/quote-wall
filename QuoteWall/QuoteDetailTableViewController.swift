//
//  QuoteDetailTableViewController.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 11/29/20.
//

import UIKit

class QuoteDetailTableViewController: UITableViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var saidByTextField: UITextField!
    
    var quote: Quote!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if quote == nil {
            quote = Quote()
        }
        updateUserInterface()
        
    }
    
    func updateUserInterface() {
        titleTextField.text = quote.title
        quoteTextView.text = quote.quote
        saidByTextField.text = quote.person
    }
    
    func updateFromUserInterface() {
        quote.title = titleTextField.text!
        quote.quote = quoteTextView.text!
        quote.person = saidByTextField.text!
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        //TODO:- save item to Firestore
        updateFromUserInterface()
        
        quote.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
        
    }
}
