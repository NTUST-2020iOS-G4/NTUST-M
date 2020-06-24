//
//  CourseDetailViewController.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/6/23.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {
    
    var tintColor: UIColor = UIColor.blue
    var course: Course!
    
    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var instructorLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var classroomLabel: UILabel!
    @IBOutlet weak var registeredLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tintColor = tintColor
        
        titleCell.contentView.backgroundColor = tintColor
        titleCell.tintColor = UIColor.black
        titleLabel.text = course.title
        titleLabel.textColor = UIColor.black
        codeLabel.text = course.code
        instructorLabel.text = course.instructor
        creditLabel.text = course.credits.description
        timeLabel.text = ""
        classroomLabel.text = ""
        
        for time in course.time! {
            let time = time as! Period
            timeLabel.text! += "\(time.day!)\(time.period!) "
            classroomLabel.text! += time.classroom!.classroom! + " "
        }
        
        registeredLabel.text = course.registered.description
    }
}
