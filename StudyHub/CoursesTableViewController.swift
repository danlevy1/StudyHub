//
//  CoursesTableViewController.swift
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

class CoursesTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var courses = [Course]()
    var loadingCourses = Bool()
    var viewingCourses = String()
    var schoolUID = String()
    
    // MARK: Outlets
    @IBOutlet weak var addCourseBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    @IBAction func addCourseBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addCourseFromMyCoursesSegue", sender: self)
    }
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar()
        self.setUpTableView()
        self.checkInfo()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
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
        self.tableView.estimatedRowHeight = 50
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
    }
    
    func checkInfo() {
        if (self.checkNetwork() == false) {
            self.displayNoNetworkConnection()
        } else if (self.checkUser() == false) {
            print("**** NO USER")
        } else if (self.viewingCourses != "old") {
            self.getcourses(courses: "currentCourses")
        } else {
            self.getcourses(courses: "oldCourses")
        }
    }
    
    func getcourses(courses: String) {
        self.loadingCourses = true
        self.tableView.reloadData()
        databaseReference.child("users").child(currentUser!.uid).child(courses).observeSingleEvent(of: .value, with: { (snap) in
            if (snap.childrenCount >= 1) {
                let children = snap.children.allObjects as! [DataSnapshot]
                for child in children {
                    var data = child.value as! [String : String]
                    data["courseUID"] = child.key
                    let course = Course(data: data)
                    self.courses.append(course)
                }
                if (courses == "currentCourses") {
                    let oldCourses = Course(data: ["courseName": "View Old Courses", "color": "0,153,204"])
                    self.courses.append(oldCourses)
                }
            }
            self.loadingCourses = false
            self.tableView.reloadData()
        }) { (error) in
            self.reloadData()
            self.displayError(title: "Error", message: error.localizedDescription)
        }
    }
    
    func reloadData() {
        self.loadingCourses = false
        self.tableView.reloadData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if (self.loadingCourses == false && courses.count == 0) {
            return true
        } else {
            return false
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: studyHubBlue]
        let text = "My Courses"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15), NSForegroundColorAttributeName: studyHubGreen]
        let text = "It looks like you aren't registered with any courses on StudyHub. Let's add them now!"
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "Add Courses Button")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "My Courses")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.performSegue(withIdentifier: "addCourseFromMyCoursesSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingCourses == true) {
            return 1
        } else {
            return courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingCourses == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCurrentCoursesCell", for: indexPath) as! LoadingCurrentCoursesTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "currentCoursesCell", for: indexPath) as! CurrentCoursesTableViewCell
            let course = courses[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: course.color)
            cell.setUpTextView(textView: cell.dataTextView)
            cell.dataTextView.attributedText = course.info
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let course = self.courses[indexPath!.row]
        if (course.info.isEqual("View Old Courses")) {
            let oldCourses = self.storyboard?.instantiateViewController(withIdentifier: "CoursesVC") as! CoursesTableViewController
            oldCourses.viewingCourses = "old"
            self.navigationController?.pushViewController(oldCourses, animated: true)
        } else if (course.uid.characters.count > 0) {
            self.performSegue(withIdentifier: "viewCourseDetailsSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "Please try selecting this course again later")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "viewCourseDetailsSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let course = self.courses[indexPath!.row]
            let destVC = segue.destination as! CourseDetailsTableViewController
            destVC.course = course
        }
    }
}
