//
//  HomeTVC.swift
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

class HomeTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var courses = [Course]()
    var loading = Bool()
    
    // MARK: Actions
    @IBAction func addCourseBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeTVCToSelectDepartmentTVCSegue", sender: self)
    }
    
    @IBAction func newPostBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeTVCToNewPostVCSegue", sender: self)
    }
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpRefreshControl()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if (self.checkInfo() == true) {
            self.getcourses()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRefreshControl() {
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if (self.checkInfo() == true) {
            self.getcourses()
        }
    }
    
    func getcourses() {
        self.loading = true
        self.tableView.reloadData()
        self.courses.removeAll(keepingCapacity: false)
        if (currentUser!.uid.characters.count > 0) {
            databaseReference.child("users").child(currentUser!.uid).child("currentCourses").observeSingleEvent(of: .value, with: { (snap) in
                if (snap.childrenCount >= 1) {
                    let children = snap.children.allObjects as! [DataSnapshot]
                    for child in children {
                        var data = child.value as! [String : String]
                        data["uid"] = child.key
                        let course = Course(data: data)
                        self.courses.append(course)
                    }
                }
                self.reloadData()
            }) { (error) in
                self.displayError(title: "Error", message: error.localizedDescription)
                self.reloadData()
            }
        } else {
            self.reloadData()
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
        
    }
    
    func reloadData() {
        self.loading = false
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if (self.loading == false && courses.count == 0) {
            return true
        } else {
            return false
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "My Courses", fontSize: 25, fontWeight: UIFontWeightMedium)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like you aren't registered with any courses on StudyHub. Let's add them now!", fontSize: 20, fontWeight: UIFontWeightRegular)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "Add Courses Button")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Courses")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        self.performSegue(withIdentifier: "addCourseFromMyCoursesSegue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true) {
            return 1
        } else {
            return courses.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCoursesLoadingCell", for: indexPath) as! MyCoursesLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myCoursesInfoCell", for: indexPath) as! MyCoursesInfoCell
            let course = courses[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: course.color)
            cell.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = course.myCoursesInfo
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myCoursesTVCToCourseInfoTVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "myCoursesTVCToCourseInfoTVCSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let course = self.courses[indexPath!.row]
            let destVC = segue.destination as! CourseInfoTVC
            destVC.course = course
        }
    }
}
