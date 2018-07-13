//
//  OtherSectionsTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/27/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class OtherSectionsTableViewCell: UITableViewCell {
    
    // MARK: Variables
    var sectionUID = String()
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var sectionNumberAndInstructorNameLabel: UILabel!
    @IBOutlet weak var crnNumberLabel: UILabel!
    @IBOutlet weak var sectionScheduleLabel: UILabel!
    
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
