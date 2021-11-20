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
    
    private var commits : [ElementCommit] = []
    
    private var dataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataModel.delegateCommit = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCellCommit", bundle: .main), forCellReuseIdentifier: "commitCell")
        
        configure()
        
    }
    
    func configure() {
        if let rep = repo {
            nameRepoLbl.text = rep.name
            avatarImgView.image = rep.avatar
            avatarImgView.layer.cornerRadius = avatarImgView.frame.height / 2
            ownerLbl.text = rep.owner?.login
            descriptionLbl.text = rep.description
            langLbl.text = rep.language
            if let forks = rep.forksCount {
                forksLbl.text = String(forks)
            }
            if let stars = rep.stars {
                starsLbl.text = String(stars )
            }
            if let commitsUrl = rep.commitsUrl {
                dataModel.loadCommits(commitsUrl: commitsUrl)
            }
        } else {
            //self.dismiss(animated: true, completion: nil)
        }
    }


}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commitCell", for: indexPath) as? TableViewCellCommit, indexPath.row < commits.count {
                let elCommit = commits[indexPath.row]
                cell.configure(date: elCommit.commit?.commitDate?.date, author: elCommit.committer?.login ?? "", avatar: elCommit.avatar ?? UIImage(), commit: elCommit.commit?.massage ?? "")
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

extension DetailViewController : DataModelCommitDelegate {
    func dataDidRecieve(data: [ElementCommit]) {
        self.commits = data
        self.tableView.reloadData()
    }
    
    func error() {
        let alert = UIAlertController(title: "Repository is not available", message: "error of getting repository's detail" , preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        
         self.present(alert, animated: true)
    }
    
    func avatarLoaded(img: UIImage, index: Int) {
        commits[index].avatar = img
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .middle)
    }
    
}
