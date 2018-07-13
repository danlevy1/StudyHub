//
//  ChooseCourseTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/24/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet

class ChooseCourseTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    // MARK: Variables
    var courses = [Course]()
    var loading = Bool()
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpRefreshControl()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        self.getcourses()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpRefreshControl() {
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
    }
    
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if (self.checkInfo() == true) {
            self.getcourses()
        }
    }
    
    func getcourses() {
        self.loading = true
        self.tableView.reloadData()
        self.courses.removeAll(keepingCapacity: false)
        if (currentUser!.uid.count > 0) {
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
        return self.emptyDataSetString(string: "Select a Course", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like you aren't registered with any courses on StudyHub. Before you can post, go into 'My Courses' and add your courses.", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Courses")
    }
    
    func courseInfo(course: Course) -> NSAttributedString {
        let info = NSMutableAttributedString()
        info.append(newAttributedString(string: course.name, color: .white, stringAlignment: .natural, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        info.append(newAttributedString(string: "\n" + course.instructorName, color: .white, stringAlignment: .natural, fontSize: 23, fontWeight: UIFont.Weight.regular, paragraphSpacing: 10))
        return info
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCourseLoadingCell", for: indexPath) as! ChooseCourseLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCourseCourseCell", for: indexPath) as! ChooseCourseCourseCell
            let course = courses[indexPath.row]
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: course.color)
            cell.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.courseInfo(course: course)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "chooseCourseTVCToNewPostVCSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chooseCourseTVCToNewPostVCSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let course = self.courses[indexPath!.row]
            let destVC = segue.destination as! NewPostVC
            destVC.course = course
        }
    }
}
