//
//  NewInstructorVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/3/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows the user to add an instructor
 * Adds a course reference to the user
 * Adds a user reference to the course
 */

import UIKit
import Firebase
import TextFieldEffects
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView

class NewInstructorVC: UIViewController {
    
    // MARK: Variables
    var course: Course2!
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var selectInstructorTVC: UITableViewController?
    var oldInstructorRef: DocumentReference?
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var departmentNameTextField: HoshiTextField!
    @IBOutlet weak var courseNameTextField: HoshiTextField!
    @IBOutlet weak var instructorNameTextField: HoshiTextField!
    @IBOutlet weak var doneButton: UIButton!
    
    
    // MARK: Actions
    /*
     * Dismisses the vc
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Dismisses the keyboard
     * Checks for an active network connection
     */
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        if (self.checkNetwork() == true) {
            self.checkData()
        }
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
     * Dismisses keyboard on tap outside UITextField
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Adds department name and course name to UITextFields
     * Disables the department and course UITextFields
     * Rounds the corners on done button
     */
    func setUpObjects() {
        self.departmentNameTextField.text = self.course.getDepartment()!.getName()!
        self.courseNameTextField.text = self.course.getName()!
        self.departmentNameTextField.isEnabled = false
        self.courseNameTextField.isEnabled = false
        self.doneButton.layer.cornerRadius = 10
        self.doneButton.clipsToBounds = true
    }
    
    //MARK: Check Data
    /*
     * Removes whitespace on the instructor's name
     * Checks that the instructor's name exists
     */
    func checkData() {
        let instructorName = self.trimString(string: self.instructorNameTextField.text!)
        if (instructorName.count > 0) { // Checks that instructors name exists
            self.course.setInstructor(instructor: Instructor2(uid: nil, name: instructorName, ref: nil))
            self.checkInstructor()
        } else { // Instructor's name does not exist
            self.displayError(title: "Error", message: "Please enter the instructor's name for this course")
        }
    }
    
    /*
     * Displays a progress HUD
     * Checks if the instructor already exists
     * Allows the user to use the instructor already in the database
     * Skips adding the instructor if needed
     */
    func checkInstructor() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        self.course.getDepartment()!.getRef()!.collection("instructors").whereField("name", isEqualTo: self.course.getInstructor()!.getName()!).getDocuments { (snap, error) in // Downloads instructor(s) with the same name in the same department
            if (error != nil) { // Checks for an error
                self.displayError(title: "Error", message: "We can't add this course right now. Please try again later.")
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else if (snap!.documents.count > 0) { // Checks for data
                let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                let alertView = SCLAlertView(appearance: alertViewappearance)
                alertView.addButton("Yes", action: { // Sets instructor uid to instructor uid in database
                    alertView.dismiss(animated: true, completion: nil)
                    self.course.getInstructor()?.setUID(uid: snap!.documents.first!.documentID)
                    self.checkUserCourses()
                })
                alertView.addButton("No", action: {
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    alertView.dismiss(animated: true, completion: nil)
                })
                alertView.showInfo("Error", subTitle: "The instructor '\(self.course.getInstructor()!.getName()!)' already exists. Would you like to use this instructor?")
            } else { // No error and no data
                self.addInstructor()
            }
        }
    }
    
    /*
     * Checks if the user is already in the selected course
     * Checks if the user is already with the selected instructor
     * Allows the user to move instructors in the same course
     * Adds the course to the student's profile and adds the user to the instructor
     */
    func checkUserCourses() {
        firestoreRef.collection("users").document(thisUser!.uid!).collection("currentCourses").document(self.course.getUID()!).getDocument { (snap, error) in
            if (error != nil) {
                self.displayError(title: "Error", message: "We can't add this course right now. Please try again later.")
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else if (snap!.exists) { // Looks for the same instructor reference in the user's profile
                if ((snap!.data()!["instructorRef"] as! DocumentReference).documentID == self.course.getInstructor()!.getUID()!) {
                    self.displayError(title: "Error", message: "You are already in \(self.course.getName()!) with \(self.course.getInstructor()!.getName()!)")
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // Looks for the same course but not the same instructor
                    let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alertView = SCLAlertView(appearance: alertViewappearance)
                    alertView.addButton("Yes", action: { // Switches user to new instructor in the same course
                        alertView.dismiss(animated: true, completion: nil)
                        self.oldInstructorRef = snap!.reference
                        self.updateUserCourses()
                    })
                    alertView.addButton("No", action: {
                        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                        alertView.dismiss(animated: true, completion: nil)
                    })
                    alertView.showInfo("Error", subTitle: "You are currently in \(self.course.getName()!) with a different instructor. Would you like to switch to \(self.course.getInstructor()!.getName()!)?")
                }
            } else {
                self.addCourseToUser()
            }
        }
    }
    
    // MARK: Upload Instructor, Course, and User
    /*
     * Creates a new instructor uid
     * Uploads the instructor name to Firebase Firestore
     */
    func addInstructor() {
        if let schoolRef = thisUser?.school as? DocumentReference, let deptUID = self.course.getDepartment()?.getUID() {
            let instructorRef = schoolRef.collection("departments").document(deptUID).collection("instructors").document() // Gets new instructor uid
            instructorRef.setData(["name": self.course.getInstructor()!.getName()!], completion: { (error) in // Uploads instructor
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // No error
                    self.course.getInstructor()!.setUID(uid: instructorRef.documentID)
                    self.course.getInstructor()!.setRef(ref: instructorRef)
                    self.addCourseToInstructor()
                }
            })
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    /*
     * Uploads the course reference to Firebase Firestore
     */
    func addCourseToInstructor() {
        self.course.getInstructor()!.getRef()!.collection("currentCourses").document(self.course.getUID()!).setData(["courseRef": self.course.getRef()!]) { (error) in // Uploads course ref
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else { // No error
                self.addInstructorToCourse()
            }
        }
    }
    
    func addInstructorToCourse() {
        self.course.getRef()!.collection("instructors").document(self.course.getInstructor()!.getUID()!).setData(["instructorRef": self.course.getInstructor()!.getRef()!]) { (error) in // Uploads instructorRef
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else { // No error
                self.checkUserCourses()
            }
        }
    }
    
    /*
     * Adds the course reference to the user's profile
     */
    func addCourseToUser() {
        let instructorRef = self.course.getRef()!.collection("instructors").document(self.course.getInstructor()!.getUID()!)
        firestoreRef.collection("users").document(thisUser!.uid!).collection("currentCourses").document(self.course.getUID()!).setData(["courseRef": self.course.getRef()!, "instructorRef" : instructorRef]) { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.addUserToCourse(instructorRef: instructorRef)
            }
        }
    }
    
    /*
     * Adds this user's reference to the course
     */
    func addUserToCourse(instructorRef: DocumentReference) {
        instructorRef.collection("students").document(thisUser!.uid!).setData(["userRef": firestoreRef.collection("users").document(thisUser!.uid!)], completion: { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.success()
            }
        })
    }
    
    // MARK: Update Data
    /*
     * Sets the instructor reference to the new instructor reference
     */
    func updateUserCourses() {
        let instructorRef = self.course.getRef()!.collection("instructors").document(self.course.getInstructor()!.getUID()!)
        firestoreRef.collection("users").document(thisUser!.uid!).collection("currentCourses").document(self.course.getUID()!).updateData(["instructorRef" : instructorRef]) { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.updateCourseUsers(newInstructorRef: instructorRef)
            }
        }
    }
    
    /*
     * Removes user from old instructor's student list
     * Adds user to new instructor;s student list
     */
    func updateCourseUsers(newInstructorRef: DocumentReference) {
        self.oldInstructorRef!.collection("students").document(thisUser!.uid!).delete { (error) in
            if (error != nil) {
                self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            } else {
                newInstructorRef.collection("students").document(thisUser!.uid!).setData(["userRef": firestoreRef.collection("users").document(thisUser!.uid!)], completion: { (error) in
                    if let error = error {
                        self.displayError(title: "Error", message: error.localizedDescription)
                    } else {
                        self.success()
                    }
                })
            }
        }
    }
    
    // MARK: Success
    /*
     * Removes the progress HUD
     * Displays success banner
     * Dismisses the vc
     */
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.displayBanner(title: "Success!", subtitle: "This instructor has been added", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: {
            (self.selectInstructorTVC as! SelectInstructorTVC).shouldDismissVC = true
            self.dismiss(animated: true, completion: nil)
        })
    }
}
