//
//  NetworkService.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 14.11.2021.
//

import Foundation

class GitHubService {
    
    static let shared = GitHubService()
    
    var user : User?
    var token : String?
    var userName : String?
         
    private init () {}
    
    func getRepositories(completion: @escaping ([Repositary]?) -> Void) {
        

        guard let userName = self.userName, let token = self.token else {
            completion( nil)
            return
        }

        guard let URL =  URL(string: "https://api.github.com/repositories") else { //URL(string: "https://api.github.com/user/repos") else {
            completion( nil)
            return
        }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        // Headers

        let userTokenBase64 = Data("\(userName):\(token)".utf8).base64EncodedString()
        
        request.addValue("Basic " + userTokenBase64, forHTTPHeaderField: "Authorization")

        /* Start a new Task */
        DispatchQueue.global(qos: .background).async {
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error == nil,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200,
                    let data = data,
                   let repos = try? JSONDecoder().decode([Repositary].self, from: data) {
                    
                    DispatchQueue.main.async {
                        completion(repos)
                    }
                } else {
                    // Failure
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            })
            
            task.resume()
        }
        
        //session.finishTasksAndInvalidate()
        
    }
    
    func getAdditinalInfo(repo: Repositary, completion: @escaping (Repositary?) -> Void) {
        //get language, forks and stars
        
        guard let userName = self.userName, let token = self.token, let fullName = repo.fullName else {
            completion( nil)
            return
        }

        guard let URL =  URL(string: "https://api.github.com/repos/" + fullName) else {
            completion( nil)
            return
        }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        // Headers
        let userTokenBase64 = Data("\(userName):\(token)".utf8).base64EncodedString()
        
        request.addValue("Basic " + userTokenBase64, forHTTPHeaderField: "Authorization")

        /* Start a new Task */
        DispatchQueue.global(qos: .background).async {
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error == nil,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200,
                    let data = data,
                    let repoInfo = try? JSONDecoder().decode(Repositary.self, from: data) {
                    
                    repo.language = repoInfo.language
                    repo.forksCount = repoInfo.forksCount
                    repo.stars = repoInfo.stars
                    
                    DispatchQueue.main.async {
                        completion(repo)
                    }
                } else {
                    // Failure
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            })
            
            task.resume()
        }
        
    }
    
    func getInfoRepo(commitsUrl: String, repoName: String, completion: @escaping ([ElementCommit]?) -> Void) {
        
        guard let userName = self.userName, let token = self.token else {
            completion( nil)
            return
        }
        
        let commitStr = commitsUrl.replacingOccurrences(of: "{/sha}", with: "")
        
        
        guard let comUrl = URL(string: commitStr) else {
            completion( nil)
            return
        }
        var request = URLRequest(url: comUrl)
        request.httpMethod = "GET"

        // Headers

        let userTokenBase64 = Data("\(userName):\(token)".utf8).base64EncodedString()
        
        request.addValue("Basic " + userTokenBase64, forHTTPHeaderField: "Authorization")

        /* Start a new Task */
        DispatchQueue.global(qos: .background).async {
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error == nil,
                    let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200,
                    let data = data,
                    var repoDecoded = try? JSONDecoder().decode([ElementCommit].self, from: data) {
                    if repoDecoded.count > 10 {
                        repoDecoded = repoDecoded.dropLast(repoDecoded.count - 10)
                    }
                    for commit in repoDecoded {
                        commit.repoName = repoName
                    }
                    
                    DispatchQueue.main.async {
                        completion(repoDecoded)
                    }
                } else {
                    // Failure
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            })
            
            task.resume()
        }
    }
    
    
    func authenticateUsr(user: String, token: String, completion: @escaping (Bool) -> Void) {

        
        guard let URL = URL(string: "https://api.github.com/user") else {return completion(false)}
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        // Headers

        let userTokenBase64 = Data("\(user):\(token)".utf8).base64EncodedString()
        
        request.addValue("Basic " + userTokenBase64, forHTTPHeaderField: "Authorization")

        /* Start a new Task */
        DispatchQueue.global(qos: .background).async {
        
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200, let data = data {
                    let user = try? JSONDecoder().decode(User.self, from: data)
                    
                    self.user = user
                    self.userName = user?.login
                    self.token = token
                    
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    // Failure
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            })
            
            task.resume()
        }
        //session.finishTasksAndInvalidate()
    }
   
}
