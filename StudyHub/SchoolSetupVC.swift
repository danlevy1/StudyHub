//
//  SchoolSetupVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/20/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows user to search for their school
 * Checks if the school is already in Firebase Firestore
 * Adds the school to Firebase Firestore (if needed)
 * Adds a reference to the school in the user's profile
 */

import UIKit
import MapKit
import SCLAlertView
import Firebase
import MBProgressHUD
import NVActivityIndicatorView

class SchoolSetupVC: UIViewController, UISearchBarDelegate {
    
    // MARK: Variables
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    var place: CLPlacemark?
    
    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Actions
    /*
     * Allows user to contact support
     */
    @IBAction func helpBarButtonItemPressed(_ sender: Any) {
        // TODO: Set up alert view
    }
    
    /*
     * Checks that a place was found
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        if (self.place != nil) {
            self.getSchool()
        } else {
            self.displayError(title: "Error", message: "Please find your school first")
        }
    }
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpObjects()
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Rounds the corners on the next button
     */
    func setUpObjects() {
        self.nextButton.layer.cornerRadius = 10
        self.nextButton.clipsToBounds = true
    }
    
    // MARK: Search
    /*
     * Dismisses the keyboard
     * Checks that there is text in the search bar
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if (searchBar.text!.count > 0) {
            self.getLocation()
        } else {
            self.displayError(title: "Error", message: "Please search for your school using the search bar")
        }
    }
    
    /*
     * Finds the location using Apple Maps
     * Displays a progress HUD
     */
    func getLocation() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        CLGeocoder().geocodeAddressString(self.searchBar.text!) { (places, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                let place = places?.first // Gets the first place
                if (place != nil) { // Checks that a place exists
                    self.place = place
                    self.moveToLocation()
                    self.displaySchoolInfo()
                } else {
                    self.displayError(title: "Error", message: "This school was not found. Please try searching for its full name.")
                }
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            }
        }
    }
    
    /*
     * Zooms map into location
     * Sets annotation to place's name
     */
    func moveToLocation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.place!.location!.coordinate
        annotation.title = self.place!.name!
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        self.map.setRegion(region, animated: true)
        self.map.addAnnotation(annotation)
        self.map.selectAnnotation(annotation, animated: true)
    }
    
    /*
     * Collects info from place
     * Displays info in school label
     */
    func displaySchoolInfo() {
        var location = String()
        if let name = self.place!.name {
            location.append(name + " in ")
        }
        if let city = self.place!.locality {
            location.append(city + ", ")
        }
        if let state = self.place!.administrativeArea {
            location.append(state)
        }
        self.schoolLabel.text = location
    }
    
    // MARK: Add School
    /*
     * Displays a progress HUD
     * Tries to find the school's name in Firebase
     * Adds the school if not found
     */
    func getSchool() {
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        firestoreRef.collection("schools").whereField("name", isEqualTo: self.place!.name!).getDocuments { (snap, error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                if (snap!.count > 0) {
                    if (snap!.count == 1) {
                        let school = snap!.documents.first!
                        if (self.checkSchoolOnDatabase(school: school) == true) { // Checks for a match
                            self.addSchoolValues(school: school)
                            return
                        }
                    } else { // Multiple schools found
                        for school in snap!.documents {
                            if (self.checkSchoolOnDatabase(school: school)) {
                                self.addSchoolValues(school: school)
                                return
                            }
                        }
                    }
                }
                self.getSchoolData() // Creates a new school if one was not found
            }
        }
    }
    
    /*
     * Checks that school's latitude and longitude match the location found
     */
    func checkSchoolOnDatabase (school: DocumentSnapshot) -> Bool {
        if let location = school.data()!["coordinates"] as? GeoPoint {
            if (location.latitude == self.place!.location!.coordinate.latitude && location.longitude == self.place!.location!.coordinate.longitude) {
                return true
            }
        }
        return false
    }
    
    /*
     * Gets the data to be added to the user's account
     */
    func addSchoolValues(school: DocumentSnapshot) {
        self.addSchoolToUser(schoolRef: school.reference)
    }
    
    /*
     * Gets all needed information from the place
     */
    func getSchoolData() {
        var values = [String: Any]()
        values["name"] = self.place!.name!
        if let city = self.place!.locality {
            values["city"] = city
        }
        if let state = self.place!.administrativeArea {
            values["state"] = state
        }
        if let countryCode = self.place!.isoCountryCode {
            values["countryCode"] = countryCode
        }
        if let postalCode = self.place!.postalCode {
            values["postalCode"] = postalCode
        }
        values["coordinates"] = GeoPoint(latitude: self.place!.location!.coordinate.latitude, longitude: self.place!.location!.coordinate.longitude)
        self.addSchoolToDatabase(values: values)
    }
    
    /*
     * Adds the school to the Firebase realtime database
     * Gets the place's name
     * Gets the school's new uid
     */
    func addSchoolToDatabase(values: [String: Any]) {
        let schoolRef = firestoreRef.collection("schools").document()
        schoolRef.setData(values) { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            }
            else {
                self.addSchoolToUser(schoolRef: schoolRef)
            }
        }
    }
    
    /*
     * Adds the school's name and uid to the user's account
     * Removes the progress HUD
     * Moves the user out of the authentication flow
     */
    func addSchoolToUser(schoolRef: DocumentReference) {
        firestoreRef.collection("users").document(currentUser!.uid).updateData(["school": schoolRef]) { (error) in
            if let error = error {
                self.displayError(title: "Error", message: error.localizedDescription)
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
            } else {
                self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
                self.displayBanner(title: "Success!", subtitle: "Your account has been created", style: .success)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: { // Moves user to home vc
                    self.performSegue(withIdentifier: "schoolSetupVCToHomeTVCSegue", sender: self)
                })
            }
        }
    }
}
