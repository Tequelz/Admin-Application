import UIKit

class LectureAddViewController: UIViewController {
    
    @IBOutlet weak var lec_num: UITextField!
    @IBOutlet weak var lec_len: UITextField!
    
    var key:String = ""
    var lec_id:String = ""
    var email: String = ""
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func lectureCreate(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-create/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                self.failed(error: "Error in app side (When creating lecture) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.failed(error: "Error in server side (When creating lecture)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{
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
    
    
    @IBAction func addLectureButton(_ sender: Any) {
        
        
        let lecNum = Int(lec_num.text!)
        let lecLen = Int(lec_len.text!)

        let lecture = Lecture(lec_id: Int(self.lec_id)!, lec_number: lecNum!, lec_length: lecLen!)
        
        guard let uploadData = try? JSONEncoder().encode(lecture) else{
            return
        }
        
        self.lectureCreate(uploadData: uploadData)
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
