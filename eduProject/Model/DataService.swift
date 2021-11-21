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
    
    func loadImages(repos: [Repositary]) {
        for (index,rep) in repos.enumerated() {
                if let avUrl = rep.owner?.avatarUrl {
                    ImagesService.shared.getImage(url: avUrl) { image in
                        if let img = image {
                            self.avatars[avUrl] = img
                            self.delegate?.refreshRow(index: index)
                        }
                    }
                        
                    }
            }
    }
    
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

    //favorites
    func chooseFavorite(_ rep : Repositary) {
    
        
        if let index = self.favorites.containRep(rep: rep) {
            self.favorites.remove(at: index)
            
            self.delegate?.refresh()
            
            let fullName = rep.fullName
            removeRepoFromDB(repo: rep)
            
            removeCommitsFromDB(repoName: fullName ?? "")
            
        } else {
            self.favorites.append(rep)
            //saveReposToDB(repos: favorites)
            saveOneRepoToDB(repo: rep)
            
            if let urlCommits = rep.commitsUrl, let fullName = rep.fullName {
                GitHubService.shared.getInfoRepo(commitsUrl: urlCommits, repoName: fullName) { commits in
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
        do {
            try self.localRealm.write {
                self.localRealm.add(newRepo, update: .modified)
                
            }
        } catch {
            print("error saving into db")
        }
        
    }
    
    private func saveReposToDB(repos: [Repositary]) {
        
            do {
                try self.localRealm.write {
                    self.localRealm.add(repos, update: .modified)
                    
                }
            } catch {
                print("error saving into db")
            }
        
        
    }
    
    func readReposFromDB() {
            
            let  savedrepos = self.localRealm.objects(Repositary.self)
            
            guard !savedrepos.isEmpty else {
                return
            }
            
            favorites = Array(savedrepos)
    }
    
    func removeRepoFromDB(repo: Repositary) {
        let obj = self.localRealm.object(ofType: Repositary.self, forPrimaryKey: repo.fullName)
            do {
                try self.localRealm.write {
                    if obj != nil {
                    self.localRealm.delete(obj!)
                    }
                }
            } catch {
                print("error saving into db")
            }
    }
    
    private func saveCommitsToDB(commits: [ElementCommit]?) {
        
        guard let commits = commits else {
            return
        }
        
        var newCommits : [ElementCommit] = []
        for commit in commits {
            let newCommit = commit.copyCommit()
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
        
            let  savedrepos = self.localRealm.objects(ElementCommit.self).filter("repoName = %@", repoName)
                self.currentCommits = Array(savedrepos)
            
    }
    
    func removeCommitsFromDB(repoName: String) {
            do {
                try self.localRealm.write {
                    let objectsToDelete = self.localRealm.objects(ElementCommit.self).filter("repoName = %@", repoName)
                        self.localRealm.delete(objectsToDelete)
                }
            } catch {
                print("error saving into db")
            }
    }
    
}


