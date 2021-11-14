//
//  MyTabBar.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 10.11.2021.
//

import UIKit

class MyTabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    

    private func configure() {
        
        let newNC = UINavigationController()
        var firstVC = MainViewController()
        newNC.viewControllers.append(firstVC)
        
        let newNCfav    = UINavigationController()
        let secVC = StarredViewController()
        newNCfav.viewControllers.append(secVC)
        
        self.viewControllers?.append(newNC)
        self.viewControllers?.append(newNCfav)
        
        firstVC.tabBarItem.title = "⚙︎"
        secVC.tabBarItem.title = "★"
        
    }

}
