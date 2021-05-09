import UIKit

class StudentCellTableViewCell: UITableViewCell { //This will be cell that is placed for every student in a lecture
    
    
    @IBOutlet weak var nameLabel: UILabel! //Create outlets for the labels within the cell
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
