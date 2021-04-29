//
//  MyCellTableViewCell.swift
//  Login Page
//
//

import UIKit

class MyCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lectureIDLabel: UILabel!
    
    
    @IBOutlet weak var lectureNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
