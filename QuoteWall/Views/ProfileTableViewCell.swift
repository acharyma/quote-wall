//
//  ProfileTableViewCell.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 12/4/20.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    
    
    var quote: Quote! {
        didSet {
            textView.text = "\(quote.quote) - \(quote.person)"
        }
    }

}
