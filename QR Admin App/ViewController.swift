//
//  ViewController.swift
//  Login Page
//
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func loginButton(_ sender: Any) {
        
        DispatchQueue.main.async {
//            let parentController = self.presentingViewController
//            parentController!.dismiss(animated: true){
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "LoginView") as! LoginViewController
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                
                self.present(controller, animated: true, completion: nil)
            //}

        }
    }
    
}




class RequestSender {
    
}

