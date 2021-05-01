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
    let lec_num:Int
    let lec_len: Int
    
}
struct Lecture1: Codable{
    
    let lec_id:String
    let lec_name:String
    let lec_number:String
    let lec_teacher:Int
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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

