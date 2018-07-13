//
//  AddASchoolViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/26/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import TextFieldEffects

class AddASchoolViewController: UIViewController {

    // MARK: Variables
    var noNetworkConnection = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var schoolNameTextField: HoshiTextField!
    @IBOutlet weak var schoolLocationTextField: HoshiTextField!
    @IBOutlet weak var iAttendThisSchoolLabel: UILabel!
    @IBOutlet weak var iAttendThisSchoolButton: UIButton!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    

    @IBAction func cancelBarButtonItemPresses(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func iAttendThisSchoolButtonPressed(_ sender: Any) {// Checks if the user wants to add the school as their school
        if iAttendThisSchoolButton.tag == 0 {
            iAttendThisSchoolButton.setImage(UIImage(named: "Check Mark Checked"), for: .normal)
            iAttendThisSchoolButton.tag = 1
        } else if iAttendThisSchoolButton.tag == 1 {
            iAttendThisSchoolButton.setImage(UIImage(named: "Check Mark Unchecked"), for: .normal)
            iAttendThisSchoolButton.tag = 0
        }
    }
    
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        if reachabilityStatus == kNOTREACHABLE {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else {
            self.checkSchoolData()
        }
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        // Set up Keyboard Extension
        self.keyboardToolbar.removeFromSuperview()
        self.schoolNameTextField.inputAccessoryView = self.keyboardToolbar
        self.schoolLocationTextField.inputAccessoryView = self.keyboardToolbar
        // Set up Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(AddASchoolViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkSchoolData() { // Checks if text fields were entered correctly
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        if (schoolNameTextField.text?.characters.count)! < 1 {
            self.displayError(title: "Error", message: "Please enter a school name")
            spinningActivity.hide(animated: true)
        } else if (schoolLocationTextField.text?.characters.count)! < 1 {
            self.displayError(title: "Error", message: "Please enter a school location, such as 'San Francisco, CA'")
            spinningActivity.hide(animated: true)
        } else if schoolLocationTextField.text?.range(of: ",") == nil {
            self.displayError(title: "Error", message: "Your school location mush include a ',' to seperate 'city, state'")
            spinningActivity.hide(animated: true)
        } else {
            self.addSchoolToDatabase()
            spinningActivity.hide(animated: true)
        }
    }
    
    func addSchoolToDatabase() { // Adds the school data to the "Schools" section of the database
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        var values = [String : String]()
        let schoolName = self.schoolNameTextField.text!
        let schoolLocation = self.schoolLocationTextField.text!
        values["name"] = schoolName
        values["nameLC"] = schoolName.lowercased()
        values["location"] = schoolLocation
        let schoolsRef = databaseReference.child("Schools").childByAutoId()
        schoolsRef.updateChildValues(values, withCompletionBlock: { (error, ref) in // Sends data off to Firebase
            if let error = error { // Checks if there is an error
                self.displayError(title: "Upload Failed", message: "\(error.localizedDescription).")
                spinningActivity.hide(animated: true)
            } else { // If there is no error
                if self.iAttendThisSchoolButton.tag == 1 { // If the user attends the new school
                    self.addSchoolToUserDatabase(uid: ref.key)
                    spinningActivity.hide(animated: true)
                } else { // If the user does not attend the new school
                    spinningActivity.hide(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    func addSchoolToUserDatabase(uid: String) { // Adds the school under the user's database
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        spinningActivity.label.text = "Loading"
        let schoolName = self.schoolNameTextField.text!
        let schoolLocation = self.schoolLocationTextField.text!
        var values = [String : String]()
        values["schoolName"] = schoolName
        values["schoolLocation"] = schoolLocation
        values["schoolUID"] = uid
        let usersRef = databaseReference.child("Users").child(FIRAuth.auth()!.currentUser!.uid)
        usersRef.updateChildValues(values) { (error, ref) in // Sends data off to Firebase
            if let error = error { // Cehcks if there is an error
                self.displayError(title: "Upload Failed", message: "\(error.localizedDescription)")
                spinningActivity.hide(animated: true)
            } else { // If there is no error
                spinningActivity.hide(animated: true)
                print("New school added")
//                self.performSegue(withIdentifier: "successfulSignupNewSchoolSegue", sender: self)
            }
        }
    }
    
    func reachabilityStatusChanged() {
        if reachabilityStatus == kNOTREACHABLE {
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if reachabilityStatus == kREACHABLEWITHWIFI || reachabilityStatus == kREACHABLEWITHWWAN {
            if noNetworkConnection == true {
                self.displayNetworkReconnection()
                self.noNetworkConnection = false
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){ // Dismisses the keyboard if the user touches outside of the text fields
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
