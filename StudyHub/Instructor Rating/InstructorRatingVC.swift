//
//  InstructorRatingVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/10/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

/*
 * Allows ueser to rate an instructor
 * Rating includes rating (1 to 5), review, and recommendation
 */

import UIKit
import Firebase
import SCLAlertView
import MBProgressHUD
import NVActivityIndicatorView

class InstructorRatingVC: UIViewController, UITextViewDelegate {
    // MARK: Variables
    var instructor: Instructor2!
    var selectedCourses = [Course]()
    var rating = 1
    var ratingChanged = Bool()
    var recommends: Bool?
    var progressHUD: MBProgressHUD?
    var activityView: NVActivityIndicatorView?
    
    // MARK: Outlets
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var reviewTextField: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: Actions
    /*
     * Dismisses view controller
     */
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Calls updateStars
     */
    @IBAction func ratingSliderValueDidChange(_ sender: Any) {
        self.getRating()
    }
    
    /*
     * Calls recommendsButtonPressed
     */
    @IBAction func yesButtonPressed(_ sender: Any) {
        self.recommends = true
        self.recommendsButtonPressed(buttonPressed: self.yesButton, otherButton: self.noButton, color: .green)
    }
    
    /*
     * Calls recommendsButtonPressed
     */
    @IBAction func noButtonPressed(_ sender: Any) {
        self.recommends = false
        self.recommendsButtonPressed(buttonPressed: self.noButton, otherButton: self.yesButton, color: .red)
    }
    
    /*
     * Calls checkRatingChanged
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.checkRatingChanged()
    }
    
    // MARK: Basics
    /*
     * Calls methods
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
     * Dismisses keyboard on tap outside UITextView
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
     * Dismisses keyboard on scroll of UITextView
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    /*
     * Sets up UIGestureRecognizer for rating slider
     * Sets character count label to 500
     * Rounds next button
     */
    func setUpObjects() {
        let ratingSliderRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.ratingSliderMoved(recognizer:)))
        self.ratingSlider.addGestureRecognizer(ratingSliderRecognizer)
        self.characterCountLabel.text = "500"
        self.nextButton.layer.cornerRadius = 10
        self.nextButton.clipsToBounds = true
        self.setUpButton(button: self.yesButton)
        self.setUpButton(button: self.noButton)
    }
    
    /*
     * Rounds recommendation button
     */
    func setUpButton(button: UIButton) {
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
    }
    
    // MARK: Rating Slider
    /*
     * Gets location of slider
     * Sets the value of the slider
     */
    @objc func ratingSliderMoved(recognizer: UIGestureRecognizer) {
        // Gets location of slider
        let pointTapped: CGPoint = recognizer.location(in: self.view)
        let positionOfSlider: CGPoint = self.ratingSlider.frame.origin
        let widthOfSlider: CGFloat = self.ratingSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(self.ratingSlider.maximumValue) / widthOfSlider)
        self.ratingSlider.setValue(Float(newValue), animated: false) // Changes value of slider
        self.getRating()
    }
    
    /*
     * Gets rating from rating slider value
     */
    func getRating() {
        self.ratingChanged = true
        let value = ceilf(self.ratingSlider.value)
        if (value < 1.5) {
            self.rating = 1
        } else if (value >= 1.5 && value < 2.5) {
            self.rating = 2
            self.star5.image = #imageLiteral(resourceName: "Rating Star Inactive")
        } else if (value >= 2.5 && value < 3.5) {
            self.rating = 3
        } else if (value >= 3.5 && value < 4.5) {
            self.rating = 4
        } else {
            self.rating = 5
        }
        self.updateStars()
    }
    
    /*
     * Updates rating stars' images
     */
    func updateStars() {
        let stars = [self.star2, self.star3, self.star4, self.star5] // Image 1 is always yellow
        var counter = 1
        for star in stars { // Loops trhough stars
            if counter < self.rating { // Checks if star should be yellow
                star!.image = #imageLiteral(resourceName: "Rating Star Active")
            } else { // Star should be white
                star!.image = #imageLiteral(resourceName: "Rating Star Inactive")
            }
            counter += 1
        }
    }
    
    // MARK: Recommendation Buttons
    /*
     * Updates recommendation buttons' colors
     */
    func recommendsButtonPressed(buttonPressed: UIButton, otherButton: UIButton, color: UIColor) {
        buttonPressed.setTitleColor(color, for: .normal)
        buttonPressed.layer.borderColor = color.cgColor
        otherButton.setTitleColor(.white, for: .normal)
        otherButton.layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: Review Text View
    /*
     * Updates character count label
     */
    func textViewDidChange(_ textView: UITextView) {
        let count = 500 - textView.text.count
        if (count >= 0) { // Checks if count is within limits (0+ characters left)
            self.characterCountLabel.textColor = .white
        } else { // Count is outside limits (1+ characters over)
            self.characterCountLabel.textColor = .red
        }
        self.characterCountLabel.text = String(count)
    }
    
    // MARK: Upload Data
    /*
     * Checks if rating was changed
     */
    func checkRatingChanged() {
        if (self.ratingChanged) { // Checks if rating was changed
            self.checkData()
        } else { // Rating was not changed (left at 1)
            // Displays alert view
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Yes", action: {
                alertView.dismiss(animated: true, completion: nil)
                self.checkData()
            })
            alertView.addButton("No", action: {
                alertView.dismiss(animated: true, completion: nil)
            })
            alertView.showInfo("Rating", subTitle: "It looks like you didn't change your rating. Would you like to rate this instructor with a 1 out of 5?")
        }
    }
    
    /*
     * Checks that review is between 10 and 500 characters
     * Checks that recommendation was selected
     */
    func checkData() {
        if (self.reviewTextField.text.count >= 500) { // Checks if review is 501+ characters long
            self.displayError(title: "Error", message: "Please limit your review to 500 characters or less")
        } else if (self.reviewTextField.text.count < 10) { // Checks if review is between 0 and 10 characters long
            self.displayError(title: "Error", message: "Your review must be at least 10 characters long")
        } else if (self.recommends == nil) { // Checks if recommeds instructor exists
            self.displayError(title: "Error", message: "Please select whether you recommend this instructor or not")
        } else { // All data is correct
            self.uploadReview()
        }
    }
    
    /*
     * Displays a progress HUD
     * Uploads rating data to Firebase Firestore
     */
    func uploadReview() {
        // Displays progress HUD
        self.activityView = self.customProgressHUDView()
        self.progressHUD = self.startProgressHUD(activityView: self.activityView!, view: self.view)
        if let userRef = thisUser?.ref as? DocumentReference {
            let data = ["rating": self.rating, "review": self.reviewTextField.text!, "recommends": self.recommends!, "userRef": userRef] as [String : Any]
            if let instructorRef = self.instructor.getRef() { // Tries to get instructor ref
                instructorRef.collection("ratings").document().setData(data, completion: { (error) in
                    if let error = error { // Checks for an error
                        self.displayError(title: "Error", message: error.localizedDescription)
                    } else { // No error
                        self.success()
                    }
                })
            } else {
                self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
            }
        } else {
            self.displayError(title: "Error", message: "Something went wrong. Please try again later.")
        }
    }
    
    /*
     * Displays success banner
     * Removes progress HUD
     * Dismisses view controller after six seconds
     */
    func success() {
        self.displayBanner(title: "Success!", subtitle: "Your rating has been added", style: .success)
        self.stopProgressHUD(progressHUD: self.progressHUD!, activityView: self.activityView!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(6), execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
}
