//
//  CourseInfoStudentCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell with a profile UIImageView, profile and bio UITextViews
 * Displays a student's profile image, username, full name, and bio
 */

import UIKit

class CourseInfoStudentCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var optionsButton: UIButton!
    
    // MARK: Basics
    /*
     * Makes the profile UIImageView a circle
     */
    override func awakeFromNib() {
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: .white)
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
    }
    
    /*
     * 
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}


