//
//  Quotes.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 11/29/20.
//

import Foundation
import Firebase

class Quotes {
    var quoteArray: [Quote] = []
    var db: Firestore!

    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ())  {
        db.collection("quotes").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.quoteArray = []
            // there are querySnapshot!.documents.count documents in teh quotes snapshot
            for document in querySnapshot!.documents {
              // You'll have to be sure you've created an initializer in the singular class (Quote, below) that acepts a dictionary.
                let quote = Quote(dictionary: document.data())
                quote.documentID = document.documentID
                self.quoteArray.append(quote)
            }
            completed()
        }
    }
}
