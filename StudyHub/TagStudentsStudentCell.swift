//
//  TagStudentsStudentCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Sets up a table view cell with a custom bg UIView, UIImageView and a UITextView
 */

import UIKit

class TagStudentsStudentCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var studentProfileImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     * Initializes cell
     * Makes the profile UIImageView a circle
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.studentProfileImageView.layer.cornerRadius = self.studentProfileImageView.frame.size.height / 2
        self.studentProfileImageView.clipsToBounds = true
    }

    /*
     * Ignore
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
