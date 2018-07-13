//
//  StudentInfoEmptyDataSetCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/19/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * UITableViewCell with a UIImageView and a UITextView
 * Displays why there are no posts or socail accounts
 */


import UIKit

class StudentInfoEmptyDataSetCell: UITableViewCell {
    // MARK: Outlets
    @IBOutlet weak var largeImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     *
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /*
     *
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
