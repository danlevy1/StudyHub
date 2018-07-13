//
//  AccountPost5ImgCell.swift
//  StudyHub
//
//  Created by Dan Levy on 8/8/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class AccountPost5ImgCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var taggedStudentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        self.imageView0.clipsToBounds = true
        self.imageView1.clipsToBounds = true
        self.imageView2.clipsToBounds = true
        self.imageView3.clipsToBounds = true
        self.imageView4.clipsToBounds = true
        self.imageView0.layer.cornerRadius = 10
        self.imageView1.layer.cornerRadius = 10
        self.imageView2.layer.cornerRadius = 10
        self.imageView3.layer.cornerRadius = 10
        self.imageView4.layer.cornerRadius = 10
        self.commentButton.imageView?.contentMode = .scaleAspectFit
        self.likeButton.imageView?.contentMode = .scaleAspectFit
        self.taggedStudentsButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
