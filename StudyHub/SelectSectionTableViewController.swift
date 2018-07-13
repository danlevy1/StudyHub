//
//  SelectSectionTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import MBProgressHUD
import ReachabilitySwift

class SelectSectionTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: Variables
    var departmentCodeUID = String()
    var departmentCode = String()
    var courseUID = String()
    var courseName = String()
    var courseNumber = String()
    var course = String()
    var sections = [Sections]()
    var progressHUD = MBProgressHUD()
    var loadingSections = Bool()
    var dataDownloaded = Bool()
    var dataUploaded = Bool()
    var courseData = [String: String]()
    var refreshController = UIRefreshControl()
    
    // MARK: Functions
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
                self.getSections()
            } else {
                self.reloadData()
            }
        })
    }
    
    func getSections() {
        self.loadingSections = true
        self.tableView.reloadData()
        self.sections.removeAll(keepingCapacity: false)
        databaseReference.child("courseSections").child("-K_wSEKPL0ZWF3B_zegg").child(self.departmentCodeUID).child(self.courseUID).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.exists() == true && snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var data = [String : String]()
                    data = child.value as! [String : String]
                    data["sectionUID"] = child.key
                    let sections = Sections(data: data)
                    self.sections.append(sections)
                }
                let data = ["sectionNumber" : "Can't find your section?"]
                let sections = Sections(data: data)
                self.sections.append(sections)
            }
            self.reloadData()
        }) { (error) in
            self.displayError(title: "Error", message: error.localizedDescription)
            self.reloadData()
        }
    }
    
    func sendCourseToUsersDatabase() {
        self.progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.progressHUD.label.text = "Loading"
        var values = self.courseData
        if (self.courseName.characters.count >= 1) {
            values["courseName"] = self.courseName
        }
        var courseID = String()
        if (self.departmentCode.characters.count >= 1) {
            courseID = self.departmentCode
        }
        if (self.courseNumber.characters.count >= 1) {
            if (courseID.characters.count >= 1) {
                courseID = courseID + " " + self.courseNumber
            } else {
                courseID = self.courseNumber + " (department code n/a)"
            }
        }
        if (courseID.characters.count >= 1) {
            values["courseID"] = courseID
        }
        if (self.departmentCodeUID.characters.count >= 1) {
            values["departmentCodeUID"] = self.departmentCodeUID
        }
        databaseReference.child("users").child(currentUser!.uid).child("currentCourses").child(self.courseUID).updateChildValues(values) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.self.progressHUD.hide(animated: true)
            } else {
                self.sendUserToCourseSectionStudentsDatabase(sectionUID: values["sectionUID"]!)
            }
        }
    }
    
    func sendUserToCourseSectionStudentsDatabase(sectionUID: String) {
        var values = [String: String]()
        if (UserDefaults.standard.value(forKey: "username") != nil) {
            values["studentUsername"] = UserDefaults.standard.value(forKey: "username") as? String
        }
        if (UserDefaults.standard.value(forKey: "fullName") != nil) {
            values["studentFullName"] = UserDefaults.standard.value(forKey: "fullName") as? String
        }
        databaseReference.child("courseSectionStudents").child("-K_wSEKPL0ZWF3B_zegg").child(self.departmentCodeUID).child(self.courseUID).child(sectionUID).child(currentUser!.uid).updateChildValues(values) { (error, ref) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.self.progressHUD.hide(animated: true)
            } else {
                self.success()
            }
        }
        self.dataUploaded = true
    }
    
    func success() {
        self.self.progressHUD.hide(animated: true)
        self.displayBanner(title: "Success!", subtitle: "\(self.courseName) has been added to your current course list", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func reloadData() {
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.loadingSections = false
        self.dataDownloaded = true
        self.tableView.reloadData()
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "Sections"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "It looks like this course doesn't have any sections registered on StudyHub. Let's add your section now!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.darkGray]
        let text = "Add My Section!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.performSegue(withIdentifier: "newSectionSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingSections == true) {
            return 1
        } else {
            return sections.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingSections == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSelectSectionCell", for: indexPath) as! LoadingSelectSectionTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let attributedText = NSMutableAttributedString()
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionsCell", for: indexPath) as! SectionsTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let section = self.sections[indexPath.row]
            var sectionAndCRNNUmber = String()
            if (section.sectionNumber.characters.count >= 1) {
                if (section.sectionNumber != "Can't find your section?") {
                    sectionAndCRNNUmber = "Section " + section.sectionNumber
                } else {
                    sectionAndCRNNUmber = section.sectionNumber
                }
            }
            if (section.crnNumber.characters.count >= 1) {
                sectionAndCRNNUmber = sectionAndCRNNUmber + " • " + "CRN: " + section.crnNumber
            }
            if (sectionAndCRNNUmber.characters.count >= 1) {
                attributedText.append(NSAttributedString(string: sectionAndCRNNUmber, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20), NSForegroundColorAttributeName: UIColor.black]))
            }
            if (section.instructorName.characters.count >= 1) {
                attributedText.append(NSAttributedString(string: "\n\(section.instructorName)", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.gray]))
            }
            cell.sectionTextView.attributedText = attributedText
            cell.sectionTextView.isUserInteractionEnabled = false
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.row]
        if (section.sectionNumber == "Can't find your section?") {
            self.performSegue(withIdentifier: "newSectionSegue", sender: self)
        } else if (section.sectionNumber.characters.count >= 1 && section.crnNumber.characters.count >= 1 && section.instructorName.characters.count >= 1 && section.sectionUID.characters.count >= 1) {
            self.courseData["sectionNumber"] = section.sectionNumber
            self.courseData["crnNumber"] = section.crnNumber
            self.courseData["instructorName"] = section.instructorName
            self.courseData["sectionUID"] = section.sectionUID
            if (networkIsReachable == true) {
              self.sendCourseToUsersDatabase()
            }
        } else {
            self.displayError(title: "Error", message: "Please try selecting this section again later")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newSectionSegue") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewCourseViewController
        }
    }
    
    func reachabilityStatusChanged() {
        if (networkIsReachable == true) {
            if (self.dataDownloaded == false) {
                self.reloadData()
            } else if (self.dataUploaded == false) {
                // TODO: If data has not been uploaded
            }
            self.displayNetworkReconnection()
        } else {
            self.displayNoNetworkConnection()
        }
    }
}
