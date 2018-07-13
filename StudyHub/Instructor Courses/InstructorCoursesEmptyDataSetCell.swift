//
//  InstructorCoursesEmptyDataSetCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/12/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class InstructorCoursesEmptyDataSetCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addACourseButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
