//
//  ViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 05.11.2021.
//

import UIKit
import KeychainAccess


class ViewController: UIViewController {
    
    @IBOutlet private weak var loginTextView: UITextField!
    
    @IBOutlet private weak var tokenTextView: UITextField!
    
    let gitHubService = GitHubService.shared
    
    private var user: String?
    
    private var token: String?
    
    private var saveCredentials = true
    
 
    @IBOutlet weak var btnSaveCredentials: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //tokenTextView.text =
        
        //try to authenticate with last input token
        tryLastAuthentication()
        
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.changeSavingCredentials(_:)))
        
        btnSaveCredentials.addGestureRecognizer(tabGestureRecognizer)
        showBtnSaveCredentials()
    
    }

   
    @IBAction func authGit(_ sender: Any) {
         
        guard let token = tokenTextView.text, let user = loginTextView.text else {
            return
        }
        self.token = token
        self.user = user
            
        gitHubService.authenticateUsr(user: user, token: token, completion: { success in
            if success {
                self.complitAuth()
            } else {
                
                let alert = UIAlertController(title: "Authenticating failed", message: "error.", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
               
                self.present(alert, animated: true)
            }
        })
              
    }
    
    
    
    func complitAuth() {
        
        let userStr = user ?? ""
        
        if saveCredentials {
            try? savePassword(login: userStr, password: token)
        }
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "myTabBarVC")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)


}
    func savePassword(login: String, password: String?) throws {
        
        guard let password = password else {
            return
        }
        
        var notEmptyLogin = "_"
        if login != "" {
            notEmptyLogin = login
        }
        
        let keychain = Keychain(service: "MyGithubClientApp")
        keychain[notEmptyLogin] = password
        
        keychain["lastIncome"] = password
    }
    
    func loadPassword(login: String) throws -> String {
        let keychain = Keychain(service: "MyGithubClientApp")
        if let receivedPassword = keychain[login] {
            return receivedPassword
        }
        return ""
    }
    
    private func tryLastAuthentication() {
        guard let lastToken = try? loadPassword(login: "lastIncome") else {
            return
        }
        
        if lastToken != "" {
            gitHubService.authenticateUsr(user: "", token: lastToken, completion: { success in
                if success {
                    self.complitAuth()
                }
            })
        }
    }
    
    private func showBtnSaveCredentials() {
        if saveCredentials {
            btnSaveCredentials.image = UIImage(systemName: "checkmark.seal.fill")
        } else {
            btnSaveCredentials.image = UIImage(systemName: "checkmark.seal")
        }
    }
    
    @objc private func changeSavingCredentials(_ sender: UIGestureRecognizer) {
        saveCredentials = !saveCredentials
        showBtnSaveCredentials()
    }
    
}
