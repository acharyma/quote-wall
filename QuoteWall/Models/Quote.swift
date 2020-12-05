//
//  Quote.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 11/29/20.
//

import Foundation
import Firebase

class Quote {
    var title: String
    var quote: String
    var person: String
    var category: String
    var likedBy: [String]
    var dislikedBy: [String]
    var numOfLikes: Int
    var numOfDislikes: Int
    var createdOn: Date
    var postingUserID: String
    var documentID: String
    
    
    var dictionary: [String: Any] {
        //convert date
        let timeIntervalDate = createdOn.timeIntervalSince1970
        
        return ["title": title, "quote": quote, "person": person, "category": category, "likedBy": likedBy, "dislikedBy": dislikedBy, "numOfLikes": numOfLikes, "numOfDislikes": numOfDislikes, "createdOn": timeIntervalDate, "postingUserID": postingUserID, "documentID":documentID]
    }
    
    init(title: String, quote: String, person: String, category: String, likedBy: [String], dislikedBy: [String], numOfLikes: Int, numOfDislikes: Int, createdOn: Date, postingUserID: String, documentID: String) {
        self.title = title
        self.quote = quote
        self.person = person
        self.category = category
        self.likedBy = likedBy
        self.dislikedBy = dislikedBy
        self.numOfLikes = numOfLikes
        self.numOfDislikes = numOfDislikes
        self.createdOn = createdOn
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let quote = dictionary["quote"] as! String? ?? ""
        let person = dictionary["person"] as! String? ?? ""
        let category = dictionary["category"] as! String? ?? ""
        let likedBy = dictionary["likedBy"] as! [String]? ?? []
        let dislikedBy = dictionary["dislikedBy"] as! [String]? ?? []
        let numOfLikes = dictionary["numOfLikes"] as! Int? ?? 0
        let numOfDislikes = dictionary["numOfDislikes"] as! Int? ?? 0
        let timeIntervalDate = dictionary["createdOn"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeIntervalDate)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(title: title, quote: quote, person: person, category: category, likedBy: likedBy, dislikedBy: dislikedBy, numOfLikes: numOfLikes, numOfDislikes: numOfDislikes, createdOn: createdOn, postingUserID: postingUserID, documentID: "")
    }
    
    convenience init() {
        self.init(title: "", quote: "", person: "", category: "", likedBy: [], dislikedBy: [], numOfLikes: 0, numOfDislikes: 0, createdOn: Date(), postingUserID: "", documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        
        // Create the dictionary representing data we want to save
        
        
        var dataToSave: [String: Any] = self.dictionary
        
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            db.collection("quotes").document(self.documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    print("postingUserID is: \(document["postingUserID"])")
                    
                    dataToSave["postingUserID"] = "\(document["postingUserID"]!)"
                } else {
                    print("Document does not exist")
                }
            }
            
            let ref = db.collection("quotes").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            // Grab the user ID
            guard let postingUserID = (Auth.auth().currentUser?.uid) else {
                print("*** ERROR: Could not save data because we don't have a valid postingUserID")
                return completion(false)
            }
            print("first time posting url: \(postingUserID)")
            dataToSave["postingUserID"] = postingUserID
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("quotes").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Quote's documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    
    func deleteData(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("quotes").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting review id \(self.documentID). Error: \(error.localizedDescription)")
                completion(false)
            }
            else {
                print("👍 Successfully deleted document \(self.documentID)")
                completion(true)
            }
        }
    }
    
    
}
