//
//  SelectInstructorLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 6/30/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SelectInstructorLoadingCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
