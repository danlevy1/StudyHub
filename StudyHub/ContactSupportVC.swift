//
//  ContactSupportVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/21/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView
import TextFieldEffects

class ContactSupportVC: UIViewController, UITextViewDelegate {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var subjectTextField: HoshiTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    // MARK: Actions
    @IBAction func sendBarButtonItemPressed(_ sender: Any) {
        self.checkData()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTextView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTextView() {
        self.descriptionTextView.layer.cornerRadius = 10
        self.descriptionTextView.clipsToBounds = true
        self.characterCountLabel.text = "500"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = 500 - textView.text.count
        if (count < 0) {
            self.characterCountLabel.textColor = .red
        } else {
            self.characterCountLabel.textColor = .white
        }
        self.characterCountLabel.text = String(count)
    }
    
    func checkData() {
        let subject = self.trimString(string: self.subjectTextField.text!)
        let description = self.trimString(string: self.descriptionTextView.text!)
        if (subject.count < 1) {
            self.displayError(title: "Error", message: "Please enter a subject in the subject field")
        } else if (description.count < 1) {
            self.displayError(title: "Error", message: "Please enter a description in the description field")
        } else {
            let values = ["subject": subject, "description": description, "isOpen": "true"]
            self.sendRequest(values: values)
        }
    }
    
    func sendRequest(values: [String: String]) {
        if (self.checkInfo() == true) {
            databaseReference.child("support").child("requests").childByAutoId().updateChildValues(values) { (error, ref) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    self.addRequestToUser(requestUID: ref.key, values: values)
                }
            }
        }
    }
    
    func addRequestToUser(requestUID: String, values: [String: String]) {
        if (thisUser!.uid != nil && requestUID.count > 0) {
            databaseReference.child("users").child(thisUser!.uid!).child(requestUID).updateChildValues(values) { (error, ref) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    self.displayBanner(title: "Success!", subtitle: "Your reuqest has been sent", style: .success)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
}
