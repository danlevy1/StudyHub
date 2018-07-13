//
//  SettingsTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/17/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    
    // MARK: Variables
    let settings = ["Edit Profile Details", "Edit Profile Images", "Add/Change School", "Change Email", "Change Password", "Contact Support"]

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsSettingCell") as! SettingsSettingCell
        let setting = settings[indexPath.row]
        cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
        self.setUpTextView(textView: cell.textView)
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: setting, color: .white, stringAlignment: .left, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 0))
        cell.textView.attributedText = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            self.performSegue(withIdentifier: "settingsTVCToEditProfileDetailsVCSegue", sender: self)
        } else if (indexPath.row == 1) {
            self.performSegue(withIdentifier: "settingsTVCToEditProfileImagesVCSegue", sender: self)
        } else if (indexPath.row == 2) {
            self.performSegue(withIdentifier: "settingsTVCToAddChangeSchoolVCSegue", sender: self)
        } else if (indexPath.row == 3 || indexPath.row == 4) {
            self.performSegue(withIdentifier: "settingsTVCToChangeEmailPasswordVCSegue", sender: self)
        } else if (indexPath.row == 5) {
            self.performSegue(withIdentifier: "settingsTVCToContactSupportVCSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow!
        if (segue.identifier == "settingsTVCToChangeEmailPasswordVCSegue") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! ChangeEmailPasswordVC
            if (indexPath.row == 3) {
                destVC.change = "Email"
            } else {
                destVC.change = "Password"
            }
        }
    }
}
