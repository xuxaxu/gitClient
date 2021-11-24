//
//  DataService.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 20.11.2021.
//

import Foundation
import UIKit
import RealmSwift

class DataService {
    
    static let shared = DataService()
    
    var favorites : [Repositary] = []
    
    var repositories : [Repositary] = []
    
    var currentCommits : [ElementCommit] = []
    
    private var localRealm = try! Realm()
    
    //vc
    weak var delegate : DataModelDelegate?
    weak var delegateFavorites : DataModelDelegate?
    weak var delegateCommit : DataModelDelegate?
    
    var avatars : Dictionary<String, UIImage> = [:]
    
    //load from net
    func loadData() {
        GitHubService.shared.getRepositories { repos in
            
            guard let repo = repos else {
                self.delegate?.error()
                return
            }
        
            self.repositories = repo
            
            self.loadImages(repos: repo)
            self.delegate?.refresh()
        }
    }
    
    //load images after loading list
    func loadImages(repos: [Repositary]) {
        for (index,rep) in repos.enumerated() {
            
            //get add info in same loop with images
            GitHubService.shared.getAdditinalInfo(repo: rep) { newRep in
                self.delegate?.refreshRow(index: index)
            }
            
                if let avUrl = rep.owner?.avatarUrl {
                    ImagesService.shared.getImage(url: avUrl) { image in
                        if let img = image {
                            self.avatars[avUrl] = img
                            self.delegate?.refreshRow(index: index)
                            
                            //end animation
                            if index == repos.count - 1 {
                                self.delegate?.endAnimation()
                            }
                        }
                    }
                        
                }
            }
    }
    
    //load commits for detail
    func loadCommits(commitsUrl: String, repoName: String) {
        GitHubService.shared.getInfoRepo(commitsUrl: commitsUrl, repoName: repoName) { commits in
            guard let elementsCommit = commits else {
                self.delegateCommit?.error()
                return
            }
            
            self.currentCommits = elementsCommit
            
            self.delegateCommit?.refresh()
            
            self.loadImagesOfCommits(commits: elementsCommit)
        }
    }
    
    func loadImagesOfCommits(commits: [ElementCommit]) {
            for (indx,elmt) in commits.enumerated() {
                if let avUrl = elmt.committer?.avatarUrl {
                    ImagesService.shared.getImage(url: avUrl) { image in
                    if let img = image {
                        self.avatars[avUrl] = img
                        self.delegateCommit?.refreshRow(index: indx)
                        
                        //end animate
                        if indx == commits.count - 1 {
                            self.delegateCommit?.endAnimation()
                        }
                    }
                }
            }
            }
    }
    
    func getAvatar(url: String?) -> UIImage {
        if let key = url, let img = avatars[key] {
            return img
        } else {
            return UIImage()
        }
    }

    //favorites: if was favorite remove it, if wasn't append
    func chooseFavorite(_ rep : Repositary) {
    
        
        if let index = self.favorites.containRep(rep: rep) {
            self.favorites.remove(at: index)
            
            self.delegate?.refresh()
            
            if let id = rep.id {
                removeRepoFromDB(repo: rep)
                removeCommitsFromDB(repoName: id)
            }
            
        } else {
            self.favorites.append(rep)
    
            saveOneRepoToDB(repo: rep)
            
            if let urlCommits = rep.commitsUrl, let id = rep.id {
                GitHubService.shared.getInfoRepo(commitsUrl: urlCommits, repoName: id) { commits in
                    self.saveCommitsToDB(commits: commits)
                }
            }
        }
        
    }
    
    func favoritesLoaded(repos: [Repositary]) {
        favorites = repos
        delegate?.refresh()
        delegateFavorites?.refresh()
    }
    
    
    //work with db
    private func saveOneRepoToDB(repo: Repositary) {
        let newRepo = repo.copyRepo()
        
        guard let fullName = newRepo.fullName, let login = GitHubService.shared.userName else {
            return
        }
            
        //save login for different favorites of different users
        newRepo.id = fullName + login
        newRepo.login = login
        repo.id = newRepo.id //for commits
        
        do {
            try? self.localRealm.write {
                self.localRealm.add(newRepo, update: .modified)
                
            }
        }
        
    }
    
    func readReposFromDB() {
        if let login = GitHubService.shared.userName{
            let  savedrepos = self.localRealm.objects(Repositary.self).filter("login = %@", login)
            
            guard !savedrepos.isEmpty else {
                return
            }
            
            favorites = Array(savedrepos)
        }
    }
    
    func removeRepoFromDB(repo: Repositary) {
        let obj = self.localRealm.object(ofType: Repositary.self, forPrimaryKey: repo.id)
            do {
                try self.localRealm.write {
                    if obj != nil {
                    self.localRealm.delete(obj!)
                    }
                }
            } catch {
                print("error removing from db")
            }
    }
    
    func saveCommitsToDB(commits: [ElementCommit]?) {
        
        guard let commits = commits else {
            return
        }
        
        var newCommits : [ElementCommit] = []
        for commit in commits {
            let newCommit = commit.copyCommit()
            
            if let id = newCommit.id, let login = GitHubService.shared.userName {
                //save logins of different users because not to delete common commits
                newCommit.login = login
                newCommit.uniqId = id + login
                commit.uniqId = newCommit.uniqId
            }
            
            newCommits.append(newCommit)
        }

            do {
                try self.localRealm.write {
                    self.localRealm.add(newCommits, update: .modified)
                }
            } catch {
                print("error saving commits into db")
            }
        
    }
    
    func readCommitsFromDB(repoName: String) {
        
        if let login = GitHubService.shared.userName {
        
            let  savedrepos = self.localRealm.objects(ElementCommit.self).filter("repoName = %@ AND login = %@", repoName, login)
                self.currentCommits = Array(savedrepos)
        }
            
    }
    
    func removeCommitsFromDB(repoName: String) {
        
        guard let login = GitHubService.shared.userName else {
            return
        }
        
            do {
                try self.localRealm.write {
                    let objectsToDelete = self.localRealm.objects(ElementCommit.self).filter("repoName = %@ AND login = %@", repoName, login)
                        self.localRealm.delete(objectsToDelete)
                }
            } catch {
                print("error removing commits from db")
            }
    }
    
}


