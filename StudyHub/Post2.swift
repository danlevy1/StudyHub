//
//  Post.swift
//  StudyHub
//
//  Created by Dan Levy on 12/29/16.
//  Copyright © 2016 Dan Levy. All rights reserved.
//

import UIKit
import Firebase

class Post2: Equatable {
    private var _uid: String?
    private var _numberOfComments: Int?
    private var _numberOfLikes: Int?
    private var _numberOfTaggedStudents: Int?
    private var _text: String?
    private var _student: Student2?
    private var _images: [UIImage]?
    private var _taggedStudents: [Student]?
    private var _liked: Bool?
    private var _imagePaths: [String]?
    private var _ref: DocumentReference?
    
    init(uid: String?, numComments: Int?, numLikes: Int?, numTagged: Int?, text: String?, imagePaths: [String]?, ref: DocumentReference?) {
        self._uid = uid
        self._numberOfComments = numComments
        self._numberOfLikes = numLikes
        self._numberOfTaggedStudents = numTagged
        self._text = text
        self._student = nil
        self._images = nil
        self._taggedStudents = nil
        self._liked = nil
        self._imagePaths = imagePaths
        self._ref = ref
    }
    
    func getUID() -> String? {
        return self._uid
    }
    func getNumComments() -> Int? {
        return self._numberOfComments
    }
    func getNumLikes() -> Int? {
        return self._numberOfLikes
    }
    func getNumTagged() -> Int? {
        return self._numberOfTaggedStudents
    }
    func getText() -> String? {
        return self._text
    }
    func getStudent() -> Student2? {
        return self._student
    }
    func getImages() -> [UIImage]? {
        return self._images
    }
    func getTaggedStudents() -> [Student]? {
        return self._taggedStudents
    }
    func isLiked() -> Bool? {
        return self._liked
    }
    func getImagePaths() -> [String]? {
        return self._imagePaths
    }
    func getRef() -> DocumentReference? {
        return self._ref
    }
    
    func setTaggedStudents(students: [Student]?) {
        self._taggedStudents = students
    }
    func setLiked(liked: Bool?) {
        self._liked = liked
    }
    func setStudent(student: Student2?) {
        self._student = student
    }
    func addImage(image: UIImage) {
        if (self._images == nil) {
            self._images = [UIImage]()
        }
        self._images!.append(image)
    }
}

func == (lhs: Post, rhs: Post) -> Bool {
    return lhs.uid == rhs.uid
}



