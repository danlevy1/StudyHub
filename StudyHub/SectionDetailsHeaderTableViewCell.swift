//
//  SectionDetailsHeaderTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class SectionDetailsHeaderTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
