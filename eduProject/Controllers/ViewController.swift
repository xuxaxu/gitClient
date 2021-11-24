//
//  ViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 05.11.2021.
//

import UIKit
import KeychainAccess


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var loginTextView: UITextField!
    
    @IBOutlet private weak var tokenTextView: UITextField!
    
    //check authentication
    let gitHubService = GitHubService.shared
    
    private var user: String?
    
    private var token: String?
    
    private var saveCredentials = true
    
 
    @IBOutlet weak var btnSaveCredentials: UIImageView!
    
    //default - use auto, if after exit - no auto
    var tryAutoAuthentication = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextView.delegate = self
        
        //try to authenticate with last input token
        if tryAutoAuthentication {
            tryLastAuthentication()
        }
        
        //for switch saving credentials
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.changeSavingCredentials(_:)))
        
        btnSaveCredentials.addGestureRecognizer(tabGestureRecognizer)
        showBtnSaveCredentials()
            
    }

   //authentication to github
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
    
    //show main vc after success auth
    func complitAuth() {
        
        let userStr = user ?? ""
        
        if saveCredentials {
            try? savePassword(login: userStr, password: token)
        }
        
        //clear for possible exit from auth
        loginTextView.text = nil
        tokenTextView.text = nil
        
        //tab bar is in storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "myTabBarVC")
        vc.modalPresentationStyle = .fullScreen
        if let myTab = vc as? MyTabBarVC {
            myTab.authVC = self
        }
        self.present(vc, animated: true)
    }
    
    //saving token in keychain after succesfull auth
    func savePassword(login: String, password: String?) throws {
        
        guard let password = password else {
            return
        }
        
        var notEmptyLogin = "_"
        if login != "" {
            notEmptyLogin = login
        }
        
        //name of the app for surching in keychain
        let keychain = Keychain(service: "MyGithubClientApp")
        keychain[notEmptyLogin] = password
        
        //use "lastIncome" for saving and surching last succesfull auth
        keychain["lastIncome"] = password
    }
    
    //find password for login and our app in keychain
    private func loadPassword(login: String) throws -> String {
        let keychain = Keychain(service: "MyGithubClientApp")
        if let receivedPassword = keychain[login] {
            return receivedPassword
        }
        return ""
    }
    
    //try find token from last auth and try to auth with it
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
    
    //connection checkmark view and variable
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
    
    //surch saved token for entering login in keychain and fill textview
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == loginTextView, let textLogin = textField.text {
            if let savedPassword = try? loadPassword(login: textLogin) {
                tokenTextView.text = savedPassword
            }
        }
    }
    
}
