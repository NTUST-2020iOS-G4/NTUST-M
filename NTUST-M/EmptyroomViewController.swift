//
//  EmptyroomViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/28.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

struct classtime {
    var name: String
    var start: Date?
    var end: Date?
    
    init(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int){
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
}

class EmptyroomViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    let buildingList = ["研揚大樓","國際大樓","第三教學大樓","第四教學大樓","工程一館","工程二館","電資館","管理大樓"]
    let buildCode = ["TR","IB","T3","T4","E1","E2","EE","MB"]
    
    let timeList = [
        classtime(name: "第 1 節課", startHour: 8, startMinute: 10, endHour: 9, endMinute: 0),
        classtime(name: "第 2 節課", startHour: 9, startMinute: 10, endHour: 10, endMinute: 0),
        classtime(name: "第 3 節課", startHour: 10, startMinute: 20, endHour: 11, endMinute: 10),
        classtime(name: "第 4 節課", startHour: 11, startMinute: 20, endHour: 12, endMinute: 10),
        classtime(name: "第 5 節課", startHour: 12, startMinute: 10, endHour: 13, endMinute: 10),
        classtime(name: "第 6 節課", startHour: 13, startMinute: 20, endHour: 14, endMinute: 10),
        classtime(name: "第 7 節課", startHour: 14, startMinute: 20, endHour: 15, endMinute: 10),
        classtime(name: "第 8 節課", startHour: 15, startMinute: 30, endHour: 16, endMinute: 20),
        classtime(name: "第 9 節課", startHour: 16, startMinute: 30, endHour: 17, endMinute: 20),
        classtime(name: "第 10 節課", startHour: 17, startMinute: 30, endHour: 18, endMinute: 20),
        classtime(name: "第 A 節課", startHour: 18, startMinute: 25, endHour: 19, endMinute: 15),
        classtime(name: "第 B 節課", startHour: 19, startMinute: 20, endHour: 20, endMinute: 10),
        classtime(name: "第 C 節課", startHour: 20, startMinute: 15, endHour: 21, endMinute: 05),
        classtime(name: "第 D 節課", startHour: 21, startMinute: 10, endHour: 22, endMinute: 00)
    ]

    @IBOutlet var subPickView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var buildingTime: UIButton!
    @IBOutlet weak var pickerViewDoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let now = Date()
        for (timeIndex, time) in timeList.enumerated() {
            if now >= time.start! {
                pickerView.selectRow(timeIndex, inComponent: 1, animated: true)
            }
        }
        doneClick(pickerViewDoneButton)
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
    }
    
    @IBAction func selectClick(_ sender: UIButton) {
        displayPickerView(true)
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        displayPickerView(false)
        let building = pickerView.selectedRow(inComponent: 0)
        let time = pickerView.selectedRow(inComponent: 1)
        buildingTime.setTitle("\(buildingList[building]) \(timeList[time].formatString())", for: .normal)
    }
    
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
            return timeList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        
        if component == 0 {
            pickerLabel.text = buildingList[row]
        } else {
            pickerLabel.text = timeList[row].name
        }
        pickerLabel.textAlignment = .center

        return pickerLabel
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
