//
//  DepartmentTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class DepartmentTableViewController: UITableViewController {
    // MARK: Variables
    var schoolUID = String()
    var departmentUID = String()
    var schoolName = String()
    var departmentNameAndCode = String()
    var courses = [DepartmentCourses]()
    var loadingCourses = Bool()
    var coursesDownloaded = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var departmentNameAndCodeLabel: UILabel!
    @IBOutlet weak var schoolNameButton: UIButton!
    @IBOutlet weak var departmentImageBgView: UIView!
    @IBOutlet weak var departmentImageView: UIImageView!
    
    // MARK: Actions
    @IBAction func schoolNameButtonPressed(_ sender: Any) {
        if (schoolUID.characters.count > 0) {
            self.performSegue(withIdentifier: "getSchoolFromDepartmentVCSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "We can't get this school right now")
        }
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        self.setUpViews()
        self.displayDepartmentDetails()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpViews() {
        self.departmentImageBgView.layer.cornerRadius = self.departmentImageBgView.frame.size.width / 2
        self.departmentImageView.layer.cornerRadius = self.departmentImageView.frame.size.width / 2
        self.departmentImageBgView.clipsToBounds = true
        self.departmentImageView.clipsToBounds = true
    }
    
    func displayDepartmentDetails() {
        self.departmentNameAndCodeLabel.text = self.departmentNameAndCode
        self.schoolNameButton.setTitle(self.schoolName, for: .normal)
    }
    
    func getCourses() {
        self.loadingCourses = true
        self.tableView.reloadData()
        self.courses.removeAll(keepingCapacity: false)
        databaseReference.child("schoolCourses").child("-K_wSEKPL0ZWF3B_zegg").child(self.departmentUID).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.exists() == true && snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var data = child.value as! [String: String]
                    data["courseUID"] = child.key
                    let courses = DepartmentCourses(data: data)
                    self.courses.append(courses)
                }
            } else {
                self.displayError(title: "Error", message: "We can't get this school's departments")
            }
            self.reloadData()
        }) { (error) in
            self.displayError(title: "Error", message: "We can't get this school's departments")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingCourses == true) {
            return 1
        } else {
            return self.courses.count
        }
    }
    
    func reloadData() {
        self.loadingCourses = false
        self.coursesDownloaded = true
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingCourses == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCoursesCell", for: indexPath) as! LoadingCoursesTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let attributedText = NSMutableAttributedString()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 20
            let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCoursesCell", for: indexPath) as! DepartmentCoursesTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let course = self.courses[indexPath.row]
            attributedText.append(NSAttributedString(string: course.courseID, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black]))
            attributedText.append(NSAttributedString(string: "\n\(course.courseName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.gray]))
            cell.coursesTextView.isUserInteractionEnabled = false
            cell.coursesTextView.attributedText = attributedText
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.loadingCourses == true) {
            self.displayNotice(title: "Notice", message: "Please wait for courses to load")
        } else {
            let course = self.courses[indexPath.row]
            if (self.schoolUID.characters.count >= 1 && self.departmentUID.characters.count >= 1 && course.courseUID.characters.count >= 1) {
                self.performSegue(withIdentifier: "getCourseFromDepartmentVCSegue", sender: self)
            } else {
                self.displayError(title: "Error", message: "We can't get this course right now")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "getCourseFromDepartmentVCSegue") {
//            let course = self.courses[self.tableView.indexPathForSelectedRow!.row]
//            let destVC = segue.destination as! CourseDetailsTableViewController
//            destVC.schoolUID = self.schoolUID
//            destVC.departmentCodeUID = self.departmentUID
//            destVC.courseUID = course.courseUID
        } else {
            let destVC = segue.destination as! SchoolTableViewController
            destVC.schoolUID = self.schoolUID
        }
    }
    
    func reachabilityStatusChanged() {
        if (networkIsReachable == true) {
            self.displayNetworkReconnection()
            if (self.coursesDownloaded == false) {
            }
        } else {
            self.displayNoNetworkConnection()
        }
    }
}
