//
//  ConnectToSchoolTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 11/22/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class ConnectToSchoolTableViewCell: UITableViewCell {
    
    // MARK: Variables
    var schoolUID = String
    
    // MARK: Outlets
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    
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
