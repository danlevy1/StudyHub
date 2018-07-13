//
//  ConnectToSchoolTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/22/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD

class ConnectToSchoolTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: Variables
    var fromSignup = Bool()
    var newSchoolAdded = Bool()
    var loadingSchools = Bool()
    var noSchools = Bool()
    var schools = [Schools]()
    var noNetworkConnection = Bool()
    
    // MARK: Actions
    @IBAction func addPressed(_ sender: Any) { // TODO: For testing only
        self.performSegue(withIdentifier: "addSchoolFromSignupSegue", sender: self)
    }
    
    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        // Set up Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(ConnectToSocialAccountSetupViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        // Set up Table View
        tableView.separatorStyle = .none
        tableView.backgroundColor = studyHubColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.schools.removeAll()
        if searchBar.text != "" { // Checks if there is text in the search bar
            self.loadingSchools = true
            self.noSchools = false
            self.tableView.reloadData()
            // Get new school results
            self.getSchoolResults()
        } else { // If there is no text, no search will happen
            self.loadingSchools = false
            self.noSchools = true
            self.tableView.reloadData()
        }
    }
    
    func getSchoolResults() { // Gets the data for the table view based on the person's text
        databaseReference.child("Schools").queryOrdered(byChild: "name").queryStarting(atValue: "A").queryEnding(atValue: "A\\uf8ff").observeSingleEvent(of: .value, with: { (snapshot) in // Gets the school results
            print(snapshot);
            if snapshot.children.allObjects as? [FIRDataSnapshot] != nil && snapshot.exists() == true { // Checks if there are any results
                let snapshot = snapshot.children.allObjects as! [FIRDataSnapshot]
                var schoolDict = [String : String]()
                for snap in snapshot { // Loops through each snap and puts it into a dictionary
                    schoolDict = snap.value as! [String : String]
                    schoolDict["schoolUID"] = snap.key
                    let school = Schools(schoolData: schoolDict)
                    self.schools.append(school)
                    self.loadingSchools = false
                    self.noSchools = false
                    self.tableView.reloadData()
                }
            } else { // If there aren't any schools that include the search term
                self.loadingSchools = false
                self.noSchools = true
                self.tableView.reloadData()
            }
        }) { (error) in // If an error occurs
            self.loadingSchools = false
            self.noSchools = false
            self.tableView.reloadData()
            // TODO: Display error in table view
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.loadingSchools == true {
            return 1
        } else if self.schools.count > 0 {
            return self.schools.count + 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectToSchoolInfoCell", for: indexPath) as! ConnectToSchoolInfoTableViewCell
        
        cell.enableCardTableView()
        if (self.loadingSchools == true) {
            cell.schoolNameLabel.text = "Loading..."
        } else if (self.noSchools == true) {
            cell.schoolNameLabel.text = "We could not find this school"
            cell.schoolLocationButton.setTitle("Add this school", for: .normal)
        } else {
//            cell.customImageView.image = schools
            let school = self.schools[indexPath.row]
            cell.schoolNameLabel.text = school.schoolName
            cell.schoolLocationButton.setTitle(school.schoolLocation, for: .normal)
            cell.schoolUID = school.schoolUID
        }
        
        return cell
        
        
        
//        if (self.schools.count > 0) {
//            print("TRUE 1")
//            if (indexPath.row != self.schools.count + 1) {
//                print("TRUE 2")
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectToSchoolInfoCell", for: indexPath) as! ConnectToSchoolInfoTableViewCell
//                cell.enableCardTableView()
//                let school = schools[indexPath.row]
//                if school.schoolName != "" {
//                    cell.schoolNameLabel.text = school.schoolName
//                }
//                if school.schoolLocation != "" {
//                    cell.schoolLocationButton.setTitle(school.schoolLocation, for: .normal)
//                }
//                if (school.schoolUID) != "" {
//                    cell.schoolUID = school.schoolUID
//                }
//                cell.customImageView.image = UIImage(named: "School")
//                cell.customImageView.isHidden = false
//                return cell
//            } else {
//                print("TRUE 3")
//                let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectToSchoolExtraCell", for: indexPath) as! ConnectToSchoolExtraTableViewCell
//                cell.infoLabel.text = "Can't Find Your School? Tap Here."
//                cell.selectionStyle = .gray
//                return cell
//            }
//        } else if (self.loadingSchools == true) {
//            print("TRUE 4")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectToSchoolExtraCell", for: indexPath) as! ConnectToSchoolExtraTableViewCell
//            cell.infoLabel.text = "Loading Your Schools..."
//            cell.selectionStyle = .none
//             return cell
//        } else {
//            print("TRUE 5")
//           let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectToSchoolInfoCell", for: indexPath) as! ConnectToSchoolInfoTableViewCell
//            return cell
//        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedCell = schools[indexPath.row]
        if (indexPath.row != self.schools.count + 1) {
            spinningActivity.label.text = "Loading"
            if reachabilityStatus == kNOTREACHABLE {
                spinningActivity.hide(animated: true)
                self.displayNetworkReconnection()
            } else {
                var values = [String : String]()
                if selectedCell.schoolUID != "" {
                    values["schoolUID"] = selectedCell.schoolUID
                }
                if selectedCell.schoolName != "" {
                    values["schoolName"] = selectedCell.schoolName
                    values["schoolNameLC"] = selectedCell.schoolName.lowercased()
                }
                if(selectedCell.schoolLocation != "") {
                    values["schoolLocation"] = selectedCell.schoolLocation
                }
                self.addSchoolToDatabase(values: values, type: "user")
            }
        } else {
            self.performSegue(withIdentifier: "addSchoolFromSignupSegue", sender: self)
        }
       
    }
    
    func addSchoolToDatabase(values: [String : String], type: String) {
        if (type == "user") {
            var userValues = values
            userValues.removeValue(forKey: "schoolLocation")
            let usersRef = databaseReference.child("Users").child("TTTTTT") // TODO: This won't work because of T's
            usersRef.updateChildValues(userValues, withCompletionBlock: { (error, ref) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                }
                self.addSchoolToDatabase(values: values, type: "school")
            })
        } else {
            let usersRef = databaseReference.child("Schools").childByAutoId()
            usersRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error {
                    self.displayError(title: "Error", message: error.localizedDescription)
                } else {
                    print("School Added")
//                self.performSegue(withIdentifier: "successfulSelectSchoolSegue", sender: self)
                }
            })
        }
        
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) { // If cancel button presses, dismiss keyboard and get rid of search text
        self.view.endEditing(true)
        searchBar.text = ""
    }
    
    func reachabilityStatusChanged() { // Constantly checks newtwork connection
        if reachabilityStatus == kNOTREACHABLE { // If there is no network connection
            self.displayNoNetworkConnection()
            self.noNetworkConnection = true
        } else if reachabilityStatus == kREACHABLEWITHWIFI || reachabilityStatus == kREACHABLEWITHWWAN { // If there is a network connection
            if noNetworkConnection == true { // Checks if there was no network connection before change -> user might have went from wifi to cellular or cellular to wifi (don't want to reprint the message
                self.displayNetworkReconnection()
                self.noNetworkConnection = false
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
    }
    
}
