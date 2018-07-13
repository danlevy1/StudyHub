//
//  StudentInfoSocialCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell with a UIImageView and a UITextView
 * Displays social image and account username
 */

import UIKit

class StudentInfoSocialCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var socialImageView: UIImageView!
    @IBOutlet weak var accountUsernameTextView: UITextView!
    
    // MARK: Basics
    /*
     * Enables custom cell view
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: .white)
    }

    /*
     * 
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
