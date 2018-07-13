//
//  SelectInstructorTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 6/30/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Downloads instructors from the user's selected course
 * Displays the instructors in a table view
 * Allows the user to select their desired instructor or add a new one
 * Adds a course reference to the user
 * Adds a user reference to the course
 */

import UIKit
import Firebase
import DZNEmptyDataSet
import MBProgressHUD
import NVActivityIndicatorView
import SCLAlertView

class SelectInstructorTVC: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var course: Course2!
    var instructors = [Instructor2]()
    var instructorType = String()
    var loading = Bool()
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var shouldDismissVC = Bool()
    var oldInstructorRef: DocumentReference?
    var hideBackButton = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var addAnInstructorBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    /*
     * Segues to the new instructor vc
     */
    @IBAction func addAnInstructorBarButtonItemPressed(_ sender: Any) {
        if (self.instructorType == "course") { // Course instructors downloaded
            let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: alertViewappearance)
            alertView.addButton("Ok", action: {
                alertView.dismiss(animated: true, completion: nil)
                self.getDeptInstructors()
            })
            alertView.showInfo("Add Instructor", subTitle: "Can't find your instructor? Take a look at these instructors.")
        } else { // Department instructors downloaded
            self.performSegue(withIdentifier: "selectInstructorTVCToNewInstructorVCSegue", sender: self)
        }
    }
    
    // MARK: Basics
    /*
     * Checks if there is an active network connection
     * Hides back button if needed
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if (self.checkNetwork() == true) { // Checks for network connection
            self.getCourseInstructors()
        }
        if (self.hideBackButton) { // Hides back button
            self.hideBackButton = false
            self.navigationItem.hidesBackButton = true
        }
    }
    
    /*
     * Dismisses the vc if needed
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.shouldDismissVC) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Get Instructors
    /*
     * Reloads table view with loading cell
     * Gets all instructors within user's selected course from Firebase Firestore
     * Reloads table view with course cells
     * Uses DispatchGroup to get all data
     */
    func getCourseInstructors() {
        // Reloads tableView with loading cell
        self.loading = true
        self.tableView.reloadData()
        self.course.getRef()!.collection("instructors").getDocuments { (snap, error) in // Gets instructors
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
            } else { // No error found
                self.instructors.removeAll(keepingCapacity: true)
                let group = DispatchGroup()
                for instructor in snap!.documents { // Gets each instructor's data
                    if let deptInstructorRef = instructor.data()["instructorRef"] as? DocumentReference {
                        group.enter() // Enters group
                        self.getInstructor(deptInstructorRef: deptInstructorRef, courseInstructorRef: instructor.reference, group: group)
                    }
                }
                group.notify(queue: .main, execute: {
                    self.instructorType = "course"
                    self.reloadData() // Reloads tableView with course cells
                })
            }
        }
    }
    
    /*
     * Gets instructor name
     */
    func getInstructor(deptInstructorRef: DocumentReference, courseInstructorRef: DocumentReference, group: DispatchGroup) {
        deptInstructorRef.getDocument { (snap, error) in
            if (error == nil && snap!.exists) { // Gets data from instructor
                self.instructors.append(Instructor2(uid: courseInstructorRef.documentID, name: snap!.data()!["name"] as? String, ref: courseInstructorRef))
            }
            group.leave() // Leaves group
        }
    }
    
    /*
     * Reloads table view with loading cell
     * Gets all instructors within user's selected course's department
     * Reloads table view with course cells
     */
    func getDeptInstructors() {
        // Reloads tableView with loading cell
        self.loading = true
        self.tableView.reloadData()
        self.course.getDepartment()!.getRef()!.collection("instructors").getDocuments { (snap, error) in // Gets instructors
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
            } else { // No error found
                self.instructors.removeAll(keepingCapacity: true)
                for instructor in snap!.documents { // Gets each instructor's data
                    self.instructors.append(Instructor2(uid: instructor.documentID, name: instructor.data()["name"] as? String, ref: instructor.reference))
                }
            }
            self.instructorType = "dept"
            self.reloadData() // Reloads tableView with course cells
        }
    }
    
    /*
     * Updates isLoading
     * Reloads table view
     */
    func reloadData() {
        self.loading = false
        self.tableView.reloadData()
    }
    
    // MARK: Empty Data Set
    /*
     * Returns image used for empty data set
     */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Instructors")
    }
    
    /*
     * Returns title used for empty data set
     */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "Instructors", fontSize: 25, fontWeight: UIFont.Weight.medium)
    }
    
    /*
     * Returns description used for empty data set
     */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "It looks like your school doesn't have any instructors registered on StudyHub. Let's add an instructor!", fontSize: 20, fontWeight: UIFont.Weight.regular)
    }
    
    // MARK: Table View
    /*
     * Returns number of rows in each section
     * Only one section is used
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loading == true) { // Only one row (loading cell)
            return 1
        } else { // One cell for each instructor
            return self.instructors.count
        }
    }
    
    /*
     * Presents a loading cell if data is being downloaded
     * Presents courses when they are downloaded
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loading == true) { // Checks if data is downloading
            return tableView.dequeueReusableCell(withIdentifier: "selectInstructorLoadingCell", for: indexPath) as! SelectInstructorLoadingCell // Dequeues a loading cell
        } else { // Gets all courses
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectInstructorInstructorCell", for: indexPath) as! SelectInstructorInstructorCell // Dequeues a course cell
            let instructor = self.instructors[indexPath.row] // Gets the correct course data
            self.setUpTextView(textView: cell.textView)
            if let instructorName = instructor.getName() { // Tries to get instructor's name
                cell.textView.text = instructorName
            } else { // Instructor's name not found
                cell.textView.text = "Error"
            }
            return cell
        }
    }
    
    /*
     * Gets course for the selected row
     * Sets the course uid, name, and id of the new course
     * Segues to the select instructor tvc
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow // Gets selected row's index path
        let instructor = self.instructors[indexPath!.row] // Gets instructor data for the selected index path
        // Updates newCourse with instructor data
        if let uid = instructor.getUID(), let name = instructor.getName(), let ref = instructor.getRef() { // Tries to get instructor data
            self.course.setInstructor(instructor: Instructor2(uid: uid, name: name, ref: ref))
            self.checkUserCourses()
        } else { // Instructor data not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    //MARK: Check Data
    /*
     * Displays a progress HUD
     * Checks if the user is already in the selected course
     * Checks if the user is already with the selected instructor
     * Allows the user to move instructors in the same course
     * Adds the course to the student's profile and adds the user to the instructor
     */
    func checkUserCourses() {
        // Displays progress HUD
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        if let userRef = thisUser?.ref as? DocumentReference { // Tries to get user reference
            print(userRef.documentID)
            userRef.collection("currentCourses").document(self.course.getUID()!).getDocument { (snap, error) in
                if (error != nil) { // Checks for an error
                    self.displayError(title: "Error", message: "We can't add this course right now. Please try again later.")
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else if (snap!.exists) { // Checks if data exists
                    if let instructorUID = self.course.getInstructor()?.getUID() {
                        if ((snap!.data()!["instructorRef"] as! DocumentReference).documentID == instructorUID) {
                            self.displayError(title: "Error", message: "You are already in \(self.course.getName()!) with \(self.course.getInstructor()!.getName()!)")
                            self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                        } else { // Looks for the same course but not the same instructor
                            let alertViewappearance = SCLAlertView.SCLAppearance(showCloseButton: false)
                            let alertView = SCLAlertView(appearance: alertViewappearance)
                            alertView.addButton("Yes", action: { // Switches user to new instructor in the same course
                                alertView.dismiss(animated: true, completion: nil)
                                self.oldInstructorRef = snap!.reference
                                self.updateUserCourses()
                            })
                            alertView.addButton("No", action: {
                                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                                alertView.dismiss(animated: true, completion: nil)
                            })
                            alertView.showInfo("Error", subTitle: "You are currently in \(self.course.getName()!) with a different instructor. Would you like to switch to \(self.course.getInstructor()!.getName()!)?")
                        }
                    }
                } else { // Data does not exist
                    self.addCourseToUser()
                }
            }
        } else { // User reference not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later")
        }
    }
    
    // MARK: Add New Data
    /*
     * Adds the course reference to the user's profile
     */
    func addCourseToUser() {
        if let userRef = thisUser?.ref as? DocumentReference { // Tries to get user reference
            userRef.collection("currentCourses").document(self.course.getUID()!).setData(["courseRef": self.course.getRef()!, "instructorRef" : self.course.getInstructor()!.getRef()!]) { (error) in
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // No error found
                    self.addUserToCourse(instructorRef: self.course.getInstructor()!.getRef()!)
                }
            }
        } else { // User reference not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later")
        }
    }
    
    /*
     * Adds this user's reference to the course
     */
    func addUserToCourse(instructorRef: DocumentReference) {
        if let userRef = thisUser?.ref as? DocumentReference {
            instructorRef.collection("students").document(userRef.documentID).setData(["userRef": userRef], completion: { (error) in
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                } else { // No error found
                    self.success()
                }
            })
        }
    }
    
    // MARK: Update Data
    /*
     * Sets the instructor reference to the new instructor reference
     */
    func updateUserCourses() {
        (thisUser!.ref! as! DocumentReference).collection("currentCourses").document(self.course.getUID()!).updateData(["instructorRef" : self.course.getInstructor()!.getRef()!]) { (error) in // Uploads new instructor reference
            if let error = error { // Checks for an error
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else { // No error found
                self.updateCourseUsers()
            }
        }
    }
    
    /*
     * Removes user from old instructor's student list
     * Adds user to new instructor;s student list
     */
    func updateCourseUsers() {
        self.oldInstructorRef!.collection("students").document(thisUser!.uid!).delete { (error) in // Removes user from old instructor
            if (error != nil) { // Checks for an error
                self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            } else { // No error
                self.course.getInstructor()!.getRef()!.collection("students").document(thisUser!.uid!).setData(["userRef": firestoreRef.collection("users").document(thisUser!.uid!)], completion: { (error) in // Uploads user to new instructor
                    if let error = error { // Checks for an error
                        self.displayError(title: "Error", message: error.localizedDescription)
                    } else { // No error
                        self.success()
                    }
                })
            }
        }
    }
    
    // MARK: Success
    /*
     * Removes the progress HUD
     * Displays success banner
     * Dismisses the vc
     */
    func success() {
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        self.displayBanner(title: "Success!", subtitle: "This instructor has been added", style: .success)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: Segue
    /*
     * Moves the new course to the new instructor vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "selectInstructorTVCToNewInstructorVCSegue") {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! NewInstructorVC
            destVC.selectInstructorTVC = self
            destVC.course = self.course
        }
    }
}
