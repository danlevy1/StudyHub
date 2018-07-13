//
//  HomeTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 12/21/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * UITableViewController that displays the user's current courses
 */

import UIKit
import Firebase
import DZNEmptyDataSet

class HomeTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    // MARK: Variables
    var courses = [Course2]()
    var isLoading = Bool()
    
    // MARK: Actions
    /*
     * Segues to addDepartmentTVC
     */
    @IBAction func addCourseBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeTVCToSelectDepartmentTVCSegue", sender: self)
    }
    
    // MARK: Basisc
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpRefreshControl()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if (self.checkNetwork() == true) {
            self.getCurrentCourses()
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Sets up refresh control
     */
    func setUpRefreshControl() {
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
    }
    
    /*
     * Handles the refresh control being refreshed
     */
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if (self.checkNetwork() == true) {
            self.getCurrentCourses()
        }
    }
    
    // MARK: Download Data
    /*
     * Reloads tableView with loading cell
     * Gets the course and instructor references from the user's profile
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getCurrentCourses() {
        // Reloads tableView with loading cell
        self.isLoading = true
        self.tableView.reloadData()
        let ref2 = firestoreRef.collection("users").document(currentUser!.uid).collection("currentCourses")
        ref2.getDocuments { (snap, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
            } else if (snap!.count > 0) {
                self.courses.removeAll(keepingCapacity: true)
                let group = DispatchGroup()
                for course in snap!.documents { // Loops through each course to get the references
                    if let courseRef = course.data()["courseRef"] as? DocumentReference, let instructorRef = course.data()["instructorRef"] as? DocumentReference {
                        group.enter() // Enters group
                        self.getCourse(courseRef: courseRef, instructorRef: instructorRef, group: group)
                    }
                }
                group.notify(queue: .main, execute: {
                    self.reloadData()
                })
            } else {
                self.reloadData()
            }
        }
    }
    
    /*
     * Gets course uid, id, and name
     */
    func getCourse(courseRef: DocumentReference, instructorRef: DocumentReference, group: DispatchGroup) {
        courseRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists) { // Gets data from course
                let course = Course2(uid: snap!.documentID, id: snap!.data()!["id"] as? String, name: snap!.data()!["name"] as? String, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: courseRef, department: Department2(uid: nil, name: nil, ref: courseRef.parent.parent))
                self.courses.append(course)
                self.getInstructor(instructorRef: instructorRef, course: course, group: group)
            } else {
                group.leave() // Leaves group
            }
        }
    }
    
    /*
     * Gets instructor
     * Adds instructor to instructor's list
     */
    func getInstructor(instructorRef: DocumentReference, course: Course2, group: DispatchGroup) {
        instructorRef.parent.parent?.parent.parent?.collection("instructors").document(instructorRef.documentID).getDocument { (snap, error) in // Gets instructor
            if (error == nil && snap!.exists) { // Checks for no error and data exists
                course.setInstructor(instructor: Instructor2(uid: instructorRef.documentID, name: snap!.data()!["name"] as? String, ref: instructorRef))
            }
            group.leave()
        }
    }
    
    // MARK: Helper Methods
    /*
     * Creates an attributed string with the course's name and instructor name
     */
    func courseInfo(course: Course2) -> NSAttributedString {
        let info = NSMutableAttributedString()
        if let courseName = course.getName() {
            info.append(newAttributedString(string: courseName, color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        }
        if let instructorName = course.getInstructor()?.getName() {
            info.append(newAttributedString(string: "\n" + instructorName, color: .black, stringAlignment: .natural, fontSize: 23, fontWeight: UIFont.Weight.regular, paragraphSpacing: 10))
        }
        return info
    }
    
    /*
     * Sets loading bool to false
     * Reloads the tableView to show the courses
     * Ends the refresh control refreshing
     */
    func reloadData() {
        self.isLoading = false
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: Empty Data Set
    /*
     * Returns image used for empty data set
     */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Courses")
    }
    
    /*
     * Returns title used for empty data set
     */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "My Courses", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    /*
     * Returns description used for empty data set
     */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like you aren't registered with any courses on StudyHub. Let's add them now!", fontSize: 20, fontWeight: .regular)
    }
    
    // MARK: TableView
    /*
     * Returns number of rows in each section
     * Only one section is used
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isLoading == true) { // Only one row (the loading cell)
            return 1
        } else { // One cell for each course
            return courses.count
        }
    }
    
    /*
     * Presents a laoding cell if data is being downloaded
     * Presents courses when they are downloaded
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isLoading == true) {
            return tableView.dequeueReusableCell(withIdentifier: "homeLoadingCell", for: indexPath) as! HomeLoadingCell // Dequeues a loading cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "homeInfoCell", for: indexPath) as! HomeInfoCell
            let course = courses[indexPath.row] // Gets the correct course data
            cell.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.courseInfo(course: course)
            return cell
        }
    }
    
    /*
     * Segues to myCoursesTVC
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "myCoursesTVCToCourseInfoTVCSegue", sender: self)
    }
    
    // MARK: Segue
    /*
     * Checks for the segue to myCoursesTVC
     * Sends selected course over
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "myCoursesTVCToCourseInfoTVCSegue") {
            let indexPath = tableView.indexPathForSelectedRow!.row
            let course = self.courses[indexPath]
            (segue.destination as! CourseInfoTVC).course = course
        }
    }
}
