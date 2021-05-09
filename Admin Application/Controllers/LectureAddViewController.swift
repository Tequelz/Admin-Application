import UIKit

class LectureAddViewController: UIViewController { //Create the class, passing in that its a UIViewController
    
    @IBOutlet weak var lec_num: UITextField!
    @IBOutlet weak var lec_len: UITextField! //Create outlets to obtain information entered into the fields
    
    var key:String = ""
    var lec_id:String = ""
    var email: String = "" //These values are made to be assigned values from the previous view
    
    func failed(error: String) { //Create a function for providing pop up errors
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func lectureCreate(uploadData: Data){ //This function takes in data and proceeds to create a lecture with that data
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-create/")! //set the correct path for lecture creation
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in //This section of the code is used to create a URLSession and then uploads the data to the endpoint stated in the request
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
                let data = data{ //Upon the correct reception of data load up the Lecture view
                DispatchQueue.main.async {
                
                let story = UIStoryboard(name: "Main",bundle:nil)
                let controller = story.instantiateViewController(identifier: "Lecture") as! LectureViewController
                    controller.lec_id = self.lec_id //Pass in values for innitalising the next view
                    controller.key = self.key
                    controller.email = self.email
                    controller.modalPresentationStyle = .fullScreen
                    controller.modalTransitionStyle = .crossDissolve
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        task.resume() //set task tor resume so request is run and then looks for returned data
    }
    
    
    @IBAction func addLectureButton(_ sender: Any) { //This is the button that starts the process of creating lecture using the values entered in the text fields to create some Lecture strtucture instances that are converted into JSON data, the data is then sent to the API using the lectureCreate function
        
        
        let lecNum = Int(lec_num.text!)
        let lecLen = Int(lec_len.text!)

        let lecture = Lecture(lec_id: Int(self.lec_id)!, lec_number: lecNum!, lec_length: lecLen!)
        
        guard let uploadData = try? JSONEncoder().encode(lecture) else{
            return
        }
        
        self.lectureCreate(uploadData: uploadData)
    }
    
    @IBAction func backButton(_ sender: Any) {// This button sends the user back to the Lecture view and passes in the correpsonding data for initalising the next view
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
