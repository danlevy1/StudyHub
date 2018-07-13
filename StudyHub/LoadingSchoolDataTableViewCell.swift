//
//  LoadingSchoolDataTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 1/1/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class LoadingSchoolDataTableViewCell: UITableViewCell {
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
