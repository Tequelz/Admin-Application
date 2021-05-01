//
//  Helper.swift
//  QR Admin App
//
//  Created by John Doe on 01/05/2021.
//

import Foundation
import UIKit


func moveScreen(id:String, control: UIViewController){
    DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "Login") as! LoginViewController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)

    }
}

