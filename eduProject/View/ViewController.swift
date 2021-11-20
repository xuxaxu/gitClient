//
//  ViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 05.11.2021.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet private weak var loginTextView: UITextField!
    
    @IBOutlet private weak var tokenTextView: UITextField!
    
    let gitHubService = GitHubService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //loginTextView.text = "xuxaxu"
        tokenTextView.text = "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"
    }

   
    @IBAction func authGit(_ sender: Any) {
         
        guard let token = tokenTextView.text, let user = loginTextView.text else {
            return
        }
            
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
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "myTabBarVC")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)


}

}
