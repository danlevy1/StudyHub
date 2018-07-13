//
//  SectionOverviewTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 3/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class SectionOverviewTableViewCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var sectionOverviewTextView: UITextView!
    
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