//
//  StudentInfoDetailsCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell that holds a UIImageView, UITextView, and a UIButton
 * Displays student profile image, name, username, bio, and school name
 */

import UIKit

class StudentInfoDetailsCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var schoolButton: UIButton!
    
    // MARK: Basics
    /*
     * Makes profile image a circle
     * Puts border around image
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageBGView.layer.cornerRadius = self.profileImageBGView.frame.height / 2
        self.profileImageBGView.layer.borderWidth = 2.0
        self.profileImageBGView.layer.borderColor = studyHubBlue.cgColor
        self.profileImageBGView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
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
