//
//  finVC.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 23.11.2021.
//

import UIKit
import KeychainAccess

class finVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction private func logOut(_ sender: Any) {
    
        
        
        if let myTabBar = self.tabBarController as? MyTabBarVC {
            myTabBar.authVC?.tryAutoAuthentication = false
              try? myTabBar.authVC?.savePassword(login: "lastIncome", password: "")
        }
        self.tabBarController?.dismiss(animated: true, completion: nil)
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
