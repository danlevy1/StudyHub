//
//  NewSchoolViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/2/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import TextFieldEffects
import ReachabilitySwift

class NewSchoolViewController: UIViewController {
    // MARK: Variables
    var fromVC = String()
    var progressHUD = MBProgressHUD()
    var dataUploaded = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var schoolNameTextField: HoshiTextField!
    @IBOutlet weak var schoolLocationTextField: HoshiTextField!
    @IBOutlet weak var findCountryCodeButton: UIButton!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var keyboardToolbarAddSchoolBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbarBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findCountryCodeButtonPressed(_ sender: Any) {
        if (networkIsReachable == false) {
            self.displayNoNetworkConnection()
        } else {
            // TODO: Open URL for country codes
        }
    }
    
    @IBAction func keyboardToolbarAddSchoolBarButtonItemPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.addNewSchool()
    }
    
    @IBAction func bottomToolbarBarButtonItemPressed(_ sender: Any) {
        self.addNewSchool()
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
        
        // Set up Keyboard Extension
        self.keyboardToolbar.removeFromSuperview()
        self.schoolNameTextField.inputAccessoryView = self.keyboardToolbar
        self.schoolLocationTextField.inputAccessoryView = self.keyboardToolbar
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayInfo(title: "IMPORTANT INFO", message: "Be sure to enter your FULL school name, not an abbreviated version. If you are not sure of the full name, ask your school! The school location should be typed in as 'City, State, Country'. Your county's abbreviation should be used.")
    }
    
    func addNewSchool() {
        if (self.checkInfo() == true) {
            self.checkSchoolData()
        }
    }
    
    func checkSchoolData() {
        if (self.schoolNameTextField.text!.characters.count < 1) {
            self.displayError(title: "Error", message: "Please enter the full school name")
        } else if (self.schoolLocationTextField.text!.characters.count < 1) {
            self.displayError(title: "Error", message: "Please enter the location of the school")
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.addButton("Yes", action: {
                self.addSchoolToSchoolsDatabase(addToUsersDatabase: true)
            })
            alert.addButton("No", action: {
                self.addSchoolToSchoolsDatabase(addToUsersDatabase: false)
            })
            alert.showNotice("Notice", subTitle: "Do you attend this school?")
        }
    }
    
    func addSchoolToSchoolsDatabase(addToUsersDatabase: Bool) {
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        databaseReference.child("schools").childByAutoId().updateChildValues(["schoolName": schoolNameTextField.text!, "schoolNameLC": schoolNameTextField.text!.lowercased(), "schoolLocation": schoolLocationTextField.text!]) { (error, ref) in
            if let error = error {
                self.progressHUD.hide(animated: true)
                if (self.fromVC == "signUp") {
                    self.displayError(title: "Error", message: error.localizedDescription + ". You can add this school later in your account.")
                } else {
                    self.displayError(title: "Error", message: error.localizedDescription)
                }
            } else if (addToUsersDatabase == true) {
                if (ref.key.characters.count >= 1) {
                    self.addSchoolToUsersDatabase(schoolUID: ref.key)
                } else {
                    if (self.fromVC == "signUp") {
                        self.displayError(title: "Error", message: "Something went wrong. You can add this school later in your account.")
                    } else {
                        // TODO: Contact support
                        self.displayError(title: "Error", message: "Something went wrong")
                    }
                }
            } else {
                self.success(schoolAddedToUsersDatabase: false)
            }
        }
    }
    
    func addSchoolToUsersDatabase(schoolUID: String) {
        databaseReference.child("users").child(currentUser!.uid).child("userDetails").updateChildValues(["schoolName": self.schoolNameTextField.text!, "schoolUID": schoolUID]) { (error, ref) in
            if let error = error {
                self.progressHUD.hide(animated: true)
                if (self.fromVC == "signUp") {
                    self.displayError(title: "Error", message: error.localizedDescription + ". Try searching for this school later in your account.")
                } else {
                    self.displayError(title: "Error", message: error.localizedDescription + ". Try searching for this school later to add it as your school.")
                }
            } else {
                self.success(schoolAddedToUsersDatabase: true)
            }
        }
    }
    
    func success(schoolAddedToUsersDatabase: Bool) {
        self.progressHUD.hide(animated: true)
        self.dataUploaded = true
        self.displayBanner(title: "Success!", subtitle: "\(self.schoolNameTextField.text!) has been added", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
            if (self.fromVC == "signUp") {
                if (schoolAddedToUsersDatabase == true) {
                    self.performSegue(withIdentifier: "successfulSignUpFromNewSchoolVCSegue", sender: self)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                if (schoolAddedToUsersDatabase == true) {
                    self.dismiss(animated: true, completion: {
                        let destVC = AddSchoolTableViewController()
                        destVC.dismissVC = true
                    })
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
