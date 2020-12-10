//
//  UIBarButtonItem+hide.swift
//  Snacktacular
//
//  Created by Manogya Acharya on 11/13/20.
//

import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
