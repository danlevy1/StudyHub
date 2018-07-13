//
//  InstructorCoursesTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/12/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class InstructorCoursesTVC: UITableViewController {
    
    // MARK: Variables
    var departmentUID = String()
    var instructorUID = String()
    var courses = [Course]()
    var loading = Bool()
    var coursesAreDownloaded = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableView()
        self.checkData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func checkData() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else if (self.checkUser() == false) {
            print("** NO USER")
        } else {
            self.getCourses()
        }
    }
    
    func getCourses() {
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("instructorCourses").child(userData.schoolUID).child(self.departmentUID).child(self.instructorUID).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                var courseData = [String: String]()
                for child in children {
                    courseData = child.value as! [String: String]
                    courseData["uid"] = child.key
                    courseData["instructorName"] = self.instructor.name
                    courseData["instructorUID"] = self.instructor.uid
                    let course = Course(data: courseData)
                    self.courses.append(course)
                }
            }
            self.reloadData()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
    }
    
    func reloadData() {
        self.loading = false
        self.coursesAreDownloaded = true
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.coursesAreDownloaded && self.loading == false) {
            return self.courses.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructorCoursesInfoCell", for: indexPath) as! InstructorCoursesInfoCell
            return cell
        } else if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructorCoursesLoadingCell", for: indexPath) as! InstructorCoursesLoadingCell
            cell.activityIndicator.startAnimating()
        } else if (self.courses.count > 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "instructorCoursesCourseCell", for: indexPath) as! InstructorCoursesCourseCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
            let course = courses[indexPath.row]
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = course.selectCourseInfo
        }
    }

}
