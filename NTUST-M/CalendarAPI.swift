//
//  CalendarAPI.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/6/24.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData


class CalendarAPI: NSObject {
    
    var years: [String] = ["108", "109"]
    var db: Firestore!
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Date Format
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func cleanCalendarData() {
        let coreDataConnect = CoreDataConnect(context: self.myContext)
        let deleteResult = coreDataConnect.delete("CDCalendar", predicate: nil)
        if deleteResult {
            print("Delete Old Calendar Data Success")
        }
    }
    
    func downloadCalendarData(completion: (() -> Void)? = nil) {
        // load event from firestore
        self.db = Firestore.firestore()
        var yearCount = 0
        for year in years {
            self.db.collection("\(year)_Calendar").getDocuments { (querySnapshot, error) in
                if let err = error {
                    print("Error getting \(year)_Calendar: \(err)")
                } else {
                    let tempCalendar = CDCalendar(context: self.myContext)
                    tempCalendar.name = "\(year)_Calendar"
                    print("\(tempCalendar.name!)")
                    var dateCount = 0
                    yearCount += 1
                    for dateEvent in querySnapshot!.documents {
                        let eventData = dateEvent.data()
                        let tempDate = CDDate(context: self.myContext)
                        tempDate.date = self.dateFormatter.date(from: eventData["Date"] as! String)
                        for event in eventData["Event"] as! [String] {
                            let tempEvent = CDEvent(context: self.myContext)
                            tempEvent.name = event
                            tempEvent.date = tempDate
                        }
                        tempCalendar.addToDates(tempDate)
                        
                        dateCount += 1
                        if (dateCount >= querySnapshot!.documents.count && yearCount >= self.years.count) {
                            do {
                                try self.myContext.save()
                            } catch {
                                fatalError("\(error)")
                            }
                            completion?()
                        }
                    }
                }
            }
        }
    }
}
