//
//  EditProfileDetailsVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/17/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView
import TextFieldEffects

class EditProfileDetailsVC: UIViewController {
    
    // MARK: Variables
    var progressHUD = MBProgressHUD()
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var fullNameTextField: HoshiTextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        self.checkData()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpObjects()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpObjects() {
        self.bioTextView.layer.cornerRadius = 10
        self.bioTextView.clipsToBounds = true
    }
    
    func checkData() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        var values = [String: String]()
        if (self.usernameTextField.text!.count > 0) {
            values["username"] = self.usernameTextField.text!
        }
        if (self.fullNameTextField.text!.count > 0) {
            values["fullName"] = self.fullNameTextField.text!
        }
        if (self.bioTextView.text.count > 0) {
            values["bio"] = self.bioTextView.text!
        }
        self.uploadData(values: values)
    }
    
    func uploadData(values: [String: String]) {
        databaseReference.child("users").child(thisUser!.uid!).child("userDetails").updateChildValues(values) { (error, ref) in
            if let error = error {
                self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView!)
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.success()
            }
        }
    }
    
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView!)
        self.displayBanner(title: "Success!", subtitle: "Your profile has been updated", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
