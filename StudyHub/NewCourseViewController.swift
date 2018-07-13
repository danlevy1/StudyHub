//
//  NewCourseViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/25/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView
import TextFieldEffects
import ReachabilitySwift

class NewCourseViewController: UIViewController {
    
    // MARK: Variables
    var departmentUID = String()
    var departmentName = String()
    var newCourse = NewCourse()
    var progressHUD = MBProgressHUD()
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var customTextField1: HoshiTextField!
    @IBOutlet weak var customTextField2: HoshiTextField!
    @IBOutlet weak var customTextField3: HoshiTextField!
    @IBOutlet weak var keyboardToolbar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var bottomToolbarBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var keyboardToolbarBarButtonItem: UIBarButtonItem!
    
    
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
        self.setUpVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpKeyboardExtension() {
        self.keyboardToolbar.removeFromSuperview()
        self.customTextField1.inputAccessoryView = self.keyboardToolbar
        self.customTextField2.inputAccessoryView = self.keyboardToolbar
        self.customTextField3.inputAccessoryView = self.keyboardToolbar
    }
    
    func setUpVC() {
        if (self.departmentName.characters.count > 0) {
            self.newCourse.setDepartmentUID(uid: self.departmentUID)
            self.newCourse.setDepartmentName(departmentName: self.departmentName)
            self.customizeObjects(textField1: self.departmentName, disableDepartment: true)
        } else {
            self.customizeObjects(textField1: "Department Name", disableDepartment: false)
        }
    }
    
    func customizeObjects(textField1: String, disableDepartment: Bool) {
        if (disableDepartment == true) {
            self.customTextField1.isUserInteractionEnabled = false
        }
        self.customTextField1.placeholder = textField1
        self.customTextField2.placeholder = "Course Name"
        self.customTextField3.placeholder = "Course ID"
    }
    
    func checkData() {
        // TODO: Check textFields
        if (self.departmentName.characters.count > 0) {
            self.newCourse.setDepartmentName(departmentName: self.customTextField1.text!)
        }
        self.newCourse.setDepartmentName(departmentName: self.customTextField1.text!)
        self.newCourse.setName(name: self.customTextField2.text!)
        self.newCourse.setID(id: self.customTextField3.text!)
        self.checkVC()
    }
    
    func checkVC() {
        if (self.departmentName.characters.count > 0) {
            self.addCourseToCourses()
        } else {
            self.addDepartment()
        }
    }
    
    func addDepartment() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        self.progressHUD.tag = 1
        databaseReference.child("departments").child(thisUser!.schoolUID!).childByAutoId().updateChildValues(["name": self.newCourse.departmentName]) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView!)
            } else {
                self.newCourse.setDepartmentUID(uid: ref.key)
                self.addCourseToCourses()
            }
        }
    }
    
    func addCourseToCourses() {
        if (self.progressHUD.tag == 0) {
            self.activityView = self.customProgressHUDView()
            self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        }
        let data = ["id": self.newCourse.id, "name": self.newCourse.name]
        databaseReference.child("courses").child(thisUser!.schoolUID!).child(self.newCourse.departmentUID).childByAutoId().updateChildValues(data) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD, activityView: self.activityView! )
            } else {
                self.newCourse.setUID(uid: ref.key)
                self.performSegue(withIdentifier: "newCourseVCToSelectInstructorTVCSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newCourseVCToSelectInstructorTVCSegue") {
            let destVC = segue.destination as! SelectInstructorTVC
            destVC.newCourse = self.newCourse
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
