//
//  LogInViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/15/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Fabric
import TwitterKit
import TextFieldEffects
import MBProgressHUD
import SCLAlertView

class LogInViewController: UIViewController {
    
    // MARK: Variables
    var noNetworkConnection = true // TODO: Make this a global variable
    
    // MARK: Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var logInWithFacebookImageView: UIImageView!
    @IBOutlet weak var logInWithTwitterImageView: UIImageView!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var logInWithEmailBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    
    // MARK: Actions
    
    func logInWithFacebook(img: AnyObject) {
        if reachabilityStatus == kNOTREACHABLE {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else {
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            FBSDKLoginManager().logIn(withReadPermissions: ["public_profile"], from: self, handler: { (user, error) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                    spinningActivity.hide(animated: true)
                } else if user != nil {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.logInWithCredential(credential: credential)
                    spinningActivity.hide(animated: true)
                } else {
                    self.displayError(title: "Login Failed", message: "Something went wrong. Please try again.")
                    spinningActivity.hide(animated: true)
                }
            })
        }
    }
    
    func logInWithTwitter(img: AnyObject) {
        if reachabilityStatus == kNOTREACHABLE {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else {
            
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            Twitter.sharedInstance().logIn(completion: { (user, error) in
                if let error = error {
                    self.displayError(title: "Login Failed", message: error.localizedDescription)
                    spinningActivity.hide(animated: true)
                } else if let user = user {
                    let token = user.authToken
                    let secret = user.authTokenSecret
                    let credential = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
                    self.logInWithCredential(credential: credential)
                    spinningActivity.hide(animated: true)
                } else {
                    self.displayError(title: "Login Failed", message: "Something went wrong. Please try again.")
                    spinningActivity.hide(animated: true)
                }
            })
        }
    }
    

    @IBAction func logInWithEmailBarButtonItemPressed(_ sender: Any) {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        if reachabilityStatus == kNOTREACHABLE {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if email!.characters.count < 8 {
            self.displayError(title: "Error", message: "Emails need to be at least 8 characters.")
        } else if password!.characters.count < 8 {
            self.displayError(title: "Error", message: "Passwords need to be at least 8 characters.")
        } else {
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
                if let error = error {
                    self.displayError(title: "Login Failed", message: error.localizedDescription)
                    spinningActivity.hide(animated: true)
                } else if let user = user {
                    spinningActivity.hide(animated: true)
                    self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
                } else {
                    self.displayError(title: "Error", message: "Something went wrong. Please try again.")
                    spinningActivity.hide(animated: true)
                }
            })
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpFromLogInSegue", sender: self)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "forgotPasswordSegue", sender: self)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
       // TODO: Set up privacy policy
    }
    
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) {
        // TODO: Set up privacy policy
    }

    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        
        // Set up Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(LogInViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        // Set up Keyboard Extension
        self.keyboardToolbar.removeFromSuperview()
        self.emailTextField.inputAccessoryView = self.keyboardToolbar
        self.passwordTextField.inputAccessoryView = self.keyboardToolbar
        
        // Set up UITapGestureRecognizer on social sign up images
        self.logInWithFacebookImageView.isUserInteractionEnabled = true
        self.logInWithTwitterImageView.isUserInteractionEnabled = true
        let logInWithFacebookTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logInWithFacebook(img:)))
        let logInWithTwitterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logInWithTwitter(img:)))
        self.logInWithFacebookImageView.addGestureRecognizer(logInWithFacebookTapGestureRecognizer)
        self.logInWithTwitterImageView.addGestureRecognizer(logInWithTwitterTapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logInWithCredential(credential: FIRAuthCredential) {
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                spinningActivity.hide(animated: true)
            } else if user != nil {
                spinningActivity.hide(animated: true)
                self.performSegue(withIdentifier: "successfulLoginSegue", sender: self)
            } else {
                self.displayError(title: "Error", message: "Soemthing went wrong. Please try again")
                spinningActivity.hide(animated: true)
            }
        })
    }
    
    func reachabilityStatusChanged() { // Continously checks the network connection
        if reachabilityStatus == kNOTREACHABLE { // Checks is there is no netork connection
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if reachabilityStatus == kREACHABLEWITHWIFI || reachabilityStatus == kREACHABLEWITHWWAN { // Checks if there is a connection to WiFi or cellular
            if noNetworkConnection == true {
                self.displayNetworkReconnection()
                self.noNetworkConnection = false
            }
        } else {
            // TODO: Send event to Firebase that reachability errored out -> send up reachabilityStatus
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // Dismisses keyboard if user touches outside of text fields
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
