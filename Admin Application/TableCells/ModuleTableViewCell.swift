import UIKit

class ModuleTableViewCell: UITableViewCell { // Creates a cell template for every module in the tableView

    @IBOutlet weak var moduleIDLabel: UILabel! //Pass in the outlets for the labels that'll be changed
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
