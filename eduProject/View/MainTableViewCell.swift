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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String, text2: String?, lang: String, forks: Int, stars : Int, owner : User?, avatar: UIImage?) {
        lblMain.text = text
        lbl2.text = text2 ?? ""
        foto.image = avatar
        langLbl.text = lang
        forksLbl.text = "⑂" + String(forks)
        starsLbl.text = "✮" + String(stars)
        authorLbl.text = owner?.login
        
        foto.layer.cornerRadius = foto.frame.height / 2
        
    }
    
}
