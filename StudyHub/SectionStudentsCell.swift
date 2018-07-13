//
//  SectionStudentsCell.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class SectionStudentsCell: UITableViewCell {
    
    // MARK: Variables
    var studentUID = String()
    
    // MARK: Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    //MARK: Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
