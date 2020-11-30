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
    var likedBy: [String]
    var numOfLikes: Int
    var createdOn: Date
    var postingUserID: String
    var documentID: String
    //TODO:- ADD DROPDOWN FOR CATEGORIES!!
    
    var dictionary: [String: Any] {
        //convert date
        let timeIntervalDate = createdOn.timeIntervalSince1970
        
        return ["title": title, "quote": quote, "person": person, "likedBy": likedBy, "numOfLikes": numOfLikes, "createdOn": timeIntervalDate, "postingUserID": postingUserID, "documentID":documentID]
    }
    
    init(title: String, quote: String, person: String, likedBy: [String], numOfLikes: Int, createdOn: Date, postingUserID: String, documentID: String) {
        self.title = title
        self.quote = quote
        self.person = person
        self.likedBy = likedBy
        self.numOfLikes = numOfLikes
        self.createdOn = createdOn
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let quote = dictionary["quote"] as! String? ?? ""
        let person = dictionary["person"] as! String? ?? ""
        let likedBy = dictionary["likedBy"] as! [String] ?? []
        let numOfLikes = dictionary["numOfLikes"] as! Int? ?? 0
        let timeIntervalDate = dictionary["createdOn"] as! TimeInterval? ?? TimeInterval()
        let createdOn = Date(timeIntervalSince1970: timeIntervalDate)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(title: title, quote: quote, person: person, likedBy: likedBy, numOfLikes: numOfLikes, createdOn: createdOn, postingUserID: postingUserID, documentID: "")
    }
    
    convenience init() {
        self.init(title: "", quote: "", person: "", likedBy: [], numOfLikes: 0, createdOn: Date(), postingUserID: "", documentID: "")
    }
    
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
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
    
    
}
