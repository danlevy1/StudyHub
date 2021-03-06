//
//  PostInfoPost3ImgCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class PostInfoPost3ImgCell: UITableViewCell, UITextViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var likesButton: UIButton!
    @IBOutlet weak var taggedStudentsButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        self.profileImageView.isUserInteractionEnabled = true
        self.profileTextView.isUserInteractionEnabled = true
        self.imageView0.clipsToBounds = true
        self.imageView1.clipsToBounds = true
        self.imageView2.clipsToBounds = true
        self.imageView0.layer.cornerRadius = 10
        self.imageView1.layer.cornerRadius = 10
        self.imageView2.layer.cornerRadius = 10
        self.likeButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


