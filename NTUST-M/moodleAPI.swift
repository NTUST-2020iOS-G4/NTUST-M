//
//  moodleAPI.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/20.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import KeychainSwift
import Firebase
import FirebaseFirestore

class moodleAPI: NSObject {
    
    // MARK: moodleURL
    let moodleURL = "https://moodle.ntust.edu.tw/"
    let moodleTokenURL = "login/token.php?service=moodle_mobile_app"
    let moodleWebServiceURL = "webservice/rest/server.php"
    
    // MARK: parameter
    var userToken: String?
    
    enum APIFunction: String {
        case getSiteInfo = "core_webservice_get_site_info"
        case getUserByField = "core_user_get_users_by_field"
        case getUsersByKeyword = "core_message_search_contacts"
        case getCourseEnrollUsers = "core_enrol_get_enrolled_users"
        case getUserCommonCourses = "core_enrol_get_users_courses"
        case getCoursesEvents = "core_calendar_get_calendar_events"
    }

    enum APIUserField: String {
        case id = "id"
        case email = "email"
    }
    
    // MARK: CoreData Context
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: Firebase Cloud FireStore
    var db: Firestore!
    
    // MARK: setUserToken
    // this token is used for access moodle web service
    func setUserToken(parameters: Parameters?, completion: @escaping (_: Bool, _ error: String?) -> ()) {
        AF.request(moodleURL + moodleTokenURL, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if json["token"].exists() {
                    self.userToken = json["token"].string
                    
                    let keychain = KeychainSwift()
                    keychain.synchronizable = true
                    
                    if keychain.set(self.userToken!, forKey: "moodleToken") {
                        print("Keychain: moodleToken set success")
                    }
                    
                    if let username = parameters!["username"] as? String {
                        if keychain.set(username, forKey: "username") {
                            print("Keychain: Username set success")
                        }
                        
                    }
                    
                    if let password = parameters!["password"] as? String {
                        if keychain.set(password, forKey: "password") {
                            print("Keychain: Password set success")
                        }
                    }
                    
                    print("User token request success")
                    completion(true, nil)
                } else if json["error"].exists() {
                    print("User token request failed: \(json["error"])")
                    completion(false, json["error"].string)
                } else {
                    print("Unknow error")
                    completion(false, "Unknow error")
                }
            case .failure(let error):
                print("User token Request failed with error: \(error)")
                completion(false, error.errorDescription)
            }
        }
    }
    
    // MARK: getSelfMoodleID
    // get own user moodleID
    // TODO: Error Handling
    func getSelfMoodleID(completion: @escaping (_: Int?) -> ()) {

        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getSiteInfo.rawValue,
            "moodlewsrestformat": "json",
        ]
        
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                let userID = json["userid"].intValue
                print("get user MoodleID success: \(userID)")
                completion(userID)
    
            case .failure(let error):
                print("get user MoodleID failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: getUserInfo
    // get user infomation by moodleID / email field
    // TODO: Error Handeling
    func getUserInfo(searchField: moodleAPI.APIUserField, value: Any, completion: @escaping (_: User?) -> ()) {

        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getUserByField.rawValue,
            "moodlewsrestformat": "json",
            "field": searchField.rawValue,
            "values[0]": value,
        ]
        
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                
                let coreDataConnect = CoreDataConnect(context: self.myContext)
                let userPredicate = NSPredicate(format: "userID = \(json[0]["id"].intValue)")
                
                var tempUser: User!
                
                if let foundUser = coreDataConnect.find("User", predicate: userPredicate) as? User {
                    // use exist user
                    tempUser = foundUser
                } else {
                    // insert new user
                    tempUser = User(context: self.myContext)
                }
                
                // update user data
                tempUser.userID = Int64(json[0]["id"].intValue)
                tempUser.fullname = json[0]["fullname"].stringValue
                tempUser.userPictureURL = json[0]["profileimageurl"].url!
                tempUser.userPictureMiniURL = json[0]["profileimageurlsmall"].url!
                
                // save context
                do {
                    try self.myContext.save()
                } catch {
                    fatalError("\(error)")
                }
                
                print("get userInfo success: \(value)")
                
                completion(tempUser)
    
            case .failure(let error):
                print("get userInfo \(value) failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: searchUsersInfo
    // search users infomation by keyword
    // TODO: Error Handling
    func searchUsersInfo(searchtext: String, completion: @escaping (_: [User]?) -> ()) {

        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getUsersByKeyword.rawValue,
            "moodlewsrestformat": "json",
            "searchtext": searchtext,
        ]
        
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let users = json.array {
                    for user in users {
                        print(user["fullname"].stringValue)
                    }
                }
                completion(nil)
            case .failure(let error):
//                print("get userInfo \(value) failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: getCourseEnrollUsers
    // get enroll users info by course id
    func getCourseEnrollUsers(courseid: Int, completion: @escaping (_: [User]?) -> ()) {

        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getCourseEnrollUsers.rawValue,
            "moodlewsrestformat": "json",
            "courseid": courseid,
        ]
        
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let users = json.array {
                    for user in users {
                        print(user["fullname"].stringValue)
                    }
                }
                completion(nil)
                
    
            case .failure(let error):
//                print("get userInfo \(value) failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    // MARK: getUserCommonCourses
    // get common courses with user
    func loadUserCommonCourses(user: User, completion:  ((_: Bool, _ error: String?) -> Void)? = nil) {
        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getUserCommonCourses.rawValue,
            "moodlewsrestformat": "json",
            "userid": user.userID,
        ]
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let coreDataConnect = CoreDataConnect(context: self.myContext)
                
                // Append new data
                let json = JSON(data)
                if let courses = json.array {
                    // initial firebase
                    self.db = Firestore.firestore()
                    
                    var courseCount = 0
                    for course in courses {
                        // insert new course
                        let idnumber = course["idnumber"].stringValue
                        let idnumberIndex = idnumber.index(idnumber.startIndex, offsetBy: 4)
                        let semester = Int64(idnumber[..<idnumberIndex])!
                        let code = String(idnumber[idnumberIndex...])
                        
                        self.db.collection("\(semester)_Course").document(code).getDocument { (document, error) in
                            if let document = document, document.exists {
                                let coursePredicate = NSPredicate(format: "code = '\(code)' && semester = \(semester)")
                                
                                var tempCourse: Course!
                                
                                if let foundCourse = coreDataConnect.find("Course", predicate: coursePredicate) as? Course {
                                    // use exist course ignore update data
                                    tempCourse = foundCourse
                                    print("\(course["fullname"].stringValue): already exist")
                                } else {
                                    // insert new course
                                    tempCourse = Course(context: self.myContext)
                                    tempCourse.moodleID = Int64(course["id"].intValue)
                                    tempCourse.semester = semester
                                    tempCourse.code = code
                                    
                                    let courseData = document.data()
                                    tempCourse.title = courseData?["Title"] as? String
                                    tempCourse.credits = courseData?["Credits"] as! Int64
                                    tempCourse.instructor = courseData?["Instructor"] as? String
                                    tempCourse.registered = courseData?["Registered"] as! Int64
                                    
                                    for (classroom, times) in courseData!["LocationTime"] as! [String : [String]] {
                                        let classroomPredicate = NSPredicate(format: "classroom = '\(classroom)'")
                                        var tempClassroom: Location!
                                        if let foundClassroom = coreDataConnect.find("Location", predicate: classroomPredicate) as? Location {
                                            // use exist classroom ignore new data
                                            tempClassroom = foundClassroom
                                        } else {
                                            // insert new classroom
                                            tempClassroom = Location(context: self.myContext)
                                            tempClassroom.classroom = classroom
                                        }
                                        
                                        for time in times {
                                            let timeIndex = time.index(time.startIndex, offsetBy: 1)
                                            let tempPeriod = Period(context: self.myContext)
                                            tempPeriod.day = String(time[..<timeIndex])
                                            tempPeriod.period = String(time[timeIndex...])
                                            tempPeriod.classroom = tempClassroom
                                            tempCourse.addToTime(tempPeriod)
                                        }
                                    }
                                    print("\(course["fullname"].stringValue): success added")
                                }
                                tempCourse.addToEnrolledUsers(user)
                                
                            } else {
                                print("\(course["fullname"].stringValue): not exist")
                            }
                            courseCount += 1
                            if (courseCount >= courses.count) {
                                // save context
                                do {
                                    try self.myContext.save()
                                } catch {
                                    fatalError("\(error)")
                                }
                                if completion != nil {
                                    completion!(true, nil)
                                }
                            }
                        }
                    }
                    
                }
            case .failure(let error):
                if completion != nil {
                    completion!(false, error.errorDescription)
                }
            }
        }
    }
    
    // MARK: getCoursesEvents
    // get Events info by courseid
    func getCoursesEvents(courseid: [Int], completion: @escaping (_: [User]?) -> ()) {
        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getCoursesEvents.rawValue,
            "moodlewsrestformat": "json",
            "events": [
                "courseids": courseid,
            ],
            "options": [
                "timestart": Int(NSDate().timeIntervalSince1970),
            ],
        ]
//        print(para["events"]!)
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let events = json["events"].array {
                    for event in events {
                        print(event["name"].stringValue)
                    }
                }
                completion(nil)
            case .failure(let error):
//                print("get userInfo \(value) failed with error: \(error)")
                completion(nil)
            }
        }
    }
}
