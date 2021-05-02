//
//  BTShowViewController.swift
//  Admin Application
//
//  Created by John Doe on 02/05/2021.
//

import UIKit

class BTShowViewController: UIViewController {
    
    var code:String = ""
    var email:String = ""
    var key:String = ""
    var lec_id:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "TechChoice") as! TechChoiceViewController
                controller.code = self.code
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
}
