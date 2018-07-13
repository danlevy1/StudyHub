//
//  StudentInfoPost0ImgCell.swift
//  StudyHub
//
//  Created by Dan Levy on 8/4/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class StudentInfoPost0ImgCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileTextView: UITextView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var taggedStudentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.clipsToBounds = true
        self.commentButton.imageView?.contentMode = .scaleAspectFit
        self.likeButton.imageView?.contentMode = .scaleAspectFit
        self.taggedStudentsButton.imageView?.contentMode = .scaleAspectFit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
