//
//  ConnectToSocialHelpTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 11/19/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class ConnectToSocialHelpTableViewCell: UITableViewCell {
    
    // MARK: Variables
    
    
    // MARK: Outlets
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var socialLogoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    // MARK: Actions
    
    
    // MARK: Functions
    override func awakeFromNib() {
        // Initialization code
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
//    func disableCardTableView() {
//        self.backgroundCardView.backgroundColor = UIColor.clear
//        self.backgroundCardView.layer.cornerRadius = 0.0
//        self.backgroundCardView.layer.masksToBounds = false
//        
//    }
}
