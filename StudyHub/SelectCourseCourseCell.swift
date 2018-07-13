//
//  SelectCourseCourseCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Sets up a table view cell with a custom bg view and a text view
 */

import UIKit

class SelectCourseCourseCell: UITableViewCell {
    
    // MARK: Variables
    var courseUID = String()
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     * Creates a custom cell view
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: studyHubBlue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
