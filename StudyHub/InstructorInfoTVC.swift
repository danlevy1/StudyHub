//
//  InstructorInfoTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/5/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import Reachability

/*
 * Displays ratings of the instructor
 * Displays courses that the instructor teaches
 */

class InstructorInfoTVC: UITableViewController {
    // MARK: Variables
    var ratingsAreLoading = Bool()
    var coursesAreLoading = Bool()
    var segmentedControlValue = Int()
    var instructor: Instructor2!
    var ratings = [Rating2]()
    var courses = [Course2]()
    var ratingsAreDownloaded = Bool()
    var coursesAreDownloaded = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var rateBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    /*
     * Segues to InstructorRatingVC
     */
    @IBAction func rateBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "instructorInfoTVCToInstructorRatingVCSegue", sender: self)
    }
    
    // MARK: Basics
    /*
     * Registers segmented control header view 2 with the table view
     * Checks network for active network connection
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpRefreshControl()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpNavBarTitle()
        self.tableView.register(UINib(nibName: "SegmentedControlHeaderView2", bundle: nil), forHeaderFooterViewReuseIdentifier: "segmentedControlHeaderView2")
        self.setUpTableView(tableView: self.tableView)
        self.getRatings()
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavBarTitle() {
        if let name = self.instructor?.getName() {
            self.navigationItem.title = name
        } else {
            self.navigationItem.title = "INstructor"
        }
    }
    
    /*
     * Checks for the correct data set to reload
     * Sets data downloaded = true
     * Sets isLoading to false
     * Reloads the tableView
     * Ends refresh controller refreshing
     */
    func reloadData() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: UIRefreshControl
    /*
     * Sets up refresh control
     */
    func setUpRefreshControl() {
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.chooseDataToDisplay), for: .valueChanged)
    }
    
    // MARK: UISegmentedControl
    /*
     * Gets the segmented control value
     */
    @objc func getSegmentValue(sender: UISegmentedControl) {
        self.segmentedControlValue = sender.selectedSegmentIndex
        self.chooseDataToDisplay()
    }
    
    /*
     * Chooses data to display depending on segmented control value
     * Gets new data if refresh control is refreshing or data has not yet been downloaded
     * Displays pre-loaded data otherwise
     */
    @objc func chooseDataToDisplay() {
        if (self.segmentedControlValue == 0 && self.ratingsAreDownloaded == false) {
            self.getRatings()
        } else if (self.segmentedControlValue == 1 && self.coursesAreDownloaded == false) {
            self.getCourses()
        } else {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Empty Data Set
    /*
     * Sets up custom empty data set
     */
    func setUpEmptyDataSet(cell: InstructorInfoEmptyDataSetCell, title: String, description: String, image: UIImage) {
        // Sets up attributed string
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
        text.append(newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image // Displays custom empty data set image
    }
    
    // MARK: Get Ratings
    /*
     * Reloads tableView to display loading cell
     * Downloads ratings
     * Reloads tableView to display ratings
     */
    func getRatings() {
        // Reloads tableView cell
        self.ratingsAreLoading = true
        self.tableView.reloadData()
        if let instructorRef = self.instructor?.getRef() { // Tries to get instructor ref
            instructorRef.collection("ratings").getDocuments(completion: { (snap, error) in // Gets ratings
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.ratingsAreLoading = false
                    self.ratingsAreDownloaded = false
                    if (self.segmentedControlValue == 0) { // Checks if segmented control is still on ratings
                        self.reloadData()
                    }
                } else { // No error
                    for rating in snap!.documents { // Loops through ratings to get data
                        self.ratings.append(Rating2(uid: instructorRef.documentID, rating: rating.data()["rating"] as? Int, review: rating.data()["review"] as? String, recommends: rating.data()["recommends"] as? Bool)) // Creates new rating and adds it to the ratings list
                    }
                    self.ratingsAreLoading = false
                    self.ratingsAreDownloaded = true
                    if (self.segmentedControlValue == 0) { // Checks if segmented control is still on ratings
                        self.reloadData()
                    }
                }
            })
        } else { // Instructor ref not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            self.ratingsAreLoading = false
            self.ratingsAreDownloaded = false
            if (self.segmentedControlValue == 0) { // Checks if segmented control is still on ratings
                self.reloadData()
            }
        }
    }
    
    // MARK: Get Courses
    /*
     * Reloads tableView to display loading cell
     * Downloads courses
     * Reloads tableView to display courses
     * Uses DispatchGroup to get all data
     */
    func getCourses() {
        // Reloads tableView cell
        self.coursesAreLoading = true
        self.tableView.reloadData()
        if let instructorRef = self.instructor?.getRef() {
            instructorRef.collection("currentCourses").getDocuments(completion: { (snap, error) in // Gets courses
                if let error = error { // Checks for an error
                    self.displayError(title: "Error", message: error.localizedDescription)
                    self.coursesAreLoading = false
                    self.coursesAreDownloaded = false
                    if (self.segmentedControlValue == 1) { // Checks if segmented control is still on courses
                        self.reloadData()
                    }
                } else { // No error
                    let group = DispatchGroup()
                    for course in snap!.documents { // Gets each course reference
                        if let courseRef = course.data()["courseRef"] as? DocumentReference { // Tries to get course reference
                            group.enter()
                           self.getCourse(courseRef: courseRef, group: group)
                        }                    }
                    group.notify(queue: .main, execute: {
                        self.coursesAreLoading = false
                        self.coursesAreDownloaded = true
                        if (self.segmentedControlValue == 1) { // Checks if segmented control is still on courses
                            self.reloadData()
                        }
                    })
                }
            })
        } else { // Instructor ref not found
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            self.coursesAreLoading = false
            self.coursesAreDownloaded = false
            if (self.segmentedControlValue == 1) { // Checks if segmented control is still on courses
                self.reloadData()
            }
        }
    }
    
    /*
     * Downloads course
     * Adds course to courses list
     */
    func getCourse(courseRef: DocumentReference, group: DispatchGroup) {
        courseRef.getDocument { (snap, error) in // Downloads course
            if (error == nil && snap!.exists) { // Checks for no error and data exists
                self.courses.append(Course2(uid: courseRef.documentID, id: snap!.data()!["id"] as? String, name: snap!.data()!["name"] as? String, instructor: self.instructor, ref: courseRef, department: Department2(uid: courseRef.parent.parent?.documentID, name: nil, ref: courseRef.parent.parent))) // Creates a new course and adds it to the courses list
            }
            group.leave()
        }
    }
    
    // MARK: Set up UITableViewCells
    /*
     * Sets up objects in rating cell
     */
    func setUpRatingCell(cell: InstructorInfoRatingCell, row: Int) {
        let rating = self.ratings[row] // Gets rating
        // Sets up text view
        self.setUpTextView(textView: cell.textView)
        if let reviewAndRecommendation = self.getReviewAndRecommendation(rating: rating) { // Tries to get review and recommendation
            cell.textView.attributedText = reviewAndRecommendation
        } else { // Review and recommendation not found
            cell.textView.attributedText = newAttributedString(string: "Error", color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: .regular, paragraphSpacing: 0)
        }
        // Sets up rating star UIImageViews
        let stars = [cell.star2, cell.star3, cell.star4, cell.star5] // Gets star UIImageViews (star1 is always active)
        if let ratingInt = rating.getRating() { // Tries to get rating
            for i in 2...ratingInt { // Activates correct number of stars
                stars[i - 2]!.image = #imageLiteral(resourceName: "Rating Star Active") // i starts at 2, stars start at 0
            }
        } else {
            // TODO: Set height to be 0
        }
    }
    
    /*
     * Creates attributed string with review and recommendation
     */
    func getReviewAndRecommendation(rating: Rating2) -> NSAttributedString? {
        let info = NSMutableAttributedString()
        var infoAdded = Bool()
        if let review = rating.getReview() { // Tries to get review
            info.append(newAttributedString(string: review, color: .black, stringAlignment: .natural, fontSize: 25, fontWeight: .regular, paragraphSpacing: 15))
            infoAdded = true
        }
        if let recommends = rating.recommends() { // Tries to get recommendation
            info.append(newAttributedString(string: "\n" + "Recommends Instructor: ", color: .black, stringAlignment: .natural, fontSize: 20, fontWeight: .medium, paragraphSpacing: 0))
            if (recommends) { // Checks if recommends is true
                info.append(newAttributedString(string: "Yes", color: .green, stringAlignment: .natural, fontSize: 20, fontWeight: .medium, paragraphSpacing: 0))
            } else { // Recommends is false
                info.append(newAttributedString(string: "No", color: .red, stringAlignment: .natural, fontSize: 20, fontWeight: .medium, paragraphSpacing: 0))
            }
            infoAdded = true
        }
        if (infoAdded) { // Checks if info was added
            return info
        } else { // No info added
            return nil
        }
    }
    
    /*
     * Sets up objects in course cell
     */
    func setUpCourseCell(cell: InstructorInfoCourseCell, row: Int) {
        self.setUpTextView(textView: cell.textView)
        if let courseInfo = self.getCourseInfo(course: courses[row]) { // Tries to get course info
            cell.textView.attributedText = courseInfo
        } else { // Course info not found
            cell.textView.attributedText = newAttributedString(string: "Error", color: .white, stringAlignment: .natural, fontSize: 25, fontWeight: .bold, paragraphSpacing: 0)
        }
    }
    
    /*
     * Creates attributed string with course's id and name
     */
    func getCourseInfo(course: Course2) -> NSAttributedString? {
        let info = NSMutableAttributedString()
        var infoAdded = Bool()
        if let id = course.getID() { // Tries to get id
            info.append(newAttributedString(string: id, color: .white, stringAlignment: .natural, fontSize: 25, fontWeight: .medium, paragraphSpacing: 10))
            infoAdded = true
        }
        if let name = course.getName() { // Tries to get name
            info.append(newAttributedString(string: "\n" + name, color: .white, stringAlignment: .natural, fontSize: 20, fontWeight: .regular, paragraphSpacing: 0))
            infoAdded = true
        }
        if (infoAdded) { // Info found
            return info
        } else { // Info not found
            return nil
        }
    }
    
    /*
     * Sets up a segmented control as the header
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "segmentedControlHeaderView2") as! SegmentedControlHeaderView2
        header.contentView.backgroundColor = studyHubBlue
        header.segmentedControl.selectedSegmentIndex = self.segmentedControlValue
        header.segmentedControl.layer.cornerRadius = 10
        header.segmentedControl.layer.borderWidth = 1.0
        header.segmentedControl.layer.borderColor = UIColor.white.cgColor
        header.segmentedControl.clipsToBounds = true
        header.segmentedControl.addTarget(self, action: #selector(self.getSegmentValue(sender:)), for: .valueChanged)
        return header
    }
    
    /*
     * Returns custom height for segmented control header
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    /*
     * Returns number of rows in each section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.segmentedControlValue == 0) { // Rating cells
            if (self.ratingsAreLoading) { // Checks if ratings are loading
                return 1
            } else if (self.ratings.count > 0) { // Checks if ratings exist
                return self.ratings.count
            } else { // No ratings exist
                return 1
            }
        } else { // Course cells
            if (self.coursesAreLoading) { // Checks if courses are loading
                return 1
            } else if (self.courses.count > 0) { // Checks if courses exist
                return self.courses.count
            } else { // No courses exist
                return 1
            }
        }
    }
    
    /*
     * Sets up UITableView cells
     * Checks if different data exists
     * Dequeues cells
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.segmentedControlValue == 0) { // Rating cell
            if (self.ratingsAreLoading) { // Checks if ratings are loading
                return tableView.dequeueReusableCell(withIdentifier: "instructorInfoLoadingCell", for: indexPath) as! InstructorInfoLoadingCell // Returns dequeued loading cell
            } else if (self.ratings.count > 0) { // Checks if ratings exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructorInfoRatingCell", for: indexPath) as! InstructorInfoRatingCell // Dequeues rating cell
                self.setUpRatingCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No ratings exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructorInfoEmptyDataSetCell", for: indexPath) as! InstructorInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Ratings", description: "There are no ratings for this instructor", image: #imageLiteral(resourceName: "Ratings"))
                return cell
            }
        } else { // Course cell
            if (self.coursesAreLoading) { // Checks if courses are loading
                return tableView.dequeueReusableCell(withIdentifier: "instructorInfoLoadingCell", for: indexPath) as! InstructorInfoLoadingCell // Returns dequeued loading cell
            } else if (self.courses.count > 0) { // Checks if courses exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructorInfoCourseCell", for: indexPath) as! InstructorInfoCourseCell // Dequeues course cell
                self.setUpCourseCell(cell: cell, row: indexPath.row)
                return cell
            } else { // No courses exist
                let cell = tableView.dequeueReusableCell(withIdentifier: "instructorInfoEmptyDataSetCell", for: indexPath) as! InstructorInfoEmptyDataSetCell
                self.setUpEmptyDataSet(cell: cell, title: "Courses", description: "This instructor doesn't have any courses", image: #imageLiteral(resourceName: "Ratings"))
                return cell
            }
        }
    }
    
    /*
     * Sends instructor to InstructorRatingVC
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "instructorInfoTVCToInstructorRatingVCSegue") {
            let destVC = (segue.destination as! UINavigationController).topViewController! as! InstructorRatingVC
            destVC.instructor = self.instructor
        }
    }
}
