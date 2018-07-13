//
//  ConnectToSocialHelpTableViewController.swift
//  StudyHub
//
//  Created by Dan Levy on 11/19/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit

class ConnectToSocialHelpTableViewController: UITableViewController {
    
    // MARK: Variables
    var dataDictionary = [
        ["title":"Facebook", "details":"To find your username: Go to Facebook.com and log in. Click on your name to the right of the 'Search Facebook' bar. Click the URL bar (search bar) at the top of your browser and copy all the text EXCEPT for 'https://www.facebook.com/'. That is your username!","textColor":facebookColor, "image":#imageLiteral(resourceName: "Facebook Logo")],
        ["title":"Twitter", "details":"To find your username: Go to Twitter.com and log in. On the left pannel of the website, look for your profile picture. To the left of your profile picture is your name in bold. Below your name is your username. DO NOT include the '@' symbol.","textColor":twitterColor, "image":#imageLiteral(resourceName: "Twitter Logo")],
        ["title":"Instagram", "details":"To find your username: Go to Instagram.com and log in. On the top bar, look for the image of a person's face and upper-chest. Click on that logo. The text to the left of the 'Edit Profile' button is your username.", "textColor":instagramColor, "image":#imageLiteral(resourceName: "Instagram Logo")],
        ["title":"VSCO", "details":"To find your username: Go to VSCO.com and click on 'Sign in'. Your username replaces the 'Sign in' button.","textColor":tumblrColor, "image":#imageLiteral(resourceName: "VSCO Logo")]
        // TODO: Trade tumblrColor for vsco color
    ]
    
    // MARK: Actions
    
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize Navigation Bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = studyHubColor
        // Set up Table View
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = studyHubColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataDictionary.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "connectToSocialAccountSetupHelpCell", for: indexPath) as! ConnectToSocialHelpTableViewCell
        
        let data = dataDictionary[indexPath.row]
        cell.titleLabel.text = data["title"] as! String?
        cell.titleLabel.textColor = data["textColor"] as! UIColor!
        cell.detailsLabel.text = data["details"] as! String?
        // TODO: Get corner radius to work
        cell.socialLogoImageView.layer.cornerRadius = cell.socialLogoImageView.frame.width / 2
        cell.socialLogoImageView.image = data["image"] as! UIImage?
        cell.enableCustomCellView(bgView: cell.backgroundCardView, bgViewColor: UIColor.white)
        cell.selectionStyle = .none
        
        return cell
    }
}
