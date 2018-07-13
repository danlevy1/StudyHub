//
//  CourseInfoDetailsCell.swift
//  StudyHub
//
//  Created by Dan Levy on 3/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell that holds a UITextView
 * Displays course information (course name and instructor name)
 */

import UIKit

class CourseInfoDetailsCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     *
     */
    override func awakeFromNib() {
        super.awakeFromNib()
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

