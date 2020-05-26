//
//  moodleAPI.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/20.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import Foundation
import Alamofire
import Kanna
import SwiftyJSON

enum moodleAPIFunction: String {
    case getSiteInfo = "core_webservice_get_site_info"
    case getUserByField = "core_user_get_users_by_field"
}

class moodleAPI {
    
    // MARK: moodleURL
    let moodleURL = "https://moodle.ntust.edu.tw/"
    let moodleTokenURL = "login/token.php?service=moodle_mobile_app"
    let moodleWebServiceURL = "webservice/rest/server.php"
    
    // MARK: parameter
    var loginRequest = [
        "username": "",
        "password": "",
    ]
    var userToken: String?
    
    init() {
        self.userToken = self.getUserToken()
    }
    
    // MARK: getUserToken
    // this token is used for access moodle web service
    func getUserToken() -> String? {
        AF.request(moodleURL + moodleTokenURL, method: .post, parameters: self.loginRequest).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                self.userToken = json["token"].string
                print("User token request success")
            case .failure(let error):
                print("User token Request failed with error: \(error)")
            }
        }
        print(self.userToken)
        return self.userToken
    }
    
    func getUserInfoById(id: Int) -> moodleUser? {
        let para: Parameters = [
            "wstoken": self.userToken!,
            "field": "id",
            "value": id,
        ]
        var user: moodleUser?
        AF.request(moodleURL + moodleWebServiceURL, method: .get, parameters: para).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data)
                user = moodleUser(
                    userid: json[0]["id"].intValue,
                    fullname: json[0]["fullname"].stringValue,
                    userPictureURL: json[0]["profileimageurl"].url!,
                    userPictureMiniURL: json[0]["profileimageurlsmall"].url!)
                print("get userInfo success: \(id)")
                
            case .failure(let error):
                print("get userInfo \(id) failed with error: \(error)")
            }
        }
        return user
    }
}
