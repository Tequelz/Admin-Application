//
//  TechChoiceViewController.swift
//  Admin Application
//
//  Created by John Doe on 02/05/2021.
//

import UIKit

class TechChoiceViewController: UIViewController {
    
    var code:String = ""
    var key:String = ""
    var lec_id:String = ""
    var email:String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btLoadButton(_ sender: Any) {
        
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
    
    
    @IBAction func qrLoadButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "QRShow") as! QRShowViewController
                controller.code = self.code
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
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
