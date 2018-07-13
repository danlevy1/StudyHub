//
//  PostInfoPostCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/26/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class PostInfoPostCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var flagButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpImageView()
        self.setUpUserInteraction()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setUpImageView() {
        self.profileImageView.layer.cornerRadius = self.profileTextView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
    }
    
    func setUpUserInteraction() {
        self.profileImageView.isUserInteractionEnabled = true
        self.profileTextView.isUserInteractionEnabled = true
    }
}
