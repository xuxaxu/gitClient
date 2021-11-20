//
//  StarredViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 10.11.2021.
//

import UIKit

class StarredViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainTableViewCell", bundle: .main), forCellReuseIdentifier: "mainCell")
        
        configure()
    }
    

    private func configure() {
        self.view.backgroundColor = .systemTeal
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

}

extension StarredViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DataService.shared.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell {
            let rep = DataService.shared.favorites[indexPath.row]
            cell.rep = rep
            cell.chooseFavorite = chooseFavorite(_:)
            cell.configure(fav: true)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func chooseFavorite(_ rep : Repositary) {
        
        DataService.shared.chooseFavorite(rep)
        tableView.reloadData()
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < DataService.shared.favorites.count {
            let repoToShow = DataService.shared.favorites[indexPath.row]
            if let nc = self.navigationController {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let newVC = sb.instantiateViewController(withIdentifier: "detailVCid") as! DetailViewController
                newVC.repo = repoToShow
                nc.pushViewController(newVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104//ITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104//UITableView.automaticDimension
    }
}
