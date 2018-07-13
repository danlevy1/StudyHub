//
//  SelectInstructorInstructorCell.swift
//  StudyHub
//
//  Created by Dan Levy on 6/30/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class SelectInstructorInstructorCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: studyHubBlue)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
