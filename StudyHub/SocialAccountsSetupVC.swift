//
//  SocialAccountsSetupVC.swift
//  StudyHub
//
//  Created by Dan Levy on 11/19/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Allows the user to add their social accounts to their profile
 * Accounts include Facebook, Twitter, Instagram, and Snapchat
 * Uploads data to Firebase Firestore
 */

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView

class SocialAccountsSetupVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Variables
    var links = [String: String]()
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var skipBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var facebookLinkTextField: UITextField!
    @IBOutlet weak var twitterLinkTextField: UITextField!
    @IBOutlet weak var instagramLinkTextField: UITextField!
    @IBOutlet weak var vscoLinkTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Actions
    /*
     * Handles the help alert view
     */
    @IBAction func helpBarButtonItemPressed(_ sender: Any) {
        self.help()
    }
    
    /*
     * Skips this vc
     */
    @IBAction func skipBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "socialAccountsSetupVCToSchoolSetupVC", sender: self)
    }
    
    /*
     * Handles the new user data
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.checkLinks()
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpObjects()
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Rounds the corners on the next button
     */
    func setUpObjects() {
        self.nextButton.layer.cornerRadius = 10
        self.nextButton.clipsToBounds = true
    }
    
    // MARK: Help
    /*
     * Shows the user how to find their social account usernames
     */
    func help() {
        let alert = SCLAlertView()
        alert.addButton("Find Facebook Username", action: {
            if (UIApplication.shared.canOpenURL(URL(string: "https://www.facebook.com/username")!) == true) {
                UIApplication.shared.open(URL(string: "https://www.facebook.com/username")!, options: [:], completionHandler: nil)
            }
        })
        alert.addButton("Find Twitter Username", action: {
            self.displayInfo(title: "Twitter Username", message: "Your Twitter username is the name the follows the '@' on your Twitter profile")
        })
        alert.addButton("Find Instagram Username", action: {
            self.displayInfo(title: "Instagram Username", message: "Your Instagram username is the name at the top of your Instagram profile on the Instagram app or next to the 'Edit Profile' button on your Instgram profile page on the Instagram website")
        })
        alert.addButton("Find VSCO Username", action: {
            self.displayInfo(title: "VSCO Username", message: "Your VSCO username is the name above the 'Edit Profile' button on your profile on the VSCO app or to the right of the 'Store' button on the VSCO website (if you are are signed in)")
        })
        alert.showInfo("Help", subTitle: "Select an option below")
    }
    
    // MARK: Add User Data
    /*
     * Dismisses the keyboard
     * Gets rid of whitespace on usernames
     */
    func checkLinks() {
        self.view.endEditing(true)
        let usernames = ["facebook": self.trimString(string: self.facebookLinkTextField.text!), "twitter": self.trimString(string: self.twitterLinkTextField.text!), "instagram": self.trimString(string: self.instagramLinkTextField.text!), "vsco": self.trimString(string: self.vscoLinkTextField.text!)]
        for username in usernames {
            if (self.trimString(string: username.value).count > 0) { // Only adds the username if it's not all whitespace
                self.createLink(username: username.value, socialNetwork: username.key)
            }
        }
        self.uploadLinksToDatabase()
    }
    
    /*
     * Adds the username to the correct link
     * Adds the link to the links dictionary
     */
    func createLink(username: String, socialNetwork: String) {
        self.links[socialNetwork + "Link"] = "https://www.\(socialNetwork).com/\(username)/"
    }
    
    /*
     * Displays an activity view
     * Adds the social account links to the Firebase realtime database
     * Moves user to school setup vc
     */
    func uploadLinksToDatabase() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        firestoreRef.collection("users").document(currentUser!.uid).updateData(self.links) { (error) in
            if let error = error {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                self.displayError(title: "Error", message: error.localizedDescription)
            }
            else {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                self.performSegue(withIdentifier: "socialAccountsSetupVCToSchoolSetupVC", sender: self)
            }
        }
    }
}
