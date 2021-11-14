//
//  MainViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 10.11.2021.
//

import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak private var tableView: UITableView!
    
    private var repositaries : [Repositary] = []
    private var dataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemTeal
        
        dataModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "mainCell")
        
        configure()
    }
    
    private func configure() {
        
        dataModel.loadData()
        
        self.tableView.backgroundColor = .systemTeal
        
        self.tableView.estimatedRowHeight = 104

    }
}

extension MainViewController : DataModelDelegate {
    
    func dataDidRecieve(data: [Repositary]) {
        self.repositaries = data
        self.tableView.reloadData()
    }
    
    func error() {
               let alert = UIAlertController(title: "Net is not available", message: "error of getting repositories", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
               
                self.present(alert, animated: true)
    
    }
    
    func avatarLoaded(img: UIImage, repoName: String) {
        var inx = 0
        for (index, item) in repositaries.enumerated() {
            if item.name == repoName {
                repositaries[index].avatar = img
                inx = index
                break
            }
        }
        self.tableView.reloadRows(at: [IndexPath(row: inx, section: 0)], with: .fade)
    }
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell {
            let rep = repositaries[indexPath.row]
            cell.configure(text: rep.name ?? "", text2: rep.description ?? "", lang: rep.language ?? "unknown", forks: rep.forksCount ?? 0, stars: rep.stars ?? 0, owner: rep.owner, avatar: rep.avatar)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104//ITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104//UITableView.automaticDimension
    }
    
}
