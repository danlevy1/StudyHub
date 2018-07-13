//
//  NewInstructorVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/3/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView

class NewInstructorVC: UIViewController {
    
    // MARK: Variables
    var newCourse = NewCourse()
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var instructorNameTextField: HoshiTextField!
    @IBOutlet weak var courseDetailsTextView: UITextView!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var keyboardToolbarBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbarBarButtonItem: UIBarButtonItem!
    
    
    // MARK: Actions
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func keyboardToolbarBarButtonItemPressed(_ sender: Any) {
        self.view.endEditing(true)
        if (self.checkInfo() == true) {
            self.checkData()
        }
    }
    @IBAction func bottomToolbarBarButtonItemPressed(_ sender: Any) {
        self.view.endEditing(true)
        if (self.checkInfo() == true) {
            self.checkData()
        }
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpKeyboardExtension()
        self.setUpTextView()
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpKeyboardExtension() {
        self.keyboardToolbar.removeFromSuperview()
        self.instructorNameTextField.inputAccessoryView = self.keyboardToolbar
    }
    
    func setUpTextView() {
        self.courseDetailsTextView.isUserInteractionEnabled = false;
        self.courseDetailsTextView.textContainerInset = UIEdgeInsets.zero
        let attributedString = NSMutableAttributedString()
        attributedString.append(newAttributedString(string: thisUser!.schoolName!, color: .white, stringAlignment: .center, fontSize: 25, fontWeight: UIFontWeightMedium, paragraphSpacing: 10))
        attributedString.append(newAttributedString(string: "\n" + self.newCourse.departmentName, color: .white, stringAlignment: .center, fontSize: 20, fontWeight: UIFontWeightRegular, paragraphSpacing: 10))
        attributedString.append(newAttributedString(string: "\n" + self.newCourse.name, color: .white, stringAlignment: .center, fontSize: 15, fontWeight: UIFontWeightLight, paragraphSpacing: 10))
        self.courseDetailsTextView.attributedText = attributedString
    }
    
    func checkData() {
        // TODO: Check textFields
        self.newCourse.setInstructorName(instructorName: self.instructorNameTextField.text!)
        self.addInstructor()
    }
    
    func addInstructor() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        let data = ["name": self.newCourse.instructorName, "schoolName": thisUser!.schoolName!, "departmentName": self.newCourse.departmentName]
        databaseReference.child("instructors").child(thisUser!.schoolUID!).child(self.newCourse.departmentUID).childByAutoId().updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.newCourse.setInstructorUID(instructorUID: ref.key)
                self.addInstructorToCourse(data: data)
            }
        }
    }
    
    func addInstructorToCourse(data: [String: String]) {
        databaseReference.child("courseInstructors").child(thisUser!.schoolUID!).child(self.newCourse.departmentUID).child(self.newCourse.uid).child(self.newCourse.instructorUID).updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.newCourse.setInstructorUID(instructorUID: ref.key)
                self.addCourseToInstructor()
            }
        }
    }
    
    func addCourseToInstructor() {
        let data = ["name": self.newCourse.name, "id": self.newCourse.id]
        databaseReference.child("instructorCourses").child(thisUser!.schoolUID!).child(self.newCourse.departmentUID).child(self.newCourse.instructorUID).child(self.newCourse.uid).updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
            } else {
                self.addCourseToUser()
            }
        }
    }
    
    func addCourseToUser() {
        let data = ["color": self.newCourse.color, "id": self.newCourse.id, "name": self.newCourse.name, "departmentUID": self.newCourse.departmentUID, "instructorName": self.newCourse.instructorName, "instructorUID": self.newCourse.instructorUID]
        databaseReference.child("users").child(Auth.auth().currentUser!.uid).child("currentCourses").child(self.newCourse.uid).updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.addUserToCourse()
            }
        }
    }
    
    func addUserToCourse() {
        let data = ["fullName": thisUser!.fullName!, "username": thisUser!.username!, "departmentUID": self.newCourse.departmentUID]
        databaseReference.child("courseStudents").child(thisUser!.schoolUID!).child(self.newCourse.departmentUID).child(self.newCourse.uid).child(self.newCourse.instructorUID).child(currentUser!.uid).updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.displaySuccessMessage()
            }
        }
    }
    
    func displaySuccessMessage() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.displayBanner(title: "Success!", subtitle: "This instructor has been added", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
