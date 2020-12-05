//
//  PodiumTableViewCell.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 12/4/20.
//

import UIKit

class PodiumTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quoteLabel: UITextView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    var quote: Quote! {
        didSet {
            titleLabel.text = "\(quote.person) on \(quote.title)"
            quoteLabel.text = quote.quote
            likeCountLabel.text = "\(quote.numOfLikes)"
            categoryLabel.text = quote.category
            dislikeCountLabel.text = "\(quote.numOfDislikes)"
        }
    }
    
    var updateTitleLabel: Int! {
        didSet{
            titleLabel.text = "\(updateTitleLabel!). \(quote.person) on \(quote.title)"
        }
    }
}
