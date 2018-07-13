//
//  CourseInfoInstructorCell.swift
//  StudyHub
//
//  Created by Dan Levy on 6/23/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell with a UITextView and a custom background UIView
 * Displays the instructor's name
 */

import UIKit

class CourseInfoInstructorCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     *
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: .white)
        // Initialization code
    }

    /*
     *
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
