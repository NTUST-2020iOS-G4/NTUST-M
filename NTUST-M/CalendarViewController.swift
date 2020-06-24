//
//  CalendarViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/25.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import CoreData

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDataSource, FSCalendarDelegate {
   
    var events: [String] = []
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventTableView: UITableView!
    
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let date = self.calendar.selectedDate {
            self.reloadEventList(date: date)
        } else {
            self.reloadEventList(date: self.calendar.today!)
        }
    }
    
    // MARK: - Bar item action
    
    @IBAction func clickRefreshBtn(_ sender: UIBarButtonItem) {
        self.reloadEventList(date: self.calendar.today!)
        self.calendar.select(self.calendar.today!, scrollToDate: true)
        self.calendar.deselect(self.calendar.today!)
    }
    
    // MARK: - Event TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = events[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Event Calendar
    
    // Date Format
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // 點擊該日期的觸發事件
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        reloadEventList(date: date)
    }
    
    // 回傳該日期有幾個事件
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {

        let coreDataConnect = CoreDataConnect(context: myContext)
        let datePredicate = NSPredicate(format: "date = %@", date as CVarArg)
        let selectResult = coreDataConnect.retrieve("CDDate", predicate: datePredicate, sort: nil, limit: nil)
        
        var eventcount = 0
        if let results = selectResult {
            for result in results {
                let cddate = result as! CDDate
                eventcount += cddate.events!.count
            }
        }
        return eventcount
    }
    
    func reloadEventList(date: Date) {
        let coreDataConnect = CoreDataConnect(context: myContext)
        let datePredicate = NSPredicate(format: "date = %@", date as CVarArg)
        let selectResult = coreDataConnect.retrieve("CDDate", predicate: datePredicate, sort: nil, limit: nil)
        events.removeAll()
        if let results = selectResult {
            for result in results {
                let cddate = result as! CDDate
                for event in cddate.events! {
                    let cdevent = event as! CDEvent
                    events.append(cdevent.name!)
                }
            }
        }
        self.eventTableView.reloadData()
    }
}
