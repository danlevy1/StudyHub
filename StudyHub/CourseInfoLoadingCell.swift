//
//  CourseInfoLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/30/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell that holds an NCActivityIndicatorView
 * Displays an activity indicator when data is loading
 */

import UIKit
import NVActivityIndicatorView

class CourseInfoLoadingCell: UITableViewCell {
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
