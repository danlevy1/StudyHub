//
//  HomeTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/4/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import MBProgressHUD
import SCLAlertView
import ReachabilitySwift

class HomeTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: Variables
    var posts = [Post]()
    var loadingPosts = Bool()
    var noPosts = Bool()
    var getPostsSuccessfully = Bool()
    var noNetworkConnection = Bool()
    
    // MARK: Outlets
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    
    // MARK: Actions
    

    @IBAction func postBarButtonItemPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "homeTVCToChooseCourseTVCSegue", sender: self)
    }

    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavBar(navItem: self.navigationItem, navController: self.navigationController!)
        self.setUpTableView(tableView: self.tableView)
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            //            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "Posts")
    }
    
//    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
//        return UIImage(named: "Plus Button")
//    }
//
//    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
//        self.performSegue(withIdentifier:"addClassFromHomeVC", sender: self)
//    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "Posts", fontSize: 25, fontWeight: UIFontWeightMedium)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.emptyDataSetString(string: "There aren't any posts in your courses. Create a post to add to the feed!", fontSize: 20, fontWeight: UIFontWeightRegular)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
}
