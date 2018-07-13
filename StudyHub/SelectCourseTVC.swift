//
//  SelectCourseTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 12/24/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Downloads courses from the user's selected department
 * Displays the courses in a table view
 * Allows the user to select their desired course or add a new one
 */

import UIKit
import Firebase
import DZNEmptyDataSet

class SelectCourseTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course: Course2!
    var courses = [Course2]()
    var isLoading = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var addACourseBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    /*
     * Segues to the new course vc
     */
    @IBAction func addACourseBarButtonItemPressed(_ sender: Any) {
       self.performSegue(withIdentifier: "selectCourseTVCToNewCourseVCSegue", sender: self)
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if (self.checkNetwork() == true) {
            self.getCourses()
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Get Courses
    /*
     * Reloads table view with loading cell
     * Gets all courses within user's selected department from Firebase Firestore
     * Reloads table view with courses
     */
    func getCourses() {
        // Reloads table view to show loading cell
        self.isLoading = true
        self.tableView.reloadData()
        self.course.getDepartment()!.getRef()!.collection("courses").getDocuments { (snap, error) in // Gets courses
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
            } else { // No Error
                self.courses.removeAll(keepingCapacity: true) // Removes old courses
                for course in snap!.documents { // Loops through each department to get its data
                    self.courses.append(Course2(uid: course.documentID, id: course.data()["id"] as? String, name: course.data()["name"] as? String, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: course.reference, department: nil))
                }
            }
            self.reloadData() // Reloads table view to show departments
        }
    }
    
    /*
     * Updates isLoading
     * Reloads table view
     */
    func reloadData() {
        self.isLoading = false
        self.tableView.reloadData()
    }
    
    /*
     * Creates a new attributed string with a course id and course name
     */
    func courseInfo(course: Course2) -> NSAttributedString? {
        let info = NSMutableAttributedString()
        var infoAdded = Bool()
        if let id = course.getID() { // Tries to get course id
            info.append(newAttributedString(string: id, color: .white, stringAlignment: .left, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
            infoAdded = true
        }
        if let name = course.getName() { // Tries to get course name
            info.append(newAttributedString(string: "\n" + name, color: .white, stringAlignment: .left, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
            infoAdded = true
        }
        if (infoAdded) { // Checks if info was added
            return info
        } else { // No info added
            return nil
        }
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
        return self.emptyDataSetString(string: "Courses", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    /*
     * Returns description used for empty data set
     */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like your school doesn't have any courses registered on StudyHub. Let's add a course now!", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    // MARK: Table View
    /*
     * Returns number of rows in each section
     * Only one section is used
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isLoading == true) { // Only one row (the loading cell)
            return 1
        } else { // One cell for each course
            return self.courses.count
        }
    }
    
    /*
     * Presents a loading cell if data is being downloaded
     * Presents courses when they are downloaded
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isLoading == true) { // Sets up loading cell
            return tableView.dequeueReusableCell(withIdentifier: "selectCourseLoadingCell", for: indexPath) as! SelectCourseLoadingCell // Dequeues a loading cell
        } else { // Sets up a course cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectCourseCourseCell", for: indexPath) as! SelectCourseCourseCell // Dequeues a course cell
            let course = self.courses[indexPath.row] // Gets course
            // Sets up UITextView
            self.setUpTextView(textView: cell.textView)
            cell.textView.attributedText = self.courseInfo(course: course)
            return cell
        }
    }
    
    /*
     * Gets course for the selected row
     * Sets the course uid, name, and id of the new course
     * Segues to the select instructor tvc
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let course = self.courses[indexPath!.row] // Gets course
        if let uid = course.getUID(), let name = course.getName(), let id = course.getID(), let ref = course.getRef() { // Tries to get course information
            let department = self.course.getDepartment() // Holds department
            self.course = Course2(uid: uid, id: id, name: name, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: ref, department: department)
            self.performSegue(withIdentifier: "selectInstructorTVCFromSelectCourseTVCSegue", sender: self)
        } else { // Course information not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    // MARK: Segue
    /*
     * Moves the new course to the destination vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectInstructorTVCFromSelectCourseTVCSegue") { // Segues to SelectCourseTVC
            let destVC = segue.destination as! SelectInstructorTVC
            destVC.course = self.course
        } else { // Segues to NewCourseVC
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewCourseViewController
            destVC.course = self.course
        }
    }
}
