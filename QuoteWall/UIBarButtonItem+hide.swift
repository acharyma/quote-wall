//
//  UIBarButtonItem+hide.swift
//  QuoteWall
//
//  Created by Manogya Acharya on 12/3/20.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
