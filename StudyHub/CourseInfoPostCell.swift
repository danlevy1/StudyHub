//
//  CourseInfoPostCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/28/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell with a profile UIImageView, user info UITextView, post UITextView, and interactive UIButtons
 * Displays user information (profile image, full name, and username)
 * Displays post details (post text and post images)
 */

import UIKit

class CourseInfoPostCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userInfoTextView: UITextView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var taggedStudentsButton: UIButton!
    
    // MARK: Basics
    /*
     * Makes profile UIImageView a circle
     * Makes button images "scaleAspectFit" -> no stretching of images
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.enableCustomCellView(bgView: self.bgView, bgViewColor: .white)
        // Makes imageView a circle
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
        self.profileImageView.clipsToBounds = true
        // Sets up button images
        self.commentButton.imageView!.contentMode = .scaleAspectFit
        self.likeButton.imageView!.contentMode = .scaleAspectFit
        self.taggedStudentsButton.imageView!.contentMode = .scaleAspectFit
    }

    /*
     * 
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
