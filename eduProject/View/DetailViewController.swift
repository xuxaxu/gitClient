//
//  DatailViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 15.11.2021.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private weak var nameRepoLbl: UILabel!
    
    @IBOutlet private weak var avatarImgView: UIImageView!
    
    @IBOutlet private weak var ownerLbl: UILabel!
    
    @IBOutlet private weak var descriptionLbl: UILabel!
    
    @IBOutlet private weak var langLbl: UILabel!
    
    @IBOutlet private weak var forksLbl: UILabel!
    
    @IBOutlet private  weak var starsLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var repo : Repositary?
    
    private var animateView = AnimationView()
    
    let refreshControl = UIRefreshControl()
    
    var showAnimate = true
    
    override func viewDidLoad() {
        
        if self.showAnimate {
            self.animateView.startInVC(vc: self)
        }
        
        super.viewDidLoad()

        DataService.shared.delegateCommit = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCellCommit", bundle: .main), forCellReuseIdentifier: "commitCell")
        
        
        
        configure()
        
    }
    
    func configure() {
        if let rep = repo {
            nameRepoLbl.text = rep.name
            avatarImgView.image = DataService.shared.getAvatar(url: rep.owner?.avatarUrl)
            avatarImgView.layer.cornerRadius = avatarImgView.frame.height / 2
            ownerLbl.text = rep.owner?.login
            descriptionLbl.text = rep.descript
            langLbl.text = rep.language
            if let forks = rep.forksCount {
                forksLbl.text = "⑂" + String(forks)
            } else {
                forksLbl.text = "⑂ 0"
            }
            if let stars = rep.stars {
                starsLbl.text = "✰" + String(stars )
            } else {
                starsLbl.text = "✰ 0"
            }
            
        } else {
            //self.dismiss(animated: true, completion: nil)
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.reloadCommits(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func reloadCommits(_ sender: AnyObject ) {
        if let commitsUrl = repo?.commitsUrl {
            
            //show animation while refresh
            self.animateView.startInVC(vc: self)
            
            DataService.shared.loadCommits(commitsUrl: commitsUrl, repoName: repo?.fullName ?? "nopes")
        }
    }
    
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.shared.currentCommits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commitCell", for: indexPath) as? TableViewCellCommit, indexPath.row < DataService.shared.currentCommits.count {
                let elCommit = DataService.shared.currentCommits[indexPath.row]
            cell.configure(date: elCommit.commit?.commitDate?.date, author: elCommit.committer?.login ?? "", avatar: DataService.shared.getAvatar(url: elCommit.committer?.avatarUrl), commit: elCommit.commit?.massage ?? "")
                return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60//ITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60//UITableView.automaticDimension
    }
    
}

extension DetailViewController : DataModelDelegate {
    
    func refresh() {
        tableView.reloadData()
    }
    
    func refreshRow(index: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func error() {
               let alert = UIAlertController(title: "Detail info is not available", message: "error of getting data of the repository", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
               
                self.present(alert, animated: true)
    
    }
    
    func endAnimation() {
        animateView.removeFromVC()
        refreshControl.endRefreshing()
    }
    
}
