//
//  ForgotPasswordViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/15/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import SCLAlertView
import MBProgressHUD
import ReachabilitySwift

class ForgotPasswordViewController: UIViewController {
    
    // MARK: Variables
    var noNetworkConnection = Bool()
    var emailText = String()
    var progressHUD = MBProgressHUD()
    var requestSent = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var instructionsLabel: UITextView!
    @IBOutlet weak var lineViewUnderInstructionsLabel: UIView!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var didntReceiveEmailButton: UIButton!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var resetPasswordBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didntReceiveEmailButtonPressed(_ sender: Any) {
       self.displayInfo(title: "Help!", message: "Allow up to 10 minutes to receive an email. If no email is received, check your spam and trash.")
        // TODO: Add a "I still need help" button
    }
    
    @IBAction func resetPasswordBarButtonItemPressed(_ sender: Any) {
        self.sendPasswordReset()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
        
        // Set up Keyboard Extension
        self.keyboardToolbar.removeFromSuperview()
        self.emailTextField.inputAccessoryView = self.keyboardToolbar
        
        // Hide button
        self.didntReceiveEmailButton.isHidden = true
        
        // Set up email text field
        if (self.emailText.characters.count >= 1) {
            self.emailTextField.text = self.emailText
        }
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
    }
    
    func sendPasswordReset() {
        self.checkUserDetails {
            let email = self.emailTextField.text
            if (email!.characters.count < 1) {
                self.displayError(title: "Error", message: "Please enter your email in the email field")
            } else {
                self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                self.progressHUD.label.text = "Loading"
                Auth.auth().sendPasswordReset(withEmail: email!, completion: { (error) in
                    if let error = error {
                        self.displayError(title: "Error", message: error.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.displayInfo(title: "Success!", message: "Please check your email - allow up to ten minutes.")
                        }
                        self.didntReceiveEmailButton.isHidden = false
                    }
                    self.progressHUD.hide(animated: true)
                })
            }
            self.requestSent = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
