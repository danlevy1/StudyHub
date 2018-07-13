//
//  ConnectToSocialAccountSetupViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/19/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import ReachabilitySwift

class ConnectToSocialAccountSetupViewController: UIViewController, UITextFieldDelegate {

    // MARK: Variables
    var links = [String: String]()
    var progressHUD = MBProgressHUD()
    var currentTextField = UITextField()
    var nextButtonPressed = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var helpBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var skipBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var facebookLinkTextField: UITextField!
    @IBOutlet weak var twitterLinkTextField: UITextField!
    @IBOutlet weak var instagramLinkTextField: UITextField!
    @IBOutlet weak var vscoLinkTextField: UITextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var nextBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func helpBarButtonItemPressed(_ sender: Any) {
        self.help()
    }
    
    @IBAction func skipBarButtonItemPressed(_ sender: Any) { // Brings user to Add School VC without entering any social links
        self.performSegue(withIdentifier: "successfulAddSocialConnectionsSegue", sender: self)
    }
    
    @IBAction func nextBarButtonItemPressed(_ sender: Any) { // Adds the social connections
        self.nextButtonPressed = true
        self.view.endEditing(true)
        if (self.getSocialNetwork() == true) {
           self.uploadLinksToDatabase()
        }
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpKeyboardExtension()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpKeyboardExtension() {
        self.keyboardToolbar.removeFromSuperview()
        self.facebookLinkTextField.inputAccessoryView = self.keyboardToolbar
        self.twitterLinkTextField.inputAccessoryView = self.keyboardToolbar
        self.instagramLinkTextField.inputAccessoryView = self.keyboardToolbar
        self.vscoLinkTextField.inputAccessoryView = self.keyboardToolbar
    }
    
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
    
    func getSocialNetwork() -> Bool {
        let endIndex = currentTextField.placeholder!.index(currentTextField.placeholder!.endIndex, offsetBy: -9)
        let socialNetwork = currentTextField.placeholder!.substring(to: endIndex)
        if(self.trimUsername(textField: currentTextField, socialNetwork: socialNetwork) == true) {
            return true
        } else {
            return false
        }
        
    }
    
    func trimUsername(textField: UITextField, socialNetwork: String) -> Bool {
        let trimmedUsername = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces).lowercased()
        textField.text = trimmedUsername
        if (trimmedUsername.characters.count > 0) {
            self.createLink(username: trimmedUsername, socialNetwork: socialNetwork)
            return true
        } else {
            self.view.endEditing(true)
            self.displayError(title: "Error", message: "Invalid username for \(socialNetwork)")
            return false
        }
    }
    
    func createLink(username: String, socialNetwork: String) {
        if (socialNetwork == "Facebook") {
            self.links["facebookLink"] = "https://www.facebook.com/\(username)/"
        } else if (socialNetwork == "Twitter") {
            self.links["twitterLink"] = "https://www.twitter.com/\(username)/"
        } else if (socialNetwork == "Instagram") {
            self.links["instagramLink"] = "https://www.instagram.com/\(username)/"
        } else {
            self.links["vscoLink"] = "https://www.vsco.com/\(username)/"
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.nextButtonPressed == false) {
            if (textField.text!.characters.count > 0) {
                let _ = self.getSocialNetwork()
            } else {
                self.nextButtonPressed = false
            }
        }
        
    }

    func uploadLinksToDatabase() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else {
            self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            self.progressHUD.label.text = "Loading"
            databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(self.links, withCompletionBlock: { (error, ref) in
                if let error = error {
                    self.progressHUD.hide(animated: true)
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    self.progressHUD.hide(animated: true)
                    self.performSegue(withIdentifier: "successfulAddSocialConnectionsSegue", sender: self)
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successfulAddSocialConnectionsSegue" {
            let addSchoolVC = segue.destination as! AddSchoolTableViewController
            addSchoolVC.fromVC = "signUp"
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
