import UIKit

class LectureTableViewCell: UITableViewCell { //Create the template of a cell used to represent lectures
    
    
    @IBOutlet weak var lectureNumberLabel: UILabel! //Take in the outlets for the labels that'll be changed for
    @IBOutlet weak var lectureLengthLabel: UILabel!// every lecture
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
