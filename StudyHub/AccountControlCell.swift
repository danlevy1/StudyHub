//
//  AccountControlCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/13/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class AccountControlCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.segmentedControl.layer.cornerRadius = self.segmentedControl.frame.size.height / 2
        self.segmentedControl.layer.borderWidth = 1.0
        self.segmentedControl.layer.borderColor = studyHubBlue.cgColor
        self.segmentedControl.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
