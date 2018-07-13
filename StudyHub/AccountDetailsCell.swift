//
//  AccountDetailsCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/13/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class AccountDetailsCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageBGView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerImageView.isUserInteractionEnabled = false
        self.headerImageView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
