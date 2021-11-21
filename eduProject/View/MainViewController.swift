//
//  MainViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 10.11.2021.
//

import UIKit

class MainViewController: UIViewController {
    

    @IBOutlet weak private var tableView: UITableView!
    
    private var animateView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemTeal
        
        DataService.shared.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "mainCell")
        
        configure()
    }
    
    private func configure() {
        
        //start animate
        animateView.startInVC(vc: self)
         
        DataService.shared.loadData()
        
        self.tableView.backgroundColor = .systemTeal
        
        self.tableView.estimatedRowHeight = 104

    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
        
    }
    
    func endAnimation() {
        animateView.removeFromVC()
    }
    
}

extension MainViewController : DataModelDelegate {
    
    func refresh() {
        tableView.reloadData()
    }
    
    func refreshRow(index: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func error() {
               let alert = UIAlertController(title: "Net is not available", message: "error of getting repositories", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
               
                self.present(alert, animated: true)
    
    }
    
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.shared.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell {
            let rep = DataService.shared.repositories[indexPath.row]
            cell.rep = rep
            cell.chooseFavorite = chooseFavorite(_:)
            let isContains = (DataService.shared.favorites.containRep(rep: rep) != nil) ? true : false
            cell.configure(fav: isContains)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < DataService.shared.repositories.count {
            let repoToShow = DataService.shared.repositories[indexPath.row]
            if let nc = self.navigationController {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let newVC = sb.instantiateViewController(withIdentifier: "detailVCid") as! DetailViewController
                newVC.repo = repoToShow
                if let commitsUrl = repoToShow.commitsUrl {
                    DataService.shared.loadCommits(commitsUrl: commitsUrl, repoName: repoToShow.fullName ?? "nopes")
                }
                nc.pushViewController(newVC, animated: true)
            }
        }
    }
    
    func chooseFavorite(_ rep : Repositary) {
        
        DataService.shared.chooseFavorite(rep)
        
        if let indx = DataService.shared.repositories.firstIndex(of: rep) {
            tableView.reloadRows(at: [IndexPath(row: indx, section: 0)], with: .fade)
        }
            
    }
    
}
