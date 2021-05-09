import UIKit

struct Login: Codable { //Structure used in the Login process
    
    let username: String
    let email: String
    let password:String
    
}
struct AuthKey: Decodable { //Structure used to obtain the Token

    let key: String
    
}
struct CodeSender: Codable { //Structure used in the sending of the attendance tracking code
    
    let code: Int
    
}
struct UserSender: Codable { //Allows the userID to be packaged for sending via a request
    
    let userID:Int
    
}
struct Lecture: Codable { //Structure that allows lectures to be created with the id, number and length
    
    let lec_id:Int
    let lec_number:Int
    let lec_length: Int
    
}

struct LectureID: Codable { //Structure used in the sending of the lecture id
    
    let lecID:String
    
}
struct Module: Codable { //Structure used to send request data to create a new module
    
    let mod_id: String
    let mod_teacher:Int
    let mod_name:String
    
}



class ViewController: UIViewController {//This function allows the user to locate the login page with that being loaded through a view instantiation

    @IBAction func loginButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "Login") as! LoginViewController
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
}

