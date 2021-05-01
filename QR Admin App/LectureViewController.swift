//
//  LectureViewController.swift
//  QR Admin App
//
//  Created by John Doe on 01/05/2021.
//

import UIKit

struct LectureID: Codable {
    let lecID:String
}

class LectureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var key: String = ""
     
    var lec_id: String = ""
    
    var email:String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var lectureNumberArray = [Int]()
    var lectureLengthArray = [Int]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lectureNumberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LectureCell")! as! LectureTableViewCell
        cell.lectureNumberLabel.text = String(self.lectureNumberArray[indexPath.row])
        cell.lectureLengthLabel.text = String(self.lectureLengthArray[indexPath.row])
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        print("Cell cliked value is \(indexPath.row)")


        DispatchQueue.main.async {
            
            let lecture = Lecture(lec_id: Int(self.lec_id)!, lec_num: self.lectureNumberArray[indexPath.row], lec_len: self.lectureLengthArray[indexPath.row])
            
            guard let uploadData = try? JSONEncoder().encode(lecture) else{
                return
            }
            
            let dataString = String(data: uploadData, encoding: .utf8)
            

        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "QRShowView") as! QRShowViewController
            controller.code = dataString!
            controller.key = self.key
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve

            self.present(controller, animated: true, completion: nil)
//        let navigation = UINavigationController(rootViewController: controller)
//        self.view.addSubview(navigation.view)
//        self.addChild(navigation)
//        navigation.didMove(toParent: self)
        }

     }
    @IBAction func createLectureButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "LectureAddView") as! LectureAddViewController
            controller.key = self.key
            controller.lec_id = self.lec_id
            controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                
                self.present(controller, animated: true, completion: nil)
            

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        let lectureID = LectureID(lecID: lec_id)
        print(lectureID)
        
        guard let uploadData = try? JSONEncoder().encode(lectureID)else{
            return
        }
        print(uploadData)
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-view/")!
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
                let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                if let jsonArray = jsonObj as? NSArray{
                    for obj in jsonArray{
                        print(obj)
                        if let objDict = obj as? NSDictionary{
                            if let name = objDict.value(forKey: "lec_number"){
                                self.lectureNumberArray.append(name as! Int)
                                print(name)
                            }
                            if let name = objDict.value(forKey: "lec_length"){
                                self.lectureLengthArray.append(name as! Int)
                                print(name)
                            }
                            OperationQueue.main.addOperation( {
                                self.tableView.reloadData()
                            })
                
                        }
                    }
                }
            }
        }
            
        task.resume()
        

        
        

        

        // Do any additional setup after loading the view.
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
