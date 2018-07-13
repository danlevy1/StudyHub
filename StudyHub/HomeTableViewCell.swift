//
//  HomeTableViewCell.swift
//  StudyHub
//
//  Created by Dan Levy on 11/4/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    // MARK: Variables
    var studentObjectId = String()
    
    // MARK: Outlets
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameAndUsernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTypeView: UIView!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet weak var postImage1: UIImageView!
    @IBOutlet weak var postImage2: UIImageView!
    @IBOutlet weak var postImage3: UIImageView!
    @IBOutlet weak var postLikesButton: UIButton!
    @IBOutlet weak var postCommentsButton: UIButton!

    
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
        self.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        self.backgroundCardView.layer.cornerRadius = 10.0
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
