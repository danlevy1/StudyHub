//
//  ConnectToSchoolInfoTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 11/22/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class ConnectToSchoolInfoTableViewCell: UITableViewCell {
    
    // MARK: Variables
    var schoolUID = String()
    
    // MARK: Outlets
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func enableCardTableView() {
        self.backgroundCardView.backgroundColor = UIColor.white
        self.contentView.backgroundColor = studyHubColor
        self.backgroundCardView.layer.cornerRadius = 5.0
        self.backgroundCardView.layer.masksToBounds = false
        self.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundCardView.layer.shadowOpacity = 0.8
    }
    
    func disableCardTableView() {
        self.backgroundCardView.backgroundColor = UIColor.clear
        self.backgroundCardView.layer.cornerRadius = 0.0
        self.backgroundCardView.layer.masksToBounds = false
        
    }

}
