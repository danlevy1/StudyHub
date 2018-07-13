//
//  TagStudentsLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Sets up a table view cell with an activity indicator
 */

import UIKit
import NVActivityIndicatorView

class TagStudentsLoadingCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Basics
    /*
     * Initializes cell
     * Starts animating the activity indicator
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
    }

    /*
     * Ignore
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
