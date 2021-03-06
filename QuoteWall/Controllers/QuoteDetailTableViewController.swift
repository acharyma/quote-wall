//
//  QuoteDetailTableViewController.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 11/29/20.
//

import UIKit
import Firebase

class QuoteDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var saidByTextField: UITextField!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    
    @IBOutlet weak var picker: UIPickerView!
    
    var flag = false
    
    var pickerData: [String] = [String]()
    
    var quote: Quote!
    
    var selectedCategory: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteTextView.delegate = self
        
        if quote == nil {
            quote = Quote()
        }
        self.picker.delegate = self
        self.picker.dataSource = self
        
        pickerData = ["Music", "Movie", "Book", "TV", "Life", "Other"]
        selectedCategory = "Music" //default because if it isn't changed, it will be the first one
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if titleTextField.text?.count == 0 || quoteTextView.text?.count == 0 || saidByTextField.text?.count == 0 {
            saveBarButton.hide()
        }
        else {
            saveBarButton.show()
        }
        
        updateUserInterface()
    }
    
    
    
    
    func changedText() {
        if titleTextField.text?.count == 0 || quoteTextView.text?.count == 0 || saidByTextField.text?.count == 0 {
            saveBarButton.hide()
        }
        else {
            saveBarButton.show()
        }
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
    }

    
    
    func updateUserInterface() {
        var testLike: Bool = false
        var testDislike: Bool = false

        
        titleTextField.text = quote.title
        quoteTextView.text = quote.quote
        saidByTextField.text = quote.person
        totalLikesLabel.text = "Total Likes: \(quote.numOfLikes ?? 0) Total Dislikes: \(quote.numOfDislikes ?? 0)"
        
        print(quote.documentID)
        for index in 0..<quote.likedBy.count {
            if quote.likedBy[index] == Auth.auth().currentUser!.uid {
                testLike = true
            }
        }
        
        for index in 0..<quote.dislikedBy.count {
            if quote.dislikedBy[index] == Auth.auth().currentUser!.uid {
                testDislike = true
            }
        }
        
        if(testLike) {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        else {
            likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        
        if(testDislike) {
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        }
        else {
            dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        }
        
        
        if quote.documentID == "" { //new quote
            addBordersToEditableObjects()
            likeButton.isHidden = true
            dislikeButton.isHidden = true
            deleteButton.hide()
        }
        else {
            if (quote.postingUserID == Auth.auth().currentUser?.uid || quote.postingUserID == "") { //review by current user
                print("quote postingUserID is \(quote.postingUserID) and currentUser is \(Auth.auth().currentUser?.uid)")
                self.navigationItem.leftItemsSupplementBackButton = false
                saveBarButton.title = "Update"
                saveBarButton.show()
                addBordersToEditableObjects()
                likeButton.isHidden = false
                dislikeButton.isHidden = false
            }
            else { //quote posted by different user
                print("quote postingUserID is \(quote.postingUserID) and currentUser is \(Auth.auth().currentUser?.uid)")
                changeFlag()
                saveBarButton.hide()
                cancelBarButton.hide()
                deleteButton.hide()
                
                likeButton.isHidden = false
                dislikeButton.isHidden = false

                titleTextField.isEnabled = false
                titleTextField.borderStyle = .none
                quoteTextView.isEditable = false
                quoteTextView.backgroundColor = .white
                //TODO:- hide the section if possible
                picker.isUserInteractionEnabled = false
                picker.isHidden = true
                saidByTextField.isEnabled = false
                saidByTextField.backgroundColor = .white
                saidByTextField.borderStyle = .none

                titleTextField.backgroundColor = .white
            }
        }
    
    }
    
    func changeFlag() {
        flag = true
    }
    
    func shouldHideSection(section: Int) -> Bool {
        switch section {
        case 3:
            return flag ? true : false

        default:
            return false
        }
    }
    
    func addBordersToEditableObjects() {
        titleTextField.addBorder(width: 0.5, radius: 5.0, color: .black)
        quoteTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
        saidByTextField.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func updateFromUserInterface() {
        quote.title = titleTextField.text!
        quote.quote = quoteTextView.text!
        quote.person = saidByTextField.text!
        quote.category = selectedCategory! ?? "Other" //default to other if weird thing happens with nil
        //Warning says can never be nil, but I tested on the picker didSelectRow and that is an optional returned so here JUST IN CASE
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController() {
        print("leave view controller called")
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        if quote.title.contains(" ") {
            self.oneButtonAlert(title: "Title Error", message: "Please enter only one word for the title!")
            return
        }
        
        
        quote.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        var counter: Int = -1
        if !userHasLiked() {
            quote.numOfLikes += 1
            quote.likedBy.append(Auth.auth().currentUser!.uid)
            
            if(userHasDisliked()) {
                quote.numOfDislikes -= 1
                counter = returnUserIndex(likeOrDislikeList: quote.dislikedBy)
                quote.dislikedBy.remove(at: counter)
            }
            
            quote.saveData { success in
                if success {
                    print("like saved")
                    self.updateUserInterface()
                } else {
                    print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
                }
            }
        }
        else {
            quote.numOfLikes -= 1
            counter = returnUserIndex(likeOrDislikeList: quote.likedBy)
            quote.likedBy.remove(at: counter)
            quote.saveData { success in
                if success {
                    print("like saved")
                    self.updateUserInterface()
                } else {
                    print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
                }
            }
        }
        
    }
    
    
    @IBAction func dislikeButtonPressed(_ sender: UIButton) {
        var counter: Int = -1
        if !userHasDisliked() {
            quote.numOfDislikes += 1
            quote.dislikedBy.append(Auth.auth().currentUser!.uid)
            
            if userHasLiked() {
                quote.numOfLikes -= 1
                counter = returnUserIndex(likeOrDislikeList: quote.likedBy)
                quote.likedBy.remove(at: counter)
            }
            
            quote.saveData { success in
                if success {
                    print("dislike saved")
                    self.updateUserInterface()
                } else {
                    print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
                }
            }
        }
        else {
            quote.numOfDislikes -= 1
            counter = returnUserIndex(likeOrDislikeList: quote.dislikedBy)
            quote.dislikedBy.remove(at: counter)
            quote.saveData { success in
                if success {
                    print("dislike saved")
                    self.updateUserInterface()
                } else {
                    print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
                }
            }
        }
    }
    
    func userHasLiked() -> Bool {
        if(quote.likedBy.contains(Auth.auth().currentUser!.uid)) {
            return true
        }
        else {
            return false
        }
    }
    
    func userHasDisliked() -> Bool {
        if(quote.dislikedBy.contains(Auth.auth().currentUser!.uid)) {
            return true
        }
        else {
            return false
        }
    }
    
    func returnUserIndex(likeOrDislikeList: [String]) -> Int {
        var counter = -1
        for index in 0..<likeOrDislikeList.count {
            if likeOrDislikeList[index] == Auth.auth().currentUser!.uid {
                counter = index
            }
        }
        return counter
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        quote.deleteData { (success) in
            if success {
                print("deleted successfully")
                self.leaveViewController()
            }
            else {
                print("delete unsuccessful")
            }
        }
    }
    @IBAction func titleChanged(_ sender: UITextField) {
        changedText()
    }
    
    
    @IBAction func saidByChanged(_ sender: UITextField) {
        changedText()
    }
    
}

extension QuoteDetailTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        changedText()
    }
}

extension QuoteDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = pickerData[row]
    }
    
    
}

extension QuoteDetailTableViewController {
    // Hide Header(s)
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHideSection(section: section) ? 0.1: super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    //Hide footer
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldHideSection(section: section) ? 0.1 : super.tableView(tableView, heightForFooterInSection: section)
    }

    // Hide rows in hidden sections
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return shouldHideSection(section: indexPath.section) ? 0: super.tableView(tableView, heightForRowAt: indexPath)
    }

    // Hide header text by making clear
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if shouldHideSection(section: section) {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.textColor = UIColor.clear
        }
    }

    // Hide footer text by making clear
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if shouldHideSection(section: section) {
            let footerView = view as! UITableViewHeaderFooterView
            footerView.textLabel!.textColor = UIColor.clear
        }
    }
}
// got help from this wonderful stack overflow user: https://stackoverflow.com/questions/17761878/hide-sections-of-a-static-tableview

