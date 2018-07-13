//
//  StudentDataLoadingTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 1/6/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class StudentDataLoadingTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
