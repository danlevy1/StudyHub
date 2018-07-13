//
//  SelectDepartmentTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 12/23/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

/*
 * Downloads departments from the user's school
 * Displays the departments in a table view
 * Allows the user to select their desired department or add a new one
 */

import UIKit
import Firebase
import DZNEmptyDataSet


class SelectDepartmentTVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: Variables
    var departments = [Department2]()
    var department: Department2?
    var course: Course2?
    var newCourseAdded = Bool()
    var isLoading = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addANewDepartmentBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    /*
     * Dismisses the vc
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Segues to the new course vc
     */
    @IBAction func addANewDepartmentBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "newCourseVCFromSelectDepartmentTVCSegue", sender: self)
    }
    
    // MARK: Basics
    /*
     * Checks if there is a network connection
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if (self.checkNetwork() == true) { // Checks for network connection
            self.getDepartments()
        }
    }
    
    /*
     * Sets newCourseChanged = false
     * Segues to selectInstructorTVC if a new course was just added
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.newCourseAdded) { // Checks if new course was added
            self.newCourseAdded = false
            self.performSegue(withIdentifier: "selectInstructorTVCFromSelectDepartmentTVCSegue", sender: self)
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Get Departments
    /*
     * Reloads table view with loading cell
     * Gets all departments within user's school from Firebase Firestore
     * Reloads table view with departments
     */
    func getDepartments() {
        // Reloads table view to show loading cell
        self.isLoading = true
        self.tableView.reloadData()
        (thisUser!.school! as! DocumentReference).collection("departments").getDocuments { (snap, error) in // Gets departments
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
            } else { // No error
                self.departments.removeAll(keepingCapacity: true) // Removes old departments
                for department in snap!.documents { // Loops through each department to get data
                    self.departments.append(Department2(uid: department.documentID, name: department.data()["name"] as? String, ref: department.reference))
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
    
    // MARK: Empty Data Set
    /*
     * Returns image used for empty data set
     */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Departments")
    }
    
    /*
     * Returns title used for empty data set
     */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "Departments", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    /*
     * Returns description used for empty data set
     */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like your school doesn't have any departments registered on StudyHub. Add a department now!", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    
    // MARK: Table View
    /*
     * Returns number of rows in each section
     * Only one section is used
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.isLoading == true) { // Only one row (the loading cell)
            return 1
        } else { // One cell for each department
            return self.departments.count
        }
    }
    
    /*
     * Presents a loading cell if data is being downloaded
     * Presents departments when they are downloaded
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.isLoading == true) {
            return tableView.dequeueReusableCell(withIdentifier: "selectDepartmentLoadingCell", for: indexPath) as! SelectDepartmentLoadingCell // Dequeues a loading cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectDepartmentDepartmentCell", for: indexPath) as! SelectDepartmentDepartmentCell // Dequeues a department cell
            let department = self.departments[indexPath.row] // Gets the correct department data
            self.setUpTextView(textView: cell.textView)
            if let name = department.getName() { // Tries to get department name
                cell.textView.text = name
            } else { // Department name not found
                cell.textView.text = "Error"
            }
            return cell
        }
    }
    
    /*
     * Gets department for the selected row
     * Checks that all department data exists
     * Adds department to course
     * Segues to the select course tvc
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let department = self.departments[indexPath.row] // Gets department
        if (department.getUID() != nil && department.getName() != nil && department.getRef() != nil) { // Checks if department data is available
            self.department = department
            self.performSegue(withIdentifier: "selectCourseTVCFromSelectDepartmentTVCSegue", sender: self)
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    // MARK: Segue
    /*
     * Checks for the segue to the select course tvc
     * Moves the new course to the select course tvc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectCourseTVCFromSelectDepartmentTVCSegue") {
            (segue.destination as! SelectCourseTVC).course = Course2(uid: nil, id: nil, name: nil, instructor: Instructor2(uid: nil, name: nil, ref: nil), ref: nil, department: self.department!)
        } else if (segue.identifier == "newCourseVCFromSelectDepartmentTVCSegue") {
            ((segue.destination as! UINavigationController).topViewController as! NewCourseViewController).selectDepartmentTVC = self
        } else if (segue.identifier == "selectInstructorTVCFromSelectDepartmentTVCSegue") {
            let destVC = segue.destination as! SelectInstructorTVC
            destVC.course = self.course!
            destVC.hideBackButton = true
        }
    }
}
