import UIKit

struct Login: Codable {
    
    let username: String
    let email: String
    let password:String
    
}
struct AuthKey: Decodable {

    let key: String
    
}
struct CodeSender: Codable {
    
    let code: Int
    
}
struct UserSender: Codable {
    
    let userID:Int
    
}
struct Lecture: Codable {
    
    let lec_id:Int
    let lec_number:Int
    let lec_length: Int
    
}

struct LectureID: Codable {
    
    let lecID:String
    
}
struct Module: Codable {
    
    let mod_id: String
    let mod_teacher:Int
    let mod_name:String
    
}



class ViewController: UIViewController {

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

