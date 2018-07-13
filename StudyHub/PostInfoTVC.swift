//
//  PostInfoTVC.swift
//  StudyHub
//
//  Created by Dan Levy on 7/26/17.
//  Copyright © 2017 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class PostInfoTVC: UITableViewController {
    
    // MARK: Variables
    var post: Post?
    var comments = [Post]()
    var students = [Student]()
    var loading = Bool()
    var currentRow = Int()
    var interactionType = String()
    var profileGestureRecognizerUsed = Bool()
    
    // MARK: Basics
    /*
     * Handles the initialization of the view controller
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if self.checkNetwork() == true {
            self.getPostData()
        }
    }
    
    /*
     * Handles a memory warning
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Download Data
    /*
     * Reloads tableView with loading cell
     * Gets course posts
     * Uses DispatchGroup to wait for Firebase Firestore to get all data
     */
    func getPostData() {
        // Reloads tableView with loading cell
        self.loading = true
        self.tableView.reloadData()
        databaseReference.child("coursePostComments").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).observeSingleEvent(of: .value, with: { (snap) in
            var counter = Int()
            for child in snap.children.allObjects as! [DataSnapshot] {
                var postDetails = DataSnapshot()
                var taggedStudents = DataSnapshot()
                let postUID = child.key
                for child2 in child.children.allObjects as! [DataSnapshot] {
                    if (counter % 2 == 0) {
                        postDetails = child2
                    } else {
                        taggedStudents = child2
                    }
                    counter += 1
                }
                self.getPostDetails(postDetails: postDetails, taggedStudents: taggedStudents, postUID: postUID)
            }
            self.reloadData()
        }) { (error) in
            self.reloadData()
            self.displayError(title: "Error", message: error.localizedDescription)
        }
    }
    
    func getPostDetails(postDetails: DataSnapshot, taggedStudents: DataSnapshot, postUID: String) {
        if (postDetails.childrenCount > 0) {
            let children = postDetails.children.allObjects as! [DataSnapshot]
            var data = [String: Any]()
            for child in children {
                data[child.key] = child.value
            }
            data["uid"] = postUID
            let post = Post(data: data)
            self.comments.append(post)
            self.getPostTaggedStudents(post: post, taggedStudents: taggedStudents)
            self.getStudentProfileImage(post: post)
            self.getPostImages(post: post)
        }
    }
    
    func getPostTaggedStudents(post: Post, taggedStudents: DataSnapshot) {
        if (taggedStudents.childrenCount > 0) {
            var students = [Student]()
            let children = taggedStudents.children.allObjects as! [DataSnapshot]
            var data = [String: String]()
            for child in children {
                data = child.value as! [String: String]
                data["uid"] = child.key
                let student = Student(data: data)
                students.append(student)
            }
        }
        post.setTaggedStudents(students: self.students)
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }
    
    func getStudentProfileImage(post: Post) {
        storageReference.child("users").child("profileImages").child(post.studentUID + "profileImage").getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if (error == nil && data != nil) {
                if let image = UIImage(data: data!) {
                    post.setUserProfileImage(image: image)
                }
                let row = self.comments.index(of: post)
                if let row = row {
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none)
                }
            }
        }
    }
    
    func getPostImages(post: Post) {
        var errorCount = Int()
        var postImages = [UIImage]()
        var downloadCount = Int()
        for i in 1 ... post.numberOfImages {
            storageReference.child("coursePosts").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).child("image\(i)") .getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if (error == nil && data != nil) {
                    if let image = UIImage(data: data!) {
                        postImages.append(image)
                        downloadCount += 1
                    } else {
                        errorCount += 1
                    }
                    if (downloadCount == post.numberOfImages - errorCount) {
                        post.setImages(images: postImages)
                        let row = self.comments.index(of: post)
                        if let row = row {
                            self.tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .none)
                        }
                    }
                }
            }
        }
    }
    
    @objc func profileTapped(recognizer: UITapGestureRecognizer) {
        self.profileGestureRecognizerUsed = true
        self.currentRow = recognizer.view!.tag
        self.performSegue(withIdentifier: "postInfoTVCToStudentInfoTVCSegue", sender: self)
    }
    
    func commentButtonPressed(sender: UIButton) {
        //        self.performSegue(withIdentifier: "courseInfoTVCToPostInfoTVC", sender: self)
    }
    
    @objc func likeButtonPressed(sender: UIButton) {
        if (sender.currentImage == #imageLiteral(resourceName: "Heart Inactive")) {
            sender.setImage(#imageLiteral(resourceName: "Heart Active"), for: .normal)
            self.addLike(row: sender.tag)
        } else {
            sender.setImage(#imageLiteral(resourceName: "Heart Inactive"), for: .normal)
            self.removeLike(row: sender.tag)
        }
    }
    
    func shareButtonPressed(sender: UIButton) {
        
    }
    
    func addLike(row: Int) {
        var values = [String: String]()
        if let fullName = thisUser!.fullName {
            values["fullName"] = fullName
        }
        if let username = thisUser!.username {
            values["username"] = username
        }
        if let bio = thisUser!.bio {
            values["bio"] = bio
        }
        if (row > -1) {
            self.uploadCommentLike(row: row, values: values)
        } else {
            self.uploadPostLike(values: values)
        }
    }
    
    @objc func likesButtonPressed(sender: UIButton) {
        self.interactionType = "likes"
        self.performSegue(withIdentifier: "postInfoTVCToPostInteractionTVCSegue", sender: self)
    }
    
    @objc func taggedStudentsButtonPressed(sender: UIButton) {
        self.interactionType = "taggedStudents"
        self.performSegue(withIdentifier: "postInfoTVCToPostInteractionTVCSegue", sender: self)
    }
    
    func uploadPostLike(values: [String: String]) {
        databaseReference.child("coursePostLikes").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).child(self.post!.studentUID).updateChildValues(values)
    }
    
    func uploadCommentLike(row: Int, values: [String: String]) {
        let comment = self.comments[row]
        databaseReference.child("coursePostCommentLikes").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).child(comment.uid).child(thisUser!.uid!).updateChildValues(values)
    }
    
    func removeLike(row: Int) {
        if (row > -1) {
            self.uploadCommentUnlike(row: row)
        } else {
            self.uploadPostUnlike()
        }
    }
    
    func uploadPostUnlike() {
        databaseReference.child("coursePostLikes").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).child(self.post!.studentUID).removeValue()
    }
    
    func uploadCommentUnlike(row: Int) {
        let comment = self.comments[row]
        databaseReference.child("coursePostCommentLikes").child(self.post!.schoolUID).child(self.post!.departmentUID).child(self.post!.uid).child(self.post!.instructorUID).child(self.post!.uid).child(comment.uid).child(self.post!.studentUID).removeValue()
    }
    
    func sharesButtonPressed(sender: UIButton) {
        self.currentRow = sender.tag
        self.interactionType = "Shares"
        self.performSegue(withIdentifier: "postInfoTVCToPostInteractionTVCSegue", sender: self)
    }
    
    func reloadData() {
        self.loading = false
        self.tableView.reloadData()
    }
    
    func postInfoEmptyDataSet(tableView: UITableView, indexPath: IndexPath, title: String, description: String, image: UIImage) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoEmptyDataSetCell", for: indexPath) as! PostInfoEmptyDataSetCell
        let text = NSMutableAttributedString()
        text.append(newAttributedString(string: title, color: .black, stringAlignment: .center, fontSize: 25, fontWeight: UIFont.Weight.medium, paragraphSpacing: 15))
        text.append(newAttributedString(string: "\n" + description, color: .black, stringAlignment: .center, fontSize: 20, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        self.setUpTextView(textView: cell.textView)
        cell.textView.attributedText = text
        cell.largeImageView.image = image
        return cell
    }
    
    func postStudentInfo(post: Post) -> NSAttributedString {
        let info = NSMutableAttributedString()
        info.append(newAttributedString(string: post.studentFullName, color: .black, stringAlignment: .natural, fontSize: 19, fontWeight: UIFont.Weight.medium, paragraphSpacing: 10))
        info.append(newAttributedString(string: "\n" + post.studentUsername, color: .black, stringAlignment: .natural, fontSize: 17, fontWeight: UIFont.Weight.regular, paragraphSpacing: 0))
        return info
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1) {
            let header = tableView.dequeueReusableCell(withIdentifier: "postInfoHeaderCell") as! PostInfoHeaderCell
            return header
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1) {
            return 56
        } else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else if (self.loading == true) {
            return 1
        } else if (self.comments.count > 0) {
            return self.comments.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let images = self.post!.images
            if (images.count == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost0ImgCell", for: indexPath) as! PostInfoPost0ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = post!.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: post!)
                cell.postTextView.text = post!.text
                cell.likeButton.tag = indexPath.row
                cell.likesButton.tag = indexPath.row
                cell.taggedStudentsButton.tag = indexPath.row
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                cell.likesButton.addTarget(self, action: #selector(self.likesButtonPressed(sender:)), for: .touchUpInside)
                cell.taggedStudentsButton.addTarget(self, action: #selector(self.taggedStudentsButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            } else if (images.count == 3) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost3ImgCell", for: indexPath) as! PostInfoPost3ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = post!.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: post!)
                cell.postTextView.text = post!.text
                cell.likeButton.tag = indexPath.row
                cell.likesButton.tag = indexPath.row
                cell.taggedStudentsButton.tag = indexPath.row
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                cell.imageView0.image = images[0]
                cell.imageView1.image = images[1]
                cell.imageView2.image = images[2]
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                cell.likesButton.addTarget(self, action: #selector(self.likesButtonPressed(sender:)), for: .touchUpInside)
                cell.taggedStudentsButton.addTarget(self, action: #selector(self.taggedStudentsButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost5ImgCell", for: indexPath) as! PostInfoPost5ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = post!.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: post!)
                cell.postTextView.text = post!.text
                cell.likeButton.tag = indexPath.row
                cell.likesButton.tag = indexPath.row
                cell.taggedStudentsButton.tag = indexPath.row
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                if (images.count == 1) {
                    cell.imageView0.image = images[0]
                } else if (images.count == 2) {
                    cell.imageView1.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                } else if (images.count == 4) {
                    cell.bottomStackView.isHidden = false
                    cell.imageView1.isHidden = false
                    cell.imageView2.isHidden = false
                    cell.imageView3.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                    cell.imageView2.image = images[2]
                    cell.imageView3.image = images[3]
                } else {
                    cell.bottomStackView.isHidden = false
                    cell.imageView1.isHidden = false
                    cell.imageView2.isHidden = false
                    cell.imageView3.isHidden = false
                    cell.imageView4.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                    cell.imageView2.image = images[2]
                    cell.imageView3.image = images[3]
                    cell.imageView4.image = images[4]
                }
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                cell.likesButton.addTarget(self, action: #selector(self.likesButtonPressed(sender:)), for: .touchUpInside)
                cell.taggedStudentsButton.addTarget(self, action: #selector(self.taggedStudentsButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            }
        } else if (self.loading == true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoLoadingCell", for: indexPath) as! PostInfoLoadingCell
            cell.activityIndicator.startAnimating()
            return cell
        } else if (self.comments.count > 0) {
            let comment = self.comments[indexPath.row]
            let images = comment.images
            if (images.count == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost0ImgCell", for: indexPath) as! PostInfoPost0ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = comment.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: comment)
                cell.postTextView.text = comment.text
                let buttons = [cell.likeButton]
                for button in buttons {
                    button!.tag = indexPath.row
                }
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            } else if (images.count == 3) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost3ImgCell", for: indexPath) as! PostInfoPost3ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = comment.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: comment)
                cell.postTextView.text = comment.text
                let buttons = [cell.likeButton]
                for button in buttons {
                    button!.tag = indexPath.row
                }
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                cell.imageView0.image = images[0]
                cell.imageView1.image = images[1]
                cell.imageView2.image = images[2]
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postInfoPost3ImgCell", for: indexPath) as! PostInfoPost5ImgCell
                cell.enableCustomCellView(bgView: cell.bgView, bgViewColor: .white)
                cell.profileImageView.image = comment.studentProfileImage
                self.setUpTextView(textView: cell.profileTextView)
                self.setUpTextView(textView: cell.postTextView)
                cell.profileTextView.attributedText = self.postStudentInfo(post: comment)
                cell.postTextView.text = comment.text
                let buttons = [cell.likeButton]
                for button in buttons {
                    button!.tag = indexPath.row
                }
                cell.profileImageView.tag = indexPath.row
                cell.profileTextView.tag = indexPath.row
                if (images.count == 1) {
                    cell.imageView0.image = images[0]
                } else if (images.count == 2) {
                    cell.imageView1.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                } else if (images.count == 4) {
                    cell.bottomStackView.isHidden = false
                    cell.imageView1.isHidden = false
                    cell.imageView2.isHidden = false
                    cell.imageView3.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                    cell.imageView2.image = images[2]
                    cell.imageView3.image = images[3]
                } else {
                    cell.bottomStackView.isHidden = false
                    cell.imageView1.isHidden = false
                    cell.imageView2.isHidden = false
                    cell.imageView3.isHidden = false
                    cell.imageView4.isHidden = false
                    cell.imageView0.image = images[0]
                    cell.imageView1.image = images[1]
                    cell.imageView2.image = images[2]
                    cell.imageView3.image = images[3]
                    cell.imageView4.image = images[4]
                }
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(sender:)), for: .touchUpInside)
                let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileImageView.addGestureRecognizer(profileImageGestureRecognizer)
                let profileTextViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileTapped(recognizer:)))
                cell.profileTextView.addGestureRecognizer(profileTextViewGestureRecognizer)
                return cell
            }
        } else {
            return self.postInfoEmptyDataSet(tableView: self.tableView, indexPath: indexPath, title: "Comments", description: "This post doesn't have any comments", image: #imageLiteral(resourceName: "Posts"))
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "postInfoTVCToStudentInfoTVCSegue") {
//            if (self.currentRow == -1) {
//                let destVC = segue.destination as! StudentInfoTVC
//                destVC.post = self.post!
//            } else {
//                let comment = self.comments[self.currentRow]
//                let destVC = segue.destination as! StudentInfoTVC
//                destVC.post = comment
//            }
//        } else if (segue.identifier == "postInfoTVCToPostInteractionTVCSegue") {
//            let destVC = segue.destination as! PostInteractionTVC
//            destVC.post = self.post!
//            destVC.interaction = self.interactionType
//        }
//    }
}
