//
//  PostInteractionLoadingCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/27/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PostInteractionLoadingCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Actions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}