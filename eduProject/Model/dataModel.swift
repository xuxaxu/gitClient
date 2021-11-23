//
//  dataModel.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 14.11.2021.
//

import Foundation
import UIKit
import RealmSwift


class Repositary : Object, Decodable  {
    
    /*
     название
    - описание (должно отображаться полностью, ячейки должны растягиваться соответствующим образом)
    - язык программирования, если есть
    - количество форков
    - количество звезд
    - имя автора и фото (должно быть круглым)
     */
    @Persisted var name: String?
    @Persisted var descript : String?
    @Persisted var language : String?
    @Persisted var forksCount : Int?
    @Persisted var stars : Int?
    @Persisted var fullName : String?
    @Persisted var owner : User?
    @Persisted var commitsUrl : String?
     
    enum CodingKeys: String, CodingKey {
           case descript = "description"
           case language = "language"
            case forksCount = "forks_count"
            case name = "name"
            case stars = "stargazers_count"
            case fullName = "full_name"
            case owner = "owner"
            case commitsUrl = "commits_url"
       }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
                
        self.descript = try container.decodeIfPresent(String.self, forKey: .descript) ?? nil
        self.language = try container.decodeIfPresent(String.self, forKey: .language) ?? nil
        self.forksCount = try container.decodeIfPresent(Int.self, forKey: .forksCount) ?? nil
        self.name = try? container.decodeIfPresent(String.self, forKey: .name) ?? nil
        self.stars = try? container.decodeIfPresent(Int.self, forKey: .stars) ?? nil
        self.fullName = try? container.decodeIfPresent(String.self, forKey: .fullName) ?? nil
        self.owner = try? container.decodeIfPresent(User.self, forKey: .owner) ?? nil
        self.commitsUrl = try? container.decodeIfPresent(String.self, forKey: .commitsUrl) ?? nil
    }
    
    override class func primaryKey() -> String? {
        return "fullName"
    }
    
    func copyRepo() -> Repositary {
        let newRep = Repositary()
        newRep.fullName = self.fullName
        newRep.commitsUrl = self.commitsUrl
        newRep.owner    = User()
        newRep.owner?.avatarUrl = self.owner?.avatarUrl
        newRep.owner?.id = self.owner?.id
        newRep.owner?.login = self.owner?.login
        newRep.owner?.repoUrl = self.owner?.repoUrl
        newRep.descript = self.descript
        newRep.language = self.language
        newRep.forksCount = self.forksCount
        newRep.name = self.name
        newRep.stars = self.stars
        
        return newRep
    }
}

class User : Object, Decodable {
    @Persisted var login : String?
    @Persisted var avatarUrl : String?
    @Persisted var repoUrl : String?
    @Persisted var id : Int?
    
    enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
            case repoUrl = "repos_url"
            case login = "login"
            case id = "id"
       }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
                
        self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? nil
        self.repoUrl = try container.decodeIfPresent(String.self, forKey: .repoUrl) ?? nil
        self.login = try container.decodeIfPresent(String.self, forKey: .login) ?? nil
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? nil
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}


class Commit : Object, Decodable {
    
    @Persisted var massage : String?
    @Persisted var commitDate : DateOfCommit?
    
    enum CodingKeys: String, CodingKey {
           case massage = "massage"
           case commitDate = "committer"
       }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
                
        massage = try container.decodeIfPresent(String.self, forKey: .massage) ?? nil
        commitDate = try container.decodeIfPresent(DateOfCommit.self, forKey: .commitDate) ?? nil
    }
    
}

class DateOfCommit : Object, Decodable {
    @Persisted var email : String?
    @Persisted var date : String?
     
    enum CodingKeys : String, CodingKey {
        case email = "email"
        case date = "date"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? nil
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? nil
    }
}

class ElementCommit : Object, Decodable {
    @Persisted var commit : Commit?
    @Persisted var committer : User?
    @Persisted var id : String?
    @Persisted var repoName : String?
    
    enum CodingKeys : String, CodingKey {
        case commit = "commit"
        case committer = "committer"
        case id = "sha"
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        commit = try container.decodeIfPresent(Commit.self, forKey: .commit) ?? nil
        committer = try container.decodeIfPresent(User.self, forKey: .committer) ?? nil
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? nil
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func copyCommit() -> ElementCommit {
        let newCommit = ElementCommit()
        newCommit.commit = Commit()
        newCommit.commit?.commitDate = DateOfCommit()
        newCommit.commit?.commitDate?.date = self.commit?.commitDate?.date
        newCommit.commit?.commitDate?.email = self.commit?.commitDate?.email
        newCommit.commit?.massage = self.commit?.massage
        newCommit.committer = User()
        newCommit.committer?.repoUrl = self.committer?.repoUrl
        newCommit.committer?.login = self.committer?.login
        newCommit.committer?.id = self.committer?.id
        newCommit.committer?.avatarUrl = self.committer?.avatarUrl
        newCommit.id = self.id
        newCommit.repoName = self.repoName
        
        return newCommit
    }
}

protocol DataModelDelegate: AnyObject {
    func refresh()
    func error()
    func refreshRow(index: Int)
    func endAnimation()
}

/*
extension Repositary : Equatable {
    
    override static func == (lhs: Repositary, rhs: Repositary) -> Bool {
        return lhs.fullName == rhs.fullName
    }
    
}
*/

extension Array where Element: Repositary {
    
    func containRep(rep: Repositary) -> Int? {
        for (inx,r) in self.enumerated() {
            if r.fullName == rep.fullName {
                return inx
            }
        }
        return nil
    }
    
    mutating func removeOrAppend(rep: Repositary) {
        let tempRep = rep as! Element
        for (inx, r) in self.enumerated() {
            if r.fullName == rep.fullName {
                self.remove(at: inx)
                return
            }
        }
        self.append(tempRep)
    }
}
