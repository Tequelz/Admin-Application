//
//  ModuleTableViewCell.swift
//  QR Admin App
//
//  Created by John Doe on 01/05/2021.
//

import UIKit

class ModuleTableViewCell: UITableViewCell {

    @IBOutlet weak var moduleIDLabel: UILabel!
    
    @IBOutlet weak var moduleNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
