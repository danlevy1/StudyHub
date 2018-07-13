//
//  SectionInfoLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/30/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SectionInfoLoadingCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
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
