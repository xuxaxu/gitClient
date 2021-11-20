//
//  DataService.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 20.11.2021.
//

import Foundation
import UIKit

class DataService {
    
    static let shared = DataService()
    
    var favorites : [Repositary] = []
    
    var repositories : [Repositary] = []
    
    func chooseFavorite(_ rep : Repositary) {
        
        if self.favorites.contains(rep) {
            self.favorites.remove(at: self.favorites.firstIndex(of: rep)!)
        } else {
            self.favorites.append(rep)
        }
    }
    
}
