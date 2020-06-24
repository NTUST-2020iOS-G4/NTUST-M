//
//  TimeTableViewController.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/6/18.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase
import BTNavigationDropdownMenu
import CoreData

private let reuseIdentifier = "eventCell"

class TimeTableViewController: UICollectionViewController {

    let moodle = moodleAPI()
    let keychain = KeychainSwift()
    let myUserDefaults = UserDefaults.standard

    var timeTableEvents = [TimeTableEvent]()
    var semestersString = ["108 學年 第 2 學期", "108 學年 第 1 學期", "107 學年 第 2 學期", "107 學年 第 1 學期", "106 學年 第 2 學期", "106 學年 第 1 學期" ]
    var semestersValue = [1082, 1081, 1072, 1071, 1062, 1061]
    var viewSemester = 1082

    override func viewDidLoad() {
        super.viewDidLoad()
        
        keychain.synchronizable = true
        
        // MARK: - MenuView
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("108 學年 第 2 學期"), items: self.semestersString)
        menuView.navigationBarTitleFont = UIFont.preferredFont(forTextStyle: .headline)
        menuView.menuTitleColor = UIColor.label
        menuView.arrowTintColor = UIColor.label
        menuView.cellTextLabelFont = UIFont.preferredFont(forTextStyle: .body)
        menuView.cellSeparatorColor = UIColor.opaqueSeparator
        menuView.cellBackgroundColor = UIColor.systemGroupedBackground
        menuView.checkMarkImage = UIImage.init(systemName: "checkmark")?.withTintColor(.systemBlue)
        self.navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self!.viewSemester = self!.semestersValue[indexPath]
            self!.prepareTimeTableData(semester: self!.viewSemester)
        }
        
        // MARK: - CollectionView delegate
        if let layout = collectionView?.collectionViewLayout as? TimeTableLayout {
            layout.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareTimeTableData(semester: viewSemester)
    }
    
    // MARK: - Prepare timetable data
    func prepareTimeTableData(semester: Int) {
        
        let weekdayDict = ["M": 0, "T": 1, "W": 2, "R": 3, "F": 4, "S": 5, "U": 6]
        
        let periodDict = ["1": 0, "2": 1, "3": 2, "4": 3, "5": 4, "6": 5, "7": 6,
                          "8": 7, "9": 8, "10": 9, "A": 10, "B": 11, "C": 12, "D": 13]
        
        let weekdayTitle = ["", "週一", "週二", "週三", "週四", "週五", "週六", "週日"]
        
        var colorArr = [UIColor]()
        var colorCount = 0
        
        for i in 1...16 {
            colorArr.append(UIColor.init(named: "TimeTableEventColor\(i)")!)
        }
        
        // Set moodle
        if let moodleToken = self.keychain.get("moodleToken") {
            moodle.userToken = moodleToken
            
            if let userID = myUserDefaults.object(forKey: "userID") as? Int {
                
                // MARK: CoreData
                let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let coreDataConnect = CoreDataConnect(context: myContext)
                let userPredicate = NSPredicate(format: "userID = \(userID)")
                
                if let user = coreDataConnect.find("User", predicate: userPredicate) as? User {
                    
                    // MARK: Reset source list
                    var timeTable = [[TimeTableEvent]]()
                    self.timeTableEvents = [TimeTableEvent]()
                    
                    for _ in 0..<weekdayDict.count {
                        timeTable.append([TimeTableEvent](repeating: TimeTableEvent(), count: periodDict.count))
                    }
                    
                    // MARK: Random Color
                    colorArr = colorArr.shuffled()
                    
                    for course in user.courses! {
                        let course = course as! Course
                        if course.semester == semester {
                            // MARK: Set timetableEvent data
                            for period in course.time! {
                                let period = period as! Period
                                
                                timeTable[weekdayDict[period.day!]!][periodDict[period.period!]!].course = course
                                timeTable[weekdayDict[period.day!]!][periodDict[period.period!]!].color = colorArr[colorCount]
                                timeTable[weekdayDict[period.day!]!][periodDict[period.period!]!].text = course.title! + "@" + period.classroom!.classroom!
                            }
                            colorCount = colorCount + 1 >= colorArr.count ? 0 : colorCount + 1
                        }
                    }
                    
                    // MARK: Combine timetableEvent
                    for i in 0 ..< timeTable.count {
                        var newDayArr = [TimeTableEvent]()
                        for event in timeTable[i] {
                            var event = event
                            event.day = i + 1
                            if newDayArr.isEmpty {
                                newDayArr.append(event)
                            } else {
                                if newDayArr.last?.text == event.text {
                                    newDayArr[newDayArr.endIndex - 1].length += 1
                                } else {
                                    newDayArr.append(event)
                                }
                            }
                        }
                        timeTable[i] = newDayArr
                    }
                    
                    // MARK: Add Period Title
                    var rowHeader = [TimeTableEvent]()
                    for period in periodDict.sorted(by: { $0.1 < $1.1 }) {
                        rowHeader.append(TimeTableEvent(course: nil, text: period.key, type: .periodTitle, day: 0, length: 1, color: UIColor.lightGray))
                    }
                    timeTable.insert(rowHeader, at: 0)
                    
                    // MARK: Add Weekday title
                    for i in 0...5 {
                        if i != 0 {
                            self.timeTableEvents.append(TimeTableEvent(course: nil, text: weekdayTitle[i], type: .weekTitle, day: i, length: 1, color: UIColor.lightGray))
                        } else {
                            self.timeTableEvents.append(TimeTableEvent(course: nil, text: weekdayTitle[i], type: .corner, day: i, length: 1, color: UIColor.lightGray))
                        }
                        
                        // MARK: Append to source
                        for event in timeTable[i] {
                            self.timeTableEvents.append(event)
                        }
                    }
                    
                    self.collectionView.reloadData()
                } else {
                    // error to do
                    
                }
            }
        }
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "courseDetailSegue" {
            let cell = sender as! TimeTableEventCell
            let item = self.collectionView!.indexPath(for: cell)!.item
            if timeTableEvents[item].course != nil {
                return true
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "courseDetailSegue" {
            let cell = sender as! TimeTableEventCell
            let item = self.collectionView!.indexPath(for: cell)!.item
            if timeTableEvents[item].course != nil {
                let courseDetailVC = segue.destination as! CourseDetailViewController
                courseDetailVC.tintColor = timeTableEvents[item].color
                courseDetailVC.course = timeTableEvents[item].course
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return timeTableEvents.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TimeTableEventCell

        cell.contentView.backgroundColor = timeTableEvents[indexPath.item].color
        cell.textLabel.text = timeTableEvents[indexPath.item].text ?? ""
        
        if timeTableEvents[indexPath.item].type == .course {
            cell.contentView.layer.cornerRadius = 10.0
            cell.contentView.clipsToBounds = true
            cell.textLabel.textColor = UIColor.black
        } else {
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.clipsToBounds = false
            cell.textLabel.textColor = UIColor.label
        }
        return cell
    }
}

extension TimeTableViewController: TimeTableLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, eventAtIndexPath indexPath: IndexPath) -> TimeTableEvent {
        return timeTableEvents[indexPath.item]
    }
}
