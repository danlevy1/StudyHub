func setUpTextView(textView: UITextView) {
    textView.isUserInteractionEnabled = false;
    textView.textContainerInset = UIEdgeInsets.zero
}

func sectionInfo() -> NSAttributedString {
    let attributedText = NSMutableAttributedString()
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.paragraphSpacing = 15
    attributedText.append(NSAttributedString(string: self.course.name, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25),NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black]))
    attributedText.append(NSAttributedString(string: "\nSection: " + self.section.number, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: UIColor.black]))
    attributedText.append(NSAttributedString(string: "\n" + self.section.instructorName, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: UIColor.black]))
    attributedText.append(NSAttributedString(string: "\n" + self.section.schedule, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 25), NSParagraphStyleAttributeName: paragraphStyle ,NSForegroundColorAttributeName: UIColor.black]))
    return attributedText
}

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if (self.loading == true) {
        return 1
    } else if (self.segmentedControlValue == 0) {
        return self.posts.count + 1
    } else {
        return self.students.count
    }
}

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (self.loading == true) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loadingSectionCell", for: indexPath) as! LoadingCourseInformationTableViewCell
        cell.activityIndicator.startAnimating()
        return cell
    } else {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionInfoCell", for: indexPath) as! CourseInformationTableViewCell
            self.setUpTextView(textView: cell.courseInfoTextView)
            cell.courseInfoTextView.attributedText = self.sectionInfo()
            return cell
        } else if (self.segmentedControlValue == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionPostsCell", for: indexPath) as! CourseSectionsTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sectionPostsCell", for: indexPath) as! CourseSectionsTableViewCell
            return cell
        }
    }
}
