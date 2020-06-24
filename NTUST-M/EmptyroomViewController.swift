//
//  EmptyroomViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/28.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

struct CoursePeriod {
    var name: String
    var start: Date?
    var end: Date?
    
    init(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        self.name = name
        let calendar = Calendar.current
        let now = Date()
        self.start = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: now)
        self.end = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: now)
    }
    
    func formatString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "\(self.name) (\(dateFormatter.string(from: start!))~\(dateFormatter.string(from: end!)))"
    }
    
    func shortFormatString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "\(dateFormatter.string(from: start!))~\(dateFormatter.string(from: end!))"
    }
}

struct Classroom {
    var name: String
    var courseList = [String]()
    
    func empty(periodIndex: Int) -> Bool {
        guard periodIndex < courseList.count && periodIndex >= 0 else {
            return false
        }
        if courseList[periodIndex] == "" {
            return true
        } else {
            return false
        }
    }
}

class EmptyroomViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate
{
    let buildingList = ["研揚大樓","國際大樓","第三教學大樓","第四教學大樓","工程一館","工程二館","電資館","管理大樓"]
    let buildingCode = ["TR","IB","T3","T4","E1","E2","EE","MB"]
    
    let coursePeriodList = [
        CoursePeriod(name: "第 1 節課", startHour: 8, startMinute: 10, endHour: 9, endMinute: 0),
        CoursePeriod(name: "第 2 節課", startHour: 9, startMinute: 10, endHour: 10, endMinute: 0),
        CoursePeriod(name: "第 3 節課", startHour: 10, startMinute: 20, endHour: 11, endMinute: 10),
        CoursePeriod(name: "第 4 節課", startHour: 11, startMinute: 20, endHour: 12, endMinute: 10),
        CoursePeriod(name: "第 5 節課", startHour: 12, startMinute: 10, endHour: 13, endMinute: 10),
        CoursePeriod(name: "第 6 節課", startHour: 13, startMinute: 20, endHour: 14, endMinute: 10),
        CoursePeriod(name: "第 7 節課", startHour: 14, startMinute: 20, endHour: 15, endMinute: 10),
        CoursePeriod(name: "第 8 節課", startHour: 15, startMinute: 30, endHour: 16, endMinute: 20),
        CoursePeriod(name: "第 9 節課", startHour: 16, startMinute: 30, endHour: 17, endMinute: 20),
        CoursePeriod(name: "第 10 節課", startHour: 17, startMinute: 30, endHour: 18, endMinute: 20),
        CoursePeriod(name: "第 A 節課", startHour: 18, startMinute: 25, endHour: 19, endMinute: 15),
        CoursePeriod(name: "第 B 節課", startHour: 19, startMinute: 20, endHour: 20, endMinute: 10),
        CoursePeriod(name: "第 C 節課", startHour: 20, startMinute: 15, endHour: 21, endMinute: 05),
        CoursePeriod(name: "第 D 節課", startHour: 21, startMinute: 10, endHour: 22, endMinute: 00)
    ]
    
    let myUserDefaults = UserDefaults.standard

    @IBOutlet var subPickView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var buildingTime: UIButton!
    @IBOutlet weak var pickerViewDoneButton: UIButton!
    
    @IBOutlet weak var classroomTableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var emptyRooms = [Classroom]()
    var usedRooms = [Classroom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.classroomTableView.delegate = self
        self.classroomTableView.dataSource = self
        
        // MARK: Use UserDefaluts Building
        // if not have saved index or use default building
        pickerView.selectRow(0, inComponent: 0, animated: false)
        // if use last check index then check exist and set
        if let buildingSave = myUserDefaults.object(forKey: "buildingSave") as? Bool {
            if buildingSave {
                if let buildingIndex = myUserDefaults.object(forKey: "buildingIndex") as? Int {
                    pickerView.selectRow(buildingIndex, inComponent: 0, animated: false)
                }
            }
        }
        
        // MARK: TableView refresh control
        classroomTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(objcLoadBuildingData), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(subPickView)
        subPickView.translatesAutoresizingMaskIntoConstraints = false
        
        subPickView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        subPickView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        subPickView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        let c = subPickView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 180)
        c.identifier = "bottom"
        c.isActive = true
        subPickView.layer.cornerRadius = 10
        
        super.viewWillAppear(animated)
        
        // MARK: Auto set now coursePeriod
        let now = Date()
        for (timeIndex, time) in coursePeriodList.enumerated() {
            if now >= time.start! {
                pickerView.selectRow(timeIndex, inComponent: 1, animated: false)
            }
        }
        
        refreshControl.beginRefreshingManually()
    }
    
    @IBAction func selectClick(_ sender: UIButton) {
        displayPickerView(true)
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        displayPickerView(false)
        refreshControl.beginRefreshingManually()
    }
    
    // MARK: - PickerView Setting
    
    func displayPickerView(_ show: Bool) {
        for c in view.constraints {
            if c.identifier == "bottom" {
                c.constant = (show) ? -60 : 180
                break
            }
        }
        UIView.animate(withDuration: 0.5, animations: self.view.layoutIfNeeded)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return buildingList.count
        } else {
            return coursePeriodList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        
        if component == 0 {
            pickerLabel.text = buildingList[row]
        } else {
            pickerLabel.text = coursePeriodList[row].name
        }
        pickerLabel.textAlignment = .center

        return pickerLabel
    }
    
    // MARK: - TableView Setting
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return emptyRooms.count
        }
        else if section == 1 {
            return usedRooms.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "空教室"
        } else if section == 1 {
            return "使用中的教室"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "classroomCell")
        if indexPath.section == 0 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "classroomCell")
            cell?.imageView?.image = UIImage(systemName: "checkmark.circle")
            cell?.tintColor = .systemGreen
            cell?.textLabel?.text = emptyRooms[indexPath.row].name
        } else if indexPath.section == 1 {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "classroomCell")
            cell?.imageView?.image = UIImage(systemName: "xmark.circle")?.withTintColor(.systemRed)
            cell?.tintColor = .systemRed
            cell?.textLabel?.text = usedRooms[indexPath.row].name
            
            let coursePeriodIndex = pickerView.selectedRow(inComponent: 1)
            cell?.detailTextLabel?.text = usedRooms[indexPath.row].courseList[coursePeriodIndex]
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "classroomCell")
            cell?.textLabel?.text = ""
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "classroomInfoSegue", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadBuildingData(completion: @escaping () -> Void) {
        let buildingIndex = pickerView.selectedRow(inComponent: 0)
        let coursePeriodIndex = pickerView.selectedRow(inComponent: 1)
        
        // Set userDefault if need
        if let buildingSave = myUserDefaults.object(forKey: "buildingSave") as? Bool {
            if buildingSave {
                myUserDefaults.set(buildingIndex, forKey: "buildingIndex")
                myUserDefaults.synchronize()
            }
        }
        
        // Update button title
        buildingTime.setTitle("\(buildingList[buildingIndex]) \(coursePeriodList[coursePeriodIndex].formatString())", for: .normal)
        
        // Fetch data
        AF.request("http://classroom.taiwan-te.ch/ajax", method: .get, parameters: ["building": buildingCode[buildingIndex]]).responseJSON { response in
            switch response.result {
            case .success(let data):
                let classrooms = JSON(data)
                
                self.emptyRooms.removeAll()
                self.usedRooms.removeAll()
                
                for (roomName, periodList) in classrooms {
                    let room = Classroom(name: roomName, courseList: periodList.arrayObject as! [String])
                    if room.empty(periodIndex: coursePeriodIndex) {
                        self.emptyRooms.append(room)
                    } else {
                        self.usedRooms.append(room)
                    }
                }
                
                self.emptyRooms.sort { $0.name < $1.name }
                self.usedRooms.sort { $0.name < $1.name }
                self.classroomTableView.reloadData()
                completion()
            case .failure(let error):
                print("Fetch building \(self.buildingCode[buildingIndex]) failed with error: \(error)")
                completion()
            }
        }
    }
    
    @objc func objcLoadBuildingData() {
        loadBuildingData {
            self.refreshControl.endRefreshing()
            print("Loaded Building Data")
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "classroomInfoSegue" {
            let controller = segue.destination as! EmptyroomDetailViewController
            controller.coursePeriodList = self.coursePeriodList
            let indexPath = self.classroomTableView.indexPathForSelectedRow
            if indexPath?.section == 0 {
                controller.classroom = emptyRooms[indexPath!.row]
            } else if indexPath?.section == 1 {
                controller.classroom = usedRooms[indexPath!.row]
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

extension UIRefreshControl {

    func beginRefreshingManually() {
        beginRefreshing()
        
        if let tableView = superview as? UITableView {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
                tableView.contentOffset = CGPoint(x: 0, y: -self.bounds.height)
            }) { (finish) in
                tableView.reloadData()
            }
        }
        
        sendActions(for: .valueChanged)
    }

}
