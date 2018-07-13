//
//  SignUpViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/13/16.
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

class SignUpViewController: UIViewController {
    
    // TODO: Make sure user doesn't get stuck in signup flow because of a non-fatal error
    // TODO: Try to move signUpWithEmail auth process into other firebase auth function
    // TODO: Hide keyboardToolbar when an error appears
    // TODO: Make sure all MBProgressHUDs are stopped -> should they be put into a dispatch?
    // TODO: Get Next buttons to work as return button on keyboard for all VCs
    // TODO: Handle Facebook and Twitter Cancel Button
    // TODO: Write an extension that handles all errors from Firebase, Facebook, and Twitter
    
    // MARK: Variables
    var facebookSignup = Bool()
    var twitterSignup = Bool()
    var noNetworkConnection = Bool()
    
    
    // MARK: Outlets
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var signUpWithFacebookImageView: UIImageView!
    @IBOutlet weak var signUpWithTwitterImageView: UIImageView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termsOfServiceButton: UIButton!
    @IBOutlet weak var signUpWithEmailBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func signUpWithEmailBarButtonItemPressed(_ sender: Any) { // User wants to signup using an email and password
        self.view.endEditing(true)
        var accountValues = [String : String]()
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        if reachabilityStatus == kNOTREACHABLE { // Checks if network is reachable
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if email!.characters.count < 8 { // Checks if email was entered correctly
            self.displayError(title: "Invalid Email", message: "Please enter an email in the email field")
            // TODO: Check is email is in right format
        } else if password!.characters.count < 8 { // Checks if password was entered correctly
            self.displayError(title: "Invalid Password", message: "Please enter a password in the password field")
        } else { // Sets up user with Firebase Auth and Firebase Database
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            // Creates user with Firebase Auth
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
                if let error = error { // Checks if Firebase error occured
                    self.displayError(title: "Signup Error", message: "\(error._code): \(error.localizedDescription)")
                    spinningActivity.hide(animated: true)
                } else if let user = user { // Checks if user has been authenticated
                    if let email = user.email { // Checks if user's email is available
                        accountValues["authenticatedWith"] = "Email"
                        accountValues["email"] = email
                        self.addUserToDatabase(accountValues: accountValues) // Sets up user in Firebase Database
                        spinningActivity.hide(animated: true)
                    }
                } else { // If no error and no user exists
                    self.displayError(title: "Signup Error", message: "Something went wrong")
                    spinningActivity.hide(animated: true)
                }
            })
        }
    }
    
    func signUpWithFacebook(img: AnyObject) { // User wants to signup using their Facebook account
        if reachabilityStatus == kNOTREACHABLE { // Checks if network is reachable
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else { // Needs to get user info from Facebook
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            FBSDKLoginManager().logIn(withReadPermissions: nil, from: self) { (result, error) in // Opens up Facebook auth webpage and asks user to authenticate
                if let error = error { // Checks if Facebook error occured
                    self.displayError(title: "Signup Failed", message: "\(error._code): \(error.localizedDescription)")
                    spinningActivity.hide(animated: true)
                } else if result != nil { // Checks that Facebook info was downloaded
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    self.facebookSignup = true // Lets addUserToAuth function know that user is signing up with Facebook, not Twitter
                    self.addUserToAuth(credential: credential, twitterUserID: "") // Adds Facebook user to Firebase Auth
                    spinningActivity.hide(animated: true)
                } else { // If no error and no user exists
                    self.displayError(title: "Signup Failed", message: "Something went wrong. Please try again.")
                }
            }
        }
    }
    
    func signUpWithTwitter(img: AnyObject) { // User wants to signup using their Twitter account
        if reachabilityStatus == kNOTREACHABLE { // Checks if network is reachable
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else { // Needs to get user info from Facebook
            let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
            spinningActivity.label.text = "Loading"
            Twitter.sharedInstance().logIn { (session, error) in
                if let error = error { // Checks if Twitter error occured
                    self.displayError(title: "Error", message: "\(error._code): \(error.localizedDescription)")
                    spinningActivity.hide(animated: true)
                } else if session != nil { // Checks that Twitter info was downloaded
                    let twitterCredential = session?.authToken
                    let twitterSecret = session?.authTokenSecret
                    if let twitterCredential = twitterCredential, let twitterSecret = twitterSecret {
                        let credential = FIRTwitterAuthProvider.credential(withToken: twitterCredential, secret: twitterSecret)
                        self.twitterSignup = true // Lets addUserToAuth function know that user is signing up with Twitter, not Facebook
                        let twitterUserID = session?.userID
                        if let twitterUserID = twitterUserID { // Checks if Twitter userid is available
                            self.addUserToAuth(credential: credential, twitterUserID: twitterUserID) // Adds Twitter user to Firebase Auth
                            spinningActivity.hide(animated: true)
                        } else { // If no userid is available
                            self.displayError(title: "Signup Error", message: "Something went wrong. Please try again.")
                            spinningActivity.hide(animated: true)
                        }
                    } else { // If no Twitter user credentials are available
                        self.displayError(title: "Signup Error", message: "Something went wrong. Please try again.")
                        spinningActivity.hide(animated: true)
                    }
                } else { // If no Twitter user is available
                    self.displayError(title: "Signup Error", message: "Something went wrong. Please try again.")
                    spinningActivity.hide(animated: true)
                }
            }
        }
    }
    
    
    @IBAction func logInBarButtonItemPressed(_ sender: Any) { // Sends user over to log in VC
        self.performSegue(withIdentifier: "logInFromSignUpSegue", sender: self)
    }
    
    @IBAction func privacyPolicyButtonPressed(_ sender: Any) {
        // TODO: Send user to privacy policy (either in-app or website)
    }
    
    @IBAction func termsOfServiceButtonPressed(_ sender: Any) {
        // TODO: Send user to terms of service (either in-app or website)
    }
    @IBAction func emailTextFieldPrimaryActionTriggered(_ sender: Any) { // 'Next' btton pressed on lower-right hand side of keyboard pressed
        self.passwordTextField.becomeFirstResponder() // Moves cursor from email text field down to password text field
    }
    
    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: Any) { // 'Join' btton pressed on lower-right hand side of keyboard pressed
        // TODO: Move signUpWithEmailBarButtonItemPressed code into it's own function so it can be accessed from this action and the other action
    }
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        //        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "System", size: 15)!,  NSForegroundColorAttributeName: UIColor.white]
        
        //        let bottomLineLabelBottomBorder = CALayer()
        //        bottomLineLabelBottomBorder.frame = CGRectMake(0.0, bottomLineLabel.frame.height - 1, bottomLineLabel.frame.width, 1.0)
        //        bottomLineLabelBottomBorder.backgroundColor = UIColor.lightGrayColor().CGColor
        //        bottomLineLabel.borderStyle = UITextBorderStyle.None
        //        bottomLineLabel.layer.addSublayer(bottomLineLabelBottomBorder)
        
        // Set up Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
        // Set up Keyboard Extension
        self.keyboardToolbar.removeFromSuperview()
        self.emailTextField.inputAccessoryView = self.keyboardToolbar
        self.passwordTextField.inputAccessoryView = self.keyboardToolbar
        
        // Set up UITapGestureRecognizer on social sign up images
        self.signUpWithFacebookImageView.isUserInteractionEnabled = true
        self.signUpWithTwitterImageView.isUserInteractionEnabled = true
        let signUpWithFacebookTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signUpWithFacebook(img:)))
        let signUpWithTwitterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(signUpWithTwitter(img:)))
        self.signUpWithFacebookImageView.addGestureRecognizer(signUpWithFacebookTapGestureRecognizer)
        self.signUpWithTwitterImageView.addGestureRecognizer(signUpWithTwitterTapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func facebookGraphRequest() { // Gets additional user data from Facebook
        var accountValues = [String : String]()
        accountValues["authenticatedWith"] = "Facebook" // sets accountValues value for authenticatedWith
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, first_name, last_name"])
        userDetails?.start { (connection, result, error) in // Gets Facebook user's info
            if (connection == nil) {
                // TODO: Handle no connection to Facebook graph
            }
            if error != nil { // Checks if Facebook Graph error occured
                self.addUserToDatabase(accountValues: accountValues)
                self.addUserDetailsToAuth(accountValues: accountValues)
                spinningActivity.hide(animated: true)
            } else if let result = result { // Checks if Facebook Graph data was downloaded
                let email = (result as? [String:Any])?["email"] as? String
                let firstName = (result as? [String:Any])?["first_name"] as? String
                let lastName = (result as? [String:Any])?["last_name"] as? String
                if email != nil && email != "" { // sets accountValues value for email if email is available
                    accountValues["email"] = email
                }
                if firstName != nil && firstName != "" && lastName != nil && lastName != ""{ // sets accountValues value for fullName if firstName and lastName are available
                    accountValues["fullName"] = firstName! + " " + lastName!
                }
                if let userID = (result as? [String:Any])?["id"] as? String { // Checks if Facebook user's profile image is available
                    let profileImageURL = URL(string: "https://graph.facebook.com/\(userID)/picture?type=large")
                    do {
                        let profileImageData = try? Data(contentsOf: profileImageURL!)
                        if profileImageData != nil {
                            accountValues["profileImageURL"] = "\(profileImageURL!)"
                            self.addProfileImageToStorage(accountValues: accountValues)
                            spinningActivity.hide(animated: true)
                        } else {
                            self.addUserToDatabase(accountValues: accountValues)
                            self.addUserDetailsToAuth(accountValues: accountValues)
                            spinningActivity.hide(animated: true)
                        }
                    }
                }
            } else { // If no error and no user exists
                self.addUserToDatabase(accountValues: accountValues)
                self.addUserDetailsToAuth(accountValues: accountValues)
                spinningActivity.hide(animated: true)
            }
        }
    }
    
    func additionalTwitterDetails(twitterUserID: String) { // Gets additional user data from Twitter
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        var accountValues = [String : String]()
        accountValues["authenticatedWith"] = "Twitter" // sets accountValues value for authenticatedWith
        if twitterUserID != "" { // Checks if Twitter user's id is available
            let twitterClient = TWTRAPIClient(userID: twitterUserID)
            twitterClient.loadUser(withID: twitterUserID, completion: { (user, error) in // Gets Twitter user's info
                if error != nil { // Checks if Twitter error occured
                    self.addUserToDatabase(accountValues: accountValues)
                    spinningActivity.hide(animated: true)
                } else if user != nil { // Checks if user is available
                    let username = user?.screenName
                    if let profileImageURL = user?.profileImageLargeURL {  // Checks if user's profile image is available
                        accountValues["profileImageURL"] = profileImageURL
                        self.addProfileImageToStorage(accountValues: accountValues)
                    } else { // If user's profile image isn't available, addProfileImageToStorage function must be bypassed
                        if username != nil && username != "" { // Checks if Twitter user's username is available
                            accountValues["username"] = username!
                            self.addUserToDatabase(accountValues: accountValues)
                        } else { // If Twitter user's username isn't available
                            self.addUserToDatabase(accountValues: accountValues)
                            spinningActivity.hide(animated: true)
                        }
                    }
                } else { // If no error and no Twitter user exists
                    self.addUserToDatabase(accountValues: accountValues)
                    spinningActivity.hide(animated: true)
                }
            })
        } else { // Twitter user if isn't available
            self.addUserToDatabase(accountValues: accountValues)
            spinningActivity.hide(animated: true)
        }
    }
    
    func addUserToAuth(credential: FIRAuthCredential, twitterUserID: String) { // Adds Facebook or Twitter user to Firebase auth
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in // Adds user to Firebase Auth
            if let error = error { // Checks if Firebase error occured
                self.displayError(title: "Signup Error", message: "\(error._code): \(error.localizedDescription)")
                spinningActivity.hide(animated: true)
            } else if user != nil { // Checks if Firebase user is available
                if self.facebookSignup == true { // Checks if user is comming from Facebook
                    self.facebookGraphRequest()
                    spinningActivity.hide(animated: true)
                } else if self.twitterSignup == true { // Checks if user is comming from Twitter
                    self.additionalTwitterDetails(twitterUserID: twitterUserID)
                    spinningActivity.hide(animated: true)
                } else { // If user isn't comming from Facebook or Twitter
                    self.displayError(title: "Signup Error", message: "Something went wrong. Please try again.")
                    spinningActivity.hide(animated: true)
                }
            } else { // If no error and no user exists
                self.displayError(title: "Signup Error", message: "Something went wrong. Please try again.")
                spinningActivity.hide(animated: true)
            }
        })
    }
    
    func addProfileImageToStorage(accountValues : [String : String]) { // Adds user's profile image to Firebase Storage
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        var values = [String : String]()
        values = accountValues
        let profileImageURL = URL(string: accountValues["profileImageURL"]!) // Gets accountValues value 'profileImageURL' before removing the value in the next line
        values.removeValue(forKey: "profileImageURL") // removes accountValues key for profilImageURL because this is a link to the user's profile image in Facebook or Twitter -> key is updated to photoURL after profile image is put into Firebase storage
        do {
            let profileImageData = try? Data(contentsOf: profileImageURL!)
            if profileImageData != nil { // Checks if user's profile image data is available
                let imageRef = storageReference.child("ProfilePictures").child("\(FIRAuth.auth()?.currentUser?.uid)ProfilePicture")
                imageRef.put(profileImageData!, metadata: nil) { (metadata, error) in // Puts user's profile image into Firebase Storage
                    if error != nil { // Checks if Firebase Storage error occured
                        spinningActivity.hide(animated: true)
                    } else if let downloadUrl = metadata?.downloadURL()?.absoluteString { // Checks if there is a download url available from Firebase Storage
                        values["photoURL"] = downloadUrl
                        self.addUserToDatabase(accountValues: values) // Adds user to the Firebase Database
                        self.addUserDetailsToAuth(accountValues: values) // Adds new user data to Firebase Auth
                        spinningActivity.hide(animated: true)
                    } else {
                        spinningActivity.hide(animated: true)
                    }
                }
            }
        }
    }
    
    func addUserToDatabase(accountValues: [String: String]) { // Adds user to Firebase Database
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        if currentUser != nil && CUUID != nil { // Checks if currentUser and currentUserUID (CUUID) is available
            let userRef = databaseReference.child("Users").child(CUUID!)
            if accountValues != [:] {
                var values = accountValues
                values["profilePictureURL"] = values["photoURL"]
                values.removeValue(forKey: "photoURL")
                if values["firstName"] != nil && values["lastName"] != nil { // Goes through values dictionary and removes unneeded values
                    let fullName = "\(values["firstName"]!) \(values["lastName"]!)"
                    values["fullName"] = fullName
                    values["fullNameLC"] = fullName.lowercased()
                    values.removeValue(forKey: "firstName")
                    values.removeValue(forKey: "lastName")
                } else {
                    values.removeValue(forKey: "firstName")
                    values.removeValue(forKey: "lastName")
                }
                userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil { // Checks if Firebase Database error occured
                        self.displayError(title: "Small Problem", message: "We couldn't add your details correctly. They may show up as correct in some areas, but still need to be entered a second time. Please do this in the account tab.")
                        spinningActivity.hide(animated: true)
                    } else { // If no error occured
                        spinningActivity.hide(animated: true)
                        if (accountValues["authenticatedWith"]! == "Email") {
                            self.performSegue(withIdentifier: "successfulEmailSignupSegue", sender: self)
                        } else if (accountValues["authenticatedWith"]! == "Facebook"){
                            self.performSegue(withIdentifier: "successfulSocialNetworkSignupSegue", sender: self)
                        } else if (accountValues["authenticatedWith"]! == "Twitter"){
                            self.performSegue(withIdentifier: "successfulSocialNetworkSignupSegue", sender: self)
                        } else {
                            // TODO: App doen't know which service user used to sign up - handle it
                        }
                        
                    }
                })
            }
        } else { // If currentUser and currentUserUID (CUUID) aren't available
            self.displayError(title: "Small Problem", message: "We couldn't add your details correctly. They may show up as correct in some areas, but still need to be entered a second time. Please do this in the account tab.")
            spinningActivity.hide(animated: true)
        }
    }
    
    func addUserDetailsToAuth(accountValues: [String : String]) { // Adds user data to Firebase Auth
        if currentUser != nil { // Checks us currentUser is available
            let changeRequest = currentUser?.profileChangeRequest()
            if let username = accountValues["username"]  { // Adds user's username if available
                changeRequest?.displayName = username
            }
            if let photoURL = accountValues["photoURL"] { // Adds user's profile image if available
                changeRequest?.photoURL = URL(string: photoURL)
            }
            changeRequest?.commitChanges(completion: { (error) in // Adds user data to Firebase Auth
                if error != nil { // Checks if Firebase Auth error occured
                    self.displayError(title: "Small Problem", message: "We couldn't add your details correctly. They may show up as correct in some areas, but still need to be entered a second time. Please do this in the account tab.")
                }
            })
            if let email = accountValues["email"] { // Checks if user's email is available
                currentUser?.updateEmail(email, completion: { (error) in // Adds user's email to Firebase Auth -> seperate function is needed to add email to Firebase Auth
                    if error != nil { // Checks if Firebase Auth error occured
                        self.displayError(title: "Small Problem", message: "We couldn't add your details correctly. They may show up as correct in some areas, but still need to be entered a second time. Please do this in the account tab.")
                    }
                })
            }
        } else { // If no current user is available
            self.displayError(title: "Small Problem", message: "We couldn't add your details correctly. They may show up as correct in some areas, but still need to be entered a second time. Please do this in the account tab.")
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {// Send data over to SocialNetworkAccountSetupViewController
        if (segue.identifier == "successfulSocialNetworkSignupSegue") { // Checks if the segue is the correct one
            let nav = segue.destination as! UINavigationController
            let socialNetworkAccountSetupVC = nav.topViewController as! SocialNetworkAccountSetupViewController
            if (facebookSignup == true) { // Checks is the user signed up with Facebook
                socialNetworkAccountSetupVC.signupMethod = "Facebook"
            } else if (twitterSignup == true) { // Checks if the user was signed up wiht Twitter
                socialNetworkAccountSetupVC.signupMethod = "Twitter"
            } // Else not needed -> if neither Facebook nor Twitter is true, the case will be handled in SocialNetworkAccountSetupViewController
        }
    }
}
