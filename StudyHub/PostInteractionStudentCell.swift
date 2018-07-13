//
//  PostInteractionStudentCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/27/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class PostInteractionStudentCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        self.messageButton.layer.cornerRadius = 10
        self.messageButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
