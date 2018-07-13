//
//  InstructorInfoLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/5/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell that holds an NCActivityIndicatorView
 * Displays an activity indicator when data is loading
 */

import UIKit
import NVActivityIndicatorView

class InstructorInfoLoadingCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Basics
    /*
     * Starts animating the activity indicator
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
    }

    /*
     *
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
