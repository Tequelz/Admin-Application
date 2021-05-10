import UIKit

class TechChoiceViewController: UIViewController { //Class that is used for the user to choose a technology for the tracking of attendance
    
    var code:String = ""
    var key:String = ""
    var lec_id:String = ""
    var email:String = "" //These four variables are used to take in values from the previous controller
    
    @IBAction func btLoadButton(_ sender: Any) { //This function handles the Bluetooth button being clicked with the data being passed along into the TransmitBT view
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "TransmitBT") as! TransmitBTViewController
                controller.code = self.code
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func qrLoadButton(_ sender: Any) {//This function handles the QR button being clicked with the data being passed along into the QRShow view
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "QRShow") as! QRShowViewController
                controller.code = self.code
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                print(self.email)
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) { //This function takes the user back to the previous view of Lecture
        DispatchQueue.main.async {
        
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "Lecture") as! LectureViewController
            controller.lec_id = self.lec_id
            controller.key = self.key
            controller.email = self.email
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}
