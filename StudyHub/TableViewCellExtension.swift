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
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = false
        bgView.layer.shadowColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 3)
        bgView.layer.shadowOpacity = 0.8
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
        textView.backgroundColor = UIColor.clear
    }
}
