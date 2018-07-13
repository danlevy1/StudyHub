//
//  CourseInformationTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/27/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class CourseInformationTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var courseNameAndIDLabel: UILabel!
    @IBOutlet weak var courseInfoTextView: UITextView!
    
    
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
