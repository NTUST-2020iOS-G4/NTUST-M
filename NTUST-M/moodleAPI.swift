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
    
    // MARK: setUserToken
    // this token is used for access moodle web service
    func setUserToken(parameters: Parameters?, completion: @escaping (_: Bool) -> ()) {
        AF.request(moodleURL + moodleTokenURL, method: .post, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if json["token"].exists() {
                    self.userToken = json["token"].string
                    
                    let keychain = KeychainSwift()
                    keychain.synchronizable = true
                    
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
                    completion(true)
                } else if json["error"].exists() {
                    print("User token request failed: \(json["error"])")
                    completion(false)
                } else {
                    print("Unknow error")
                    completion(false)
                }
            case .failure(let error):
                print("User token Request failed with error: \(error)")
                completion(false)
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
                let myEntityName = "User"
                let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let tempUser = NSEntityDescription.insertNewObject(forEntityName: myEntityName, into: myContext) as! User
                tempUser.userID = Int64(json[0]["id"].intValue)
                tempUser.fullname = json[0]["fullname"].stringValue
                tempUser.userPictureURL = json[0]["profileimageurl"].url!
                tempUser.userPictureMiniURL = json[0]["profileimageurlsmall"].url!
                print("get userInfo success: \(value)")
                completion(tempUser)
//                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
////                    let user = User(context: appDelegate.persistentContainer.viewContext)
////                    user.userID = Int64(json[0]["id"].intValue)
////                    user.fullname = json[0]["fullname"].stringValue
////                    user.userPictureURL = json[0]["profileimageurl"].url!
////                    user.userPictureMiniURL = json[0]["profileimageurlsmall"].url!
////                    appDelegate.saveContext()
//
//                    var test:User?
//                    test!.userID = Int64(json[0]["id"].intValue)
//                    test!.fullname = json[0]["fullname"].stringValue
//                    test!.userPictureURL = json[0]["profileimageurl"].url!
//                    test!.userPictureMiniURL = json[0]["profileimageurlsmall"].url!
//
//
//                }
                
    
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
    func getUserCommonCourses(userid: Int, completion: @escaping (_: [User]?) -> ()) {
        let para: Parameters = [
            "wstoken": self.userToken!,
            "wsfunction": moodleAPI.APIFunction.getUserCommonCourses.rawValue,
            "moodlewsrestformat": "json",
            "userid": userid,
        ]
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                if let courses = json.array {
                    for course in courses {
                        print(course["fullname"].stringValue)
                    }
                }
                completion(nil)
            case .failure(let error):
//                print("get userInfo \(value) failed with error: \(error)")
                completion(nil)
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
