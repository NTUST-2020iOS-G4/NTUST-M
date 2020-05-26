//
//  User.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/20.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import Foundation

class moodleUser {
    var userid: Int
    var fullname: String
    var userPictureURL: URL
    var userPictureMiniURL: URL
    var courses: [moodleCourse]?
    
    init(userid: Int, fullname: String, userPictureURL: URL, userPictureMiniURL: URL) {
        self.userid = userid
        self.fullname = fullname
        self.userPictureURL = userPictureURL
        self.userPictureMiniURL = userPictureMiniURL
    }
}
