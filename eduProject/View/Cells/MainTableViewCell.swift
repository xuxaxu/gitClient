//
//  MainTableViewCell.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 14.11.2021.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet private weak var lblMain: UILabel!
    
    @IBOutlet private weak var lbl2: UILabel!
    
    @IBOutlet private weak var foto: UIImageView!
    
    @IBOutlet private weak var authorLbl: UILabel!
    
    @IBOutlet private weak var langLbl: UILabel!
    
    @IBOutlet private weak var forksLbl: UILabel!
    
    @IBOutlet weak var starsLbl: UILabel!
        
    @IBOutlet weak var favBtn: UIButton!
    
    var rep: Repositary?
    
    var chooseFavorite : ((Repositary) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(fav: Bool) {
        lblMain.text = rep?.name
        lbl2.text = rep?.descript ?? ""
        foto.image = DataService.shared.getAvatar(url: rep?.owner?.avatarUrl)
        langLbl.text = rep?.language
        forksLbl.text = "⑂" + String(rep?.forksCount ?? 0)
        starsLbl.text = "✮" + String(rep?.stars ?? 0)
        authorLbl.text = rep?.owner?.login
        
        foto.layer.cornerRadius = foto.frame.height / 2
        
        if fav {
            favBtn.setTitle("❤️", for: .normal)
        } else {
            favBtn.setTitle("🤍", for: .normal)
        }
        
    }
    
    
    @IBAction func favoriteAction(_ sender: Any) {
        if let rep = self.rep, let favAction = self.chooseFavorite {
            favAction(rep)
        }
    }
    
}
