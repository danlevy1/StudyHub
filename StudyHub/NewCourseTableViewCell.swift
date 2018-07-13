//
//  NewCourseTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import TextFieldEffects

class NewCourseTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var courseInfoTextField: HoshiTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
