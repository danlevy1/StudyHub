//
//  TableViewCellExtension.swift
//  StudyHub
//
//  Created by Dan Levy on 1/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func enableCustomCellView(bgView: UIView, bgViewColor: UIColor) {
        bgView.backgroundColor = bgViewColor
        bgView.layer.cornerRadius = 5
//        bgView.clipsToBounds = false
        bgView.layer.shadowColor = UIColor.gray.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bgView.layer.shadowOpacity = 1.0
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
        textView.backgroundColor = UIColor.clear
    }
}
