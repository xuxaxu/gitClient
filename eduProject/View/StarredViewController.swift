//
//  StarredViewController.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 10.11.2021.
//

import UIKit

class StarredViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    var dataModel = DataModel()
    
    var repositaries : [Repositary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    

    private func configure() {
        self.view.backgroundColor = .systemTeal
    }

}

extension StarredViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell {
            let rep = repositaries[indexPath.row]
            //cell.configure(text: rep.name ?? "", text2: rep.description ?? "", lang: rep.language ?? "", forks: rep.forksCount ?? 0, stars: rep.stars ?? 0, owner: rep.owner)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
