import UIKit

class LectureAddViewController: UIViewController {
    
    var key:String = ""
    var lec_id:String = ""
    var email: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var lec_num: UITextField!
    @IBOutlet weak var lec_len: UITextField!
    
    @IBAction func addLectureButton(_ sender: Any) {
        
        
        let lecNum = Int(lec_num.text!)
        let lecLen = Int(lec_len.text!)

        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        let lecture = Lecture(lec_id: Int(self.lec_id)!, lec_num: lecNum!, lec_len: lecLen!)
        
        guard let uploadData = try? JSONEncoder().encode(lecture) else{
            return
        }
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-create/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + authKey.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
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
        task.resume()
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
