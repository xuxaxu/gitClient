//
//  dataModel.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 14.11.2021.
//

import Foundation
import UIKit

class DataModel {
    
    weak var delegate : DataModelDelegate?

    func loadData() {
        GitHubService.shared.getRepositories { repos in
            
            guard let repo = repos else {
                self.delegate?.error()
                return
            }
        
            self.loadImages(repos: repo)
            self.delegate?.dataDidRecieve(data: repo)
        }
    }
    
    func loadImages(repos: [Repositary]) {
        DispatchQueue.global(qos: .background).async {
            for rep in repos {
                if let avUrl = rep.owner?.avatarUrl,
                   let url = URL.init(string: avUrl),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.delegate?.avatarLoaded(img: image, repoName: rep.name ?? "")
                        }
                    }
            }
        }
    }
    
}

class Repositary : Decodable {
    
    /*
     название
    - описание (должно отображаться полностью, ячейки должны растягиваться соответствующим образом)
    - язык программирования, если есть
    - количество форков
    - количество звезд
    - имя автора и фото (должно быть круглым)
     */
    var name: String?
    var description : String?
    var language : String?
    var forksCount : Int?
    var stars : Int?
    var fullName : String?
    var owner : User?
    var avatar : UIImage?
     
    enum CodingKeys: String, CodingKey {
           case description = "description"
           case language = "language"
            case forksCount = "forks_count"
            case name = "name"
            case stars = "stargazers_count"
            case fullName = "full_name"
            case owner = "owner"
            
       }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                
             self.description = try? container.decode(String.self, forKey: .description)
             self.language = try? container.decode(String.self, forKey: .language)
            self.forksCount = try? container.decode(Int.self, forKey: .forksCount)
            self.name = try? container.decode(String.self, forKey: .name)
            self.stars = try? container.decode(Int.self, forKey: .stars)
            self.fullName = try? container.decode(String.self, forKey: .fullName)
            self.owner = try? container.decode(User.self, forKey: .owner)
        }
    
    
}

protocol DataModelDelegate: AnyObject {
    func dataDidRecieve(data: [Repositary])
    func error()
    func avatarLoaded(img: UIImage, repoName: String)
}

struct User : Decodable {
    var login : String?
    var avatarUrl : String?
    var repoUrl : String?
    
    enum CodingKeys: String, CodingKey {
           case avatarUrl = "avatar_url"
           case repoUrl = "repos_url"
            case login = "login"
           
       }
    
    init(from decoder: Decoder) throws {
             let container = try decoder.container(keyedBy: CodingKeys.self)
                
             self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
             self.repoUrl = try container.decode(String.self, forKey: .repoUrl)
            self.login = try container.decode(String.self, forKey: .login)
            
        }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}



