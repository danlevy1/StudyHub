//
//  SchoolTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 1/7/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import ReachabilitySwift

class SchoolTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: Variables
    var schoolUID = String()
    var schoolDetails = [SchoolDetails]()
    var schoolDepartments = [Department]()
    var loadingDepartments = Bool()
    var schoolDetailsDownloaded = Bool()
    var schoolDepartmentsDownloaded = Bool()
    var refreshController = UIRefreshControl()
    
    // MARK: Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolLocationLabel: UILabel!
    @IBOutlet weak var schoolImageBgView: UIView!
    @IBOutlet weak var schoolImageView: UIImageView!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubBlue
        
        // Set up table view
        self.tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = 70
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Reachability
//        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged), name: ReachabilityChangedNotification, object: reachability)
        
        // Set up views
        self.setUpViews()
        
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
    
    func setUpViews() {
        self.schoolImageBgView.layer.cornerRadius = self.schoolImageBgView.frame.size.width / 2
        self.schoolImageView.layer.cornerRadius = self.schoolImageView.frame.size.width / 2
        self.schoolImageBgView.clipsToBounds = true
        self.schoolImageView.clipsToBounds = true
    }
    
    func checkData() {
        if (self.schoolUID.characters.count >= 1) {
            if (self.schoolDetailsDownloaded == false || self.refreshController.isRefreshing == true) {
                self.checkUserDetails(action: {
                    self.getSchoolDetails()
                })
            }
            if (self.schoolDepartmentsDownloaded == false || self.refreshController.isRefreshing == true) {
                self.checkUserDetails(action: {
                    self.getSchoolDepartments()
                })
            }
        } else {
            self.displayError(title: "Error", message: "We can't get this school right now")
        }
    }
    
    func getSchoolDetails() {
        if (self.schoolUID.characters.count > 0) {
            databaseReference.child("schools").child(self.schoolUID).observeSingleEvent(of: .value, with: { (snap) in
                if (snap.childrenCount >= 1) {
                    let children = snap.children.allObjects as! [DataSnapshot]
                    var data = [String: String]()
                    for child in children {
                        data[child.key] = child.value as? String
                    }
                    let schoolDetails = SchoolDetails(data: data)
                    self.schoolDetails.append(schoolDetails)
                    self.displayStudentDetails()
                } else {
                    self.displayError(title: "Error", message: "We can't get this school right now")
                }
            }) { (error) in
                self.displayError(title: "Error", message: "We can't get this school right now")
            }
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
        
        self.schoolDetailsDownloaded = true
    }
    
    func displayStudentDetails() {
        let school = self.schoolDetails[0]
        self.schoolNameLabel.text = school.schoolName
        self.schoolLocationLabel.text = school.schoolLocation
    }
    
    func getSchoolDepartments() {
        self.loadingDepartments = true
        self.tableView.reloadData()
        self.schoolDepartments.removeAll(keepingCapacity: false)
        if (self.schoolUID.characters.count > 0) {
            databaseReference.child("schoolDepartments").child(self.schoolUID).observeSingleEvent(of: .value, with: { (snap) in
                if (snap.exists() == true && snap.childrenCount >= 1) {
                    let children = snap.children.allObjects as! [DataSnapshot]
                    for child in children {
                        var data = child.value as! [String: String]
                        data["departmentUID"] = child.key
                        let schoolDepartments = Department(data: data)
                        self.schoolDepartments.append(schoolDepartments)
                    }
                    self.loadingDepartments = false
                    self.reloadData()
                } else {
                    self.displayError(title: "Error", message: "We can't get this school's departments")
                    self.loadingDepartments = false
                    self.reloadData()
                }
            }) { (error) in
                self.displayError(title: "Error", message: "We can't get this school's departments")
                self.loadingDepartments = false
                self.reloadData()
            }
        } else {
            
        }
        self.schoolDepartmentsDownloaded = true
    }
    
    func reloadData() {
        if (self.refreshController.isRefreshing == true) {
            self.refreshController.endRefreshing()
        }
        self.schoolDetailsDownloaded = true
        self.schoolDepartmentsDownloaded = true
        self.loadingDepartments = false
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.loadingDepartments == true) {
            return 1
        } else {
            return self.schoolDepartments.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.loadingDepartments == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingDepartmentsCell", for: indexPath) as! LoadingDepartmentsTableViewCell
            cell.activityIndicator.startAnimating()
            return cell
        } else {
            let attributedText = NSMutableAttributedString()
            let cell = tableView.dequeueReusableCell(withIdentifier: "schoolDepartmentsCell", for: indexPath) as! SchoolDepartmentsTableViewCell
            cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: UIColor.white)
            let department = self.schoolDepartments[indexPath.row]
//            attributedText.append(NSAttributedString(string: department.departmentNameAndCode, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSForegroundColorAttributeName: UIColor.black]))
            cell.departmentNameTextView.isUserInteractionEnabled = false
            cell.departmentNameTextView.attributedText = attributedText
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.loadingDepartments == true) {
            self.displayNotice(title: "Notice", message: "Please wait for departments to load")
        } else {
            let department = self.schoolDepartments[indexPath.row]
            if (department.uid.characters.count >= 1) {
                self.performSegue(withIdentifier: "getDepartmentFromSchoolVCSegue", sender: self)
            } else {
                self.displayError(title: "Error", message: "We can't get this department right now")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "getDepartmentFromSchoolVCSegue") {
            let department = self.schoolDepartments[tableView.indexPathForSelectedRow!.row]
            let destVC = segue.destination as! DepartmentTableViewController
            destVC.schoolUID = self.schoolUID
            destVC.departmentUID = department.uid
            destVC.schoolName = self.schoolDetails[0].schoolName
            destVC.departmentNameAndCode = department.name
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
