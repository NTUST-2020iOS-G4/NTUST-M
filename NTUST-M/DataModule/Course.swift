//
//  Course.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/21.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import Foundation

class moodleCourse {
    // MARK: Requied Field
    var id: Int
    var shortname: String
    var fullname: String
    
    // MARK: Addition
    var idnumber: String?
    var summary: String?
    
    // MARK: init function
    
    init(id: Int, shortname: String, fullname: String) {
        self.id = id
        self.shortname = shortname
        self.fullname = fullname
        self.idnumber = nil
        self.summary = nil
    }
    
    convenience init(id: Int, shortname: String, fullname: String, idnumber: String, summary: String) {
        self.init(id: id, shortname: shortname, fullname: fullname)
        self.idnumber = idnumber
        self.summary = summary
    }
}
