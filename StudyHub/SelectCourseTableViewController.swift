//
//  SelectCourseTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class SelectCourseTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var departmentCodeUID = String()
    var departmentCode = String()
    var courses = [Coursess]()
    var loadingCourses = Bool()
    var dataDownloaded = Bool()
    var refreshController = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
        
        // Set up table view
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
        
        // Set up Refresh Control
        refreshController = UIRefreshControl()
        refreshController.tintColor = studyHubBlue
        refreshController.addTarget(self, action: #selector(self.checkData), for: .valueChanged)
        self.tableView.refreshControl = self.refreshController
        
        self.checkData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkData() {
        self.checkUserDetails(action: {
            if (self.dataDownloaded == false || self.refreshController.isRefreshing == true) {
                self.getCourses()
            } else {
                self.reloadData()
            }
        })
    }
    
    func getCourses() {
        self.loadingCourses = true
        self.tableView.reloadData()
        self.courses.removeAll(keepingCapacity: false)
        databaseReference.child("schoolCourses").child("-K_wSEKPL0ZWF3B_zegg").child(departmentCodeUID).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.exists() == true && snap.childrenCount >= 1) {
                if (snap.exists() == true && snap.childrenCount >= 1) {
                    let children = snap.children.allObjects as! [DataSnapshot]
                    for child in children {
                        var data = child.value as! [String : String]
                        data["courseUID"] = child.key
                        let courses = Coursess(data: data)
                        self.courses.append(courses)
                    }
                    let data = ["courseID" : "Can't find your course?"]
                    let courses = Coursess(data: data)
                    self.courses.append(courses)
                }
                self.reloadData()
            }
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func reloadData() {
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.loadingCourses = false
        self.dataDownloaded = true
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingCourses == true) {
            return 1
        } else {
            return self.courses.count
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "Courses"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "It looks like your school doesn't have any courses registered on StudyHub. Let's add some now!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "Add My Courses!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.performSegue(withIdentifier: "newCourseSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingCourses == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSelectCourseCell", for: indexPath) as! LoadingSelectCourseTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let attributedText = NSMutableAttributedString()
            let cell = tableView.dequeueReusableCell(withIdentifier: "coursesCell", for: indexPath) as! CoursesTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let course = self.courses[indexPath.row]
            if (course.courseID.characters.count > 0) {
                 attributedText.append(NSAttributedString(string: course.courseID, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.black]))
            }
            if (course.courseName.characters.count > 0) {
               attributedText.append(NSAttributedString(string: "\n\(course.courseName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.gray]))
            }
            cell.courseTextView.isUserInteractionEnabled = false
            cell.courseTextView.attributedText = attributedText
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let course = self.courses[indexPath!.row]
        if (course.courseID == "Can't find your course?") {
            self.performSegue(withIdentifier: "newCourseSegue", sender: self)
        } else if (course.courseUID.characters.count >= 1 && course.courseName.characters.count >= 1 && course.courseID.characters.count >= 1) {
            self.performSegue(withIdentifier: "selectSectionSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "Please try selecting this course again later")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectSectionSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let course = self.courses[indexPath!.row]
            let destVC = segue.destination as! SelectSectionTableViewController
            destVC.departmentCodeUID = self.departmentCodeUID
            destVC.courseNumber = course.courseID
            destVC.departmentCode = self.departmentCode
            destVC.courseUID = course.courseUID
            destVC.courseName = course.courseName
        } else {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewCourseViewController
        }
    }
    
    func reachabilityStatusChanged() {
        if (networkIsReachable == true) {
            self.displayNetworkReconnection()
            self.checkData()
        } else {
            self.displayNoNetworkConnection()
        }
    }
}
