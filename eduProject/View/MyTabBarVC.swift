//
//  MyTabBarVC.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 14.11.2021.
//

import UIKit

class MyTabBarVC: UITabBarController {
    
    var authVC : ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    

    private func configure() {
        self.tabBar.tintColor = .white
        
    }
   

}
