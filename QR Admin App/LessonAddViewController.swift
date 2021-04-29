//
//  LessonAddViewController.swift
//  QR Admin App
//
//  Created by John Doe on 29/04/2021.
//

import UIKit

struct Lecture: Codable{
    let lec_id:String
    let lec_name:String
    let lec_number:String
    let lec_teacher:Int
}




class LessonAddViewController: UIViewController {
    
    var key:String = ""
    
    var userID:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)
        
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/user/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + authKey.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
                let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                if let jsonArray = jsonObj as? NSDictionary{
                    let userID = jsonArray.value(forKey: "pk")
                    print(userID)
                    self.userID = userID as! Int
                    print(self.userID)
                
            
            }
            }
        }
        task.resume()

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBOutlet weak var lecName: UITextField!
    
    @IBOutlet weak var lecID: UITextField!
    
    @IBOutlet weak var lecNumber: UITextField!
    
    
    @IBAction func lectureAddButton(_ sender: Any) {
        
        
        let lectureName = lecName.text
        let lectureId = lecID.text
        let lectureNumber = lecNumber.text
        
        let lecture = Lecture(lec_id: lectureId!, lec_name: lectureName!, lec_number: lectureNumber!, lec_teacher: self.userID)
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)
        
        guard let uploadData = try? JSONEncoder().encode(lecture) else{
            return
        }
        print(lecture)
        
        print(uploadData)
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lesson-create/")!
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
            }
        }
        task.resume()
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
