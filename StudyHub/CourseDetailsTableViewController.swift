//
//  CourseDetailsTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class CourseDetailsTableViewController: UITableViewController {
    
    // MARK: Variables
    var course = Course(data: ["": ""])
    var numSections = String()
    var numInstructors = String()
    var instructors = Set<String>()
    var courseSections = [Section]()
    var refreshController = UIRefreshControl()
    var loading = Bool()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableViewRefresher()
        self.setUpTableView()
        self.checkInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBar() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.title = course.id
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
    }
    
    func setUpTableViewRefresher() {
        refreshController = UIRefreshControl()
        refreshController.tintColor = studyHubBlue
        refreshController.addTarget(self, action: #selector(self.checkInfo), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
    }
    
    func setUpTableView() {
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 130
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func checkInfo() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else if (self.checkUser() == false) {
            print("**** NO USER")
        } else {
            self.getSectionsData()
        }
    }
    
    func getSectionsData() {
        self.courseSections.removeAll(keepingCapacity: false)
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("courseSections").child(UserDefaults.standard.value(forKey: "schoolUID") as! String).child(course.departmentUID).child(course.uid).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount > 0) {
                var children = snap.children.allObjects as! [DataSnapshot]
                if (children.count == 1) {
                    self.numSections = String(children.count) + " Section"
                } else {
                    self.numSections = String(children.count) + " Sections"
                }
                var childUIDs = [String]()
                for child in children {
                    childUIDs.append(child.key)
                }
                var instructors = [String]()
                if let usersSectionIndex = childUIDs.index(of: self.course.sectionUID) {
                    let usersSectionChild = children[usersSectionIndex]
                    instructors.append(usersSectionChild.childSnapshot(forPath: "instructorName").value as! String)
                    self.addChild(child: usersSectionChild)
                    children.remove(at: usersSectionIndex)
                }
                for child in children {
                    instructors.append(child.value(forKey: "instructorName") as! String)
                    self.addChild(child: child)
                }
                self.instructors = Set(instructors)
                if (instructors.count == 1) {
                    self.numInstructors = String(instructors.count) + " Instructor"
                } else {
                    self.numInstructors = String(instructors.count) + " Instructors"
                }
                self.reloadData()
            } else {
                self.reloadData()
            }
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func addChild(child: DataSnapshot) {
        var sectionData = child.value as! [String: String]
        sectionData["sectionUID"] = child.key
        self.courseSections.append(Section(data: sectionData))
    }
    
    func reloadData() {
        self.loading = false
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.tableView.reloadData()
    }
    
    func setUpTextView(textView: UITextView) {
        textView.isUserInteractionEnabled = false;
        textView.textContainerInset = UIEdgeInsets.zero
    }
    
    func courseInfo() -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 15
        attributedText.append(NSAttributedString(string: self.course.name, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black]))
        attributedText.append(NSAttributedString(string: "\n" + self.numSections + " • " + self.numInstructors, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: UIColor.black]))
        return attributedText
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true) {
            return 1
        } else {
            return self.courseSections.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCourseInfoCell", for: indexPath) as! LoadingCourseInformationTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseInformationCell", for: indexPath) as! CourseInformationTableViewCell
                self.setUpTextView(textView: cell.courseInfoTextView)
                cell.courseInfoTextView.attributedText = courseInfo()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "courseSectionsCell", for: indexPath) as! CourseSectionsTableViewCell
                let section = self.courseSections[indexPath.row - 1]
                if (indexPath.row == 1) {
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: studyHubBlue)
                } else {
                    cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
                }
                self.setUpTextView(textView: cell.courseSectionsTextView)
                cell.courseSectionsTextView.attributedText = section.info
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        if (indexPath!.row >= 1) {
            self.performSegue(withIdentifier: "sectionDetailsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "sectionDetailsSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let section = self.courseSections[indexPath!.row - 1]
            let destVC = segue.destination as! SectionDetailsTableViewController
            destVC.course = self.course
            destVC.section = section
        }
    }
}
