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
    weak var delegateCommit : DataModelCommitDelegate?
    
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
        for rep in repos {
                if let avUrl = rep.owner?.avatarUrl {
                    ImagesService.shared.getImage(url: avUrl) { image in
                        if let img = image {
                            self.delegate?.avatarLoaded(img: img, repoName: rep.name ?? "")
                        } 
                    }
                        
                    }
            }
    }
    
    func loadCommits(commitsUrl: String) {
        GitHubService.shared.getInfoRepo(commitsUrl: commitsUrl) { commits in
            guard let elementsCommit = commits else {
                self.delegateCommit?.error()
                return
            }
            
            self.delegateCommit?.dataDidRecieve(data: elementsCommit)
            
            self.loadImagesOfCommits(commits: elementsCommit)
        }
    }
    
    func loadImagesOfCommits(commits: [ElementCommit]) {
            for (indx,elmt) in commits.enumerated() {
                if let avUrl = elmt.committer?.avatarUrl {
                    ImagesService.shared.getImage(url: avUrl) { image in
                    if let img = image {
                        self.delegateCommit?.avatarLoaded(img: img, index: indx)
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
    var commitsUrl : String?
     
    enum CodingKeys: String, CodingKey {
           case description = "description"
           case language = "language"
            case forksCount = "forks_count"
            case name = "name"
            case stars = "stargazers_count"
            case fullName = "full_name"
            case owner = "owner"
            case commitsUrl = "commits_url"
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
        self.commitsUrl = try? container.decode(String.self, forKey: .commitsUrl)
    }
    
    
}

protocol DataModelDelegate: AnyObject {
    func dataDidRecieve(data: [Repositary])
    func error()
    func avatarLoaded(img: UIImage, repoName: String)
}

protocol DataModelCommitDelegate: AnyObject {
    func dataDidRecieve(data: [ElementCommit])
    func error()
    func avatarLoaded(img: UIImage, index: Int)
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

class Commit : Decodable {
    
    var massage : String?
    var commitDate : DateOfCommit?
    
    enum CodingKeys: String, CodingKey {
           case massage = "massage"
           case commitDate = "committer"
            
       }
    
    required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                
        self.massage = try? container.decode(String.self, forKey: .massage)
        self.commitDate = try? container.decode(DateOfCommit.self, forKey: .commitDate)
        }
    
}

class DateOfCommit : Decodable {
    var email : String?
    var date : String?
    
    enum CodingKeys : String, CodingKey {
        case email = "email"
        case date = "date"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.email = try? container.decode(String.self, forKey: .email)
        self.date = try? container.decode(String.self, forKey: .date)
    }
}

class ElementCommit : Decodable {
    var commit : Commit?
    var committer : User?
    var avatar : UIImage?
    
    enum CodingKeys : String, CodingKey {
        case commit = "commit"
        case committer = "committer"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.commit = try? container.decode(Commit.self, forKey: .commit)
        self.committer = try? container.decode(User.self, forKey: .committer)
    }
}

extension Repositary : Equatable {
    
    static func == (lhs: Repositary, rhs: Repositary) -> Bool {
        return lhs.fullName == rhs.fullName
    }
    
}



