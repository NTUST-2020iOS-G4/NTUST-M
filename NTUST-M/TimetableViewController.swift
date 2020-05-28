//
//  TimetableViewController.swift
//  NTUST-M
//
//  Created by YuKai Lee on 2020/5/27.
//  Copyright © 2020 NTUST-2020iOS-G4. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func CourseClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "社群媒體資料分析實務", message: "代碼：CS5128701\n教師 ：陳怡伶\n時間：F2,F3,F4\n地點：TR-214", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let infoAction = UIAlertAction(title: "詳細資訊", style: .default) { (_) in
            print("開啟課程詳細資訊")
            
        }
        alertController.addAction(okAction)
        alertController.addAction(infoAction)
        present(alertController, animated: true, completion: nil)
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
