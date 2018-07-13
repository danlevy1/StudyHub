//
//  InstructorInfoRatingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/5/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell that holds five rating star UIImages and a UITextView
 * Displays an activity indicator when data is loading
 */

import UIKit

class InstructorInfoRatingCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     * Calls enableCustomCellView
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
