//
//  TableViewCellCommit.swift
//  eduProject
//
//  Created by Ксения Каштанкина on 15.11.2021.
//

import UIKit

class TableViewCellCommit: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var authorLbl: UILabel!
    
    @IBOutlet weak var commitLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(date: String?, author: String, avatar: UIImage, commit: String?) {
        if let dateStr = date {
            //let dateFormatter = ISO8601DateFormatter()
            dateLbl.text = dateStr//dateFormatter.string(from: dateStr)
        } else {
            dateLbl.text = ""
        }
        self.avatar.image = avatar
        self.avatar.layer.cornerRadius = self.avatar.frame.height / 2
        self.authorLbl.text = author
        self.commitLbl.text = commit
    }
    
}
