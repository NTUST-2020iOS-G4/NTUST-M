//
//  LoginViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/27.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit
import KeychainSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    let keychain = KeychainSwift()
    let moodle = moodleAPI()
    let calendar = CalendarAPI()
    let myUserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.borderStyle = .roundedRect
        password.borderStyle = .roundedRect
        
        loginBtn.layer.cornerRadius = 5.0
        loginBtn.layer.masksToBounds = true
        
        keychain.synchronizable = true
        username.text = keychain.get("username")

        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func clickLoginBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        let loadingView = UIView(frame: CGRect(x: self.view.bounds.midX - 40, y: self.view.bounds.midY - 40, width: 80, height: 80))
        loadingView.backgroundColor = UIColor.lightGray
        loadingView.layer.cornerRadius = 20.0
        loadingView.clipsToBounds = true
        
        let loading = LoadingView(frame: CGRect(x: loadingView.bounds.minX + 15, y: loadingView.bounds.minY + 15, width: 50, height: 50))
        loading.startLoading()
        loadingView.addSubview(loading)
        
        
        self.view.addSubview(loadingView)
        self.view.isUserInteractionEnabled = false
        
        self.moodle.setUserToken(parameters: ["username": username.text!, "password": password.text!]) { (status, error) in
            if status {
                self.moodle.getSelfMoodleID { (userID) in
                    self.moodle.getUserInfo(searchField: .id, value: userID!) { (user) in
                        
                        self.myUserDefaults.set(user?.fullname, forKey: "userFullname")
                        self.myUserDefaults.set(self.username.text! + "@mail.ntust.edu.tw", forKey: "userEmail")
                        self.myUserDefaults.set(userID, forKey: "userID")
                        
                        let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        
                        let msg = UIAlertController(title: "下載資料中", message: "下載 Moodle 課程資料中", preferredStyle: .alert)
                        self.present(msg, animated: true) {
                            if let userID = self.myUserDefaults.object(forKey: "userID") as? Int {
                                self.moodle.getUserInfo(searchField: .id, value: userID) { (user) in
                                    if user != nil {
                                        self.moodle.loadUserCommonCourses(user: user!) { (_, _) in
                                            msg.message = "下載行事曆資料中"
                                            self.calendar.downloadCalendarData() {
                                                let mainVC = mainStoryBoard.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
                                                sceneDelegate.window?.rootViewController = mainVC
                                                sceneDelegate.window?.makeKeyAndVisible()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                let errorMsg = UIAlertController(title: "錯誤", message: error, preferredStyle: .alert)
                errorMsg.addAction(UIAlertAction(title: "確認", style: .default))
                self.present(errorMsg, animated: true, completion: nil)
            }
            
            loadingView.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
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
