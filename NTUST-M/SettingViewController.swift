//
//  SettingViewController.swift
//  NTUST-M
//
//  Created by Jeffery Ho on 2020/5/29.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import CoreData
import FirebaseFirestore

class SettingViewController: UITableViewController {

    @IBOutlet weak var moodleAccountCell: UITableViewCell!
    @IBOutlet weak var moodleLogoutCell: UITableViewCell!
    @IBOutlet weak var buildingSaveCell: UITableViewCell!
    
    let myUserDefaults = UserDefaults.standard
    let keychain = KeychainSwift()
    let moodle = moodleAPI()
    let calendar = CalendarAPI()
    
    // MARK: CoreData Context
    let myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keychain.synchronizable = true
        
        let buildingSaveSwitch = UISwitch(frame: .zero)
        buildingSaveSwitch.addTarget(self, action: #selector(self.buildingSwitchChanged(_:)), for: .valueChanged)
        buildingSaveCell.accessoryView = buildingSaveSwitch
        
        // Set building default switch
        if let buildingSave = myUserDefaults.object(forKey: "buildingSave") as? Bool {
            buildingSaveSwitch.isOn = buildingSave
        } else {
            buildingSaveSwitch.isOn = false
            myUserDefaults.set(false, forKey: "buildingSave")
            myUserDefaults.synchronize()
        }
        
        // Set moodle
        if let moodleToken = self.keychain.get("moodleToken") {
            moodle.userToken = moodleToken
            
            // Set user fullname
            if let fullname = myUserDefaults.object(forKey: "userFullname") as? String {
                self.moodleAccountCell.textLabel?.text = fullname
            }
            
            // Set user fullname
            if let userEmail = myUserDefaults.object(forKey: "userEmail") as? String {
                self.moodleAccountCell.detailTextLabel?.text = userEmail
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        // Moodle Account Section
        case 1:
            switch indexPath.row {
            // logout cell
            case 0:
                logoutAlert()
            default:
                break
            }
        // Empty Room Section
        case 2:
            switch indexPath.row {
            // classroom website
            case 1:
                openLink(link: "http://classroom.taiwan-te.ch/")
            default:
                break
            }
        // Reset Section
        case 3:
            switch indexPath.row {
            // reset moodle data cell
            case 0:
                resetMoodleData()
            // reset calendar data cell
            case 1:
                resetCalendarData()
            default:
                break
            }
        // About Section
        case 4:
            switch indexPath.row {
            // classroom website
            case 0:
                openLink(link: "https://github.com/NTUST-2020iOS-G4/NTUST-M")
            default:
                break
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func logoutAlert() {
        let alertController = UIAlertController(
            title: "確定要登出嗎？",
            message: "登出後則無法使用 找同學 及 課表自動帶入 Moodle 課程功能。",
            preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            self.keychain.delete("password")
            self.keychain.delete("moodleToken")
            
            self.myUserDefaults.removeObject(forKey: "userFullname")
            self.myUserDefaults.removeObject(forKey: "userEmail")
            self.myUserDefaults.removeObject(forKey: "userID")
            self.myUserDefaults.removeObject(forKey: "buildingSave")
            
            self.cleanMoodleData()
            self.calendar.cleanCalendarData()
            
            let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            
            sceneDelegate.window?.rootViewController = loginVC
            sceneDelegate.window?.makeKeyAndVisible()
        }
        okAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func buildingSwitchChanged(_ sender: UISwitch) {
        myUserDefaults.set(sender.isOn, forKey: "buildingSave")
        myUserDefaults.synchronize()
    }
    
    func cleanMoodleData() {
        let coreDataConnect = CoreDataConnect(context: self.myContext)
        var deleteResult: Bool
        
        deleteResult = coreDataConnect.delete("Course", predicate: nil)
        if deleteResult {
            print("Delete Old Course Data Success")
        }
        deleteResult = coreDataConnect.delete("Location", predicate: nil)
        if deleteResult {
            print("Delete Old Location Data Success")
        }
        deleteResult = coreDataConnect.delete("Period", predicate: nil)
        if deleteResult {
            print("Delete Old Period Data Success")
        }
        deleteResult = coreDataConnect.delete("User", predicate: nil)
        if deleteResult {
            print("Delete Old User Data Success")
        }
    }
    
    func resetMoodleData() {
        let msg = UIAlertController(title: "重置資料中", message: "刪除 Moodle 課程資料中", preferredStyle: .alert)
        self.present(msg, animated: true) {
            self.cleanMoodleData()
            msg.message = "下載 Moodle 課程資料中"
            if let userID = self.myUserDefaults.object(forKey: "userID") as? Int {
                self.moodle.getUserInfo(searchField: .id, value: userID) { (user) in
                    if user != nil {
                        self.moodle.loadUserCommonCourses(user: user!) { (_, _) in
                            msg.dismiss(animated: true) {
                                msg.title = "已完成重置"
                                msg.message = "已重置所有 Moodle 課程資料"
                                msg.addAction(UIAlertAction(title: "確認", style: .default))
                                self.present(msg, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resetCalendarData() {
        let msg = UIAlertController(title: "重置資料中", message: "刪除行事曆資料中", preferredStyle: .alert)
        self.present(msg, animated: true) {
            self.calendar.cleanCalendarData()
            msg.message = "下載行事曆資料中"
            self.calendar.downloadCalendarData() {
                 msg.dismiss(animated: true) {
                    msg.title = "已完成重置"
                    msg.message = "已重置所有行事曆資料"
                    msg.addAction(UIAlertAction(title: "確認", style: .default))
                    self.present(msg, animated: true, completion: nil)
                }
            }
        }
    }
    
    func openLink(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}
