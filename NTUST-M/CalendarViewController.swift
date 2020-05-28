//
//  CalendarViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/25.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDataSource, FSCalendarDelegate {
   
    var datesEventCount: [String:Int] = [:]
    var events = ["測試事件1", "測試事件2"]
    var eventsdata: [String:(Int, [String])] = [:]
    
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var eventTableView: UITableView!
    
    let jsonURL = Bundle.main.url(forResource: "testEvent", withExtension: "json")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadEventJson()
        eventsdata["2020-05-16"] = (2, ["123","456"])
    }
    
    func loadEventJson() {
        if let data = try? Data(contentsOf: jsonURL!) {
            if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                for p in jsonObj as! [[String: AnyObject]] {
                    //datesWithEvent.append("\(String(describing: p["date"]))")
                    datesEventCount[String(describing: p["date"]!)] = p["count"] as? Int
                    eventsdata[String(describing: p["date"]!)] = (p["count"] as? Int, ["events1","events2"]) as? (Int, [String])
                }
            }
        }
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
    
    // MARK: - Event Calendar
    
    // Date Format
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // 點擊該日期的觸發事件
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        events.append("\(self.dateFormatter.string(from:date))")
        let count = self.events.count == 0 ? 0 : self.events.count - 1
        eventTableView.insertRows(at: [[0,count]], with: UITableView.RowAnimation.fade)
    }
    
    // 回傳該日期有幾個事件
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter.string(from: date)
        if let eventcount = self.datesEventCount[dateString] {
            return eventcount
        }
        return 0
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
