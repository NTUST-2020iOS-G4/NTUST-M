//
//  EmptyroomDetailViewController.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/29.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

class EmptyroomDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var coursePeriodTableView: UITableView!
    
    var classroom: Classroom?
    var coursePeriodList: [CoursePeriod]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.title = "\(classroom!.name) 的時間表"
        self.coursePeriodTableView.delegate = self
        self.coursePeriodTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (classroom?.courseList.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "periodCell")
        cell = UITableViewCell(style: .value1, reuseIdentifier: "classroomCell")
        cell?.textLabel?.text = coursePeriodList![indexPath.row].shortFormatString()
        if classroom?.courseList[indexPath.row] == "" {
            cell?.tintColor = .systemGreen
            cell?.imageView?.image = UIImage(systemName: "checkmark.circle")
            cell?.detailTextLabel?.text = "空教室"
        } else {
            cell?.tintColor = .systemRed
            cell?.imageView?.image = UIImage(systemName: "xmark.circle")
            cell?.detailTextLabel?.text = classroom?.courseList[indexPath.row]
        }
        return cell!
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
