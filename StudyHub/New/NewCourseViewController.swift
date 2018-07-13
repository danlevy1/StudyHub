//
//  NewCourseViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/25/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import NVActivityIndicatorView
import TextFieldEffects
import SCLAlertView

/*
 * Allows the user to create a new department
 * Allows the user to create a new course
 * Uploads the data to Firebase Firestore
 */

class NewCourseViewController: UIViewController {
    
    // MARK: Variables
    var course: Course2!
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var selectDepartmentTVC: UITableViewController?
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var departmentTextField: HoshiTextField!
    @IBOutlet weak var courseNameTextField: HoshiTextField!
    @IBOutlet weak var courseIDTextField: HoshiTextField!
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
     * Calls other methods
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
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Rounds the corners on done button
     * Disables the department name text field if department exists
     */
    func setUpObjects() {
        self.doneButton.layer.cornerRadius = 10
        self.doneButton.clipsToBounds = true
        if (self.course != nil && self.course.getDepartment() != nil) { // Checks if department exists
            if let deptName = self.course.getDepartment()?.getName() { // Tries to get department name
                self.departmentTextField.isUserInteractionEnabled = false
                self.departmentTextField.text = deptName
            }
        }
    }
    
    // MARK: Check Data
    /*
     * Checks that the user entered a department name, a course name, and a course id
     * Only checks the department name if the department name was not already given
     */
    func checkData() {
        if (self.departmentTextField.isEnabled == true) { // Checks if department name was already selected
            let departmentName = self.trimString(string: self.departmentTextField.text!)
            if (departmentName.count > 0) { // Checks if department name exists
                if (self.course != nil) { // Checks if course exists
                    self.course.setDepartment(department: Department2(uid: nil, name: departmentName, ref: nil))
                } else { // Course does not exist
                    self.course = Course2(uid: nil, id: nil, name: nil, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: nil, department: Department2(uid: nil, name: departmentName, ref: nil))
                }
            } else { // Department name doesn't exist
                self.displayError(title: "Error", message: "Please enter a department name")
                return
            }
        }
        let courseName = self.trimString(string: self.courseNameTextField.text!)
        let courseID = self.trimString(string: self.courseIDTextField!.text!)
        if (courseName.count > 0) { // Checks if course name exists
            self.course.setName(name: courseName)
        } else { // Department name doesn't exist
            self.displayError(title: "Error", message: "Please enter a course name")
            return
        }
        if (courseID.count > 0) { // Checks if course id exists
            self.course.setID(id: courseID)
        } else { // Course id doesn't exist
            self.displayError(title: "Error", message: "Please enter a course id")
            return
        }
        self.checkVC()
    }
    
    /*
     * Checks if the department name was already given
     * Adds the department first if needed
     */
    func checkVC() {
        if (self.departmentTextField.isEnabled == false) { // Checks if department name was already selected
            self.checkCourse(deptRef: self.course.getDepartment()!.getRef()!, displayHUD: true)
        } else { // Department name does not exist
            self.checkDepartment()
        }
    }
    
    /*
     * Displays progress HUD
     * Checks if the department already exists
     * Skips adding the department if needed
     */
    func checkDepartment() {
        // Displays progress HUD
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        if let schoolRef = thisUser?.school as? DocumentReference { // Tries to get school reference
            schoolRef.collection("departments").whereField("name", isEqualTo: self.course.getDepartment()!.getName()!).getDocuments { (snap, error) in // Downloads department with same name
                if (error != nil) { // Checks for an error
                    self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
                } else if (snap!.documents.count > 0) { // Looks for the same department name in the database
                    let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                    let alertView = SCLAlertView(appearance: alertViewappearance)
                    alertView.addButton("Yes", action: { // Adds the department uid that already exists
                        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                        alertView.dismiss(animated: true, completion: nil)
                        self.course.getDepartment()!.setUID(uid: snap!.documents.first!.documentID)
                        self.checkCourse(deptRef: snap!.documents.first!.reference, displayHUD: false)
                    })
                    alertView.addButton("No", action: { // Dismisses the alert view
                        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                        alertView.dismiss(animated: true, completion: nil)
                    })
                    alertView.showInfo("Error", subTitle: "The department '\(self.course.getDepartment()!.getName()!)' already exists. Would you like to use this department?")
                } else { // No error or data found
                    self.addDepartment()
                }
            }
        } else { // School reference not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    /*
     * Displays a progress HUD
     * Checks if the course already exists
     * Skips adding the course if needed
     */
    func checkCourse(deptRef: DocumentReference, displayHUD: Bool) {
        if (displayHUD) { // Displays progress HUD
            self.activityView = self.customProgressHUDView()
            self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        }
        deptRef.collection("courses").whereField("name", isEqualTo: self.course.getName()!).getDocuments { (snap, error) in
            if (error != nil) { // Checks for an error
                self.displayError(title: "Error", message: "We can't add this course right now. Please try again later.")
            } else if (snap!.documents.count > 0) { // Looks for the same course name in the database
                let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                let alertView = SCLAlertView(appearance: alertViewappearance)
                alertView.addButton("Yes", action: { // Adds the course reference that already exists
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    alertView.dismiss(animated: true, completion: nil)
                    self.course.setRef(ref: snap!.documents.first!.reference)
                    self.success()
                })
                alertView.addButton("No", action: { // Dismisses the alert view
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                    alertView.dismiss(animated: true, completion: nil)
                })
                alertView.showInfo("Error", subTitle: "The course '\(self.course.getName()!)' already exists. Would you like to use this course?")
            } else { // No error or data found
                self.addCourseToCourses()
            }
        }
    }
    
    // MARK: Upload Data
    /*
     * Creates a new department uid
     * Uploads the department name to Firebase Firestore
     */
    func addDepartment() {
        let departmentRef = (thisUser!.school! as! DocumentReference).collection("departments").document() // Gets new uid for department
        departmentRef.setData(["name": self.course.getDepartment()!.getName()!], completion: { (error) in // Uploads department
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else { // No error found
                self.course.getDepartment()!.setUID(uid: departmentRef.documentID)
                self.course.getDepartment()!.setRef(ref: departmentRef)
                self.addCourseToCourses()
            }
        })
    }
    
    /*
     * Displays a progress HUD if needed
     * Creates a new course uid
     * Uploads the course id and name to Firebase Firestore
     * Moves on to next vc
     */
    func addCourseToCourses() {
        let data = ["id": self.course.getID()!, "name": self.course.getName()!] 
            let courseRef = self.course.getDepartment()!.getRef()!.collection("courses").document() // Gets new uid for course
            courseRef.setData(data, completion: { (error) in // Uploads course
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView! )
                } else { // No error found
                    self.course.setUID(uid: courseRef.documentID)
                    self.course.setRef(ref: courseRef)
                    self.success()
                }
            })
    }
    
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        let destVC = self.selectDepartmentTVC as! SelectDepartmentTVC
        destVC.course = self.course
        destVC.newCourseAdded = true
        self.dismiss(animated: true, completion: nil)
    }
}
