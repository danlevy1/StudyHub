//
//  TagStudentsInfoCell.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Sets up a table view cell with a UITextView
 */

import UIKit

class TagStudentsInfoCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Basics
    /*
     * Initializes cell
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    /*
     * Ignore
     */
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
