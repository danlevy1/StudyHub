//
//  NewCourseTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import SCLAlertView

class NewCourseTableViewController: UITableViewController {
    
    // MARK: Variables
    var noNetowrkConnection = Bool()

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
