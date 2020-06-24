//
//  TimeTableEvent.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/6/23.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

struct TimeTableEvent {
    var course: Course?
    var text: String?
    
    var type: eventType = .course
    var day: Int = 0
    var length: Int = 1
    var color: UIColor = UIColor.clear
}

enum eventType {
    case course
    case weekTitle
    case periodTitle
    case corner
}
