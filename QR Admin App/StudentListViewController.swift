//
//  StudentListViewController.swift
//  QR Admin App
//
//  Created by John Doe on 30/04/2021.
//

import UIKit


struct StudentView: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }
    
    let studentName: Int
    let studentEmail: String
}

struct CodeSender: Codable {
    let code: Int
}

struct UserSender: Codable {
    let userID:Int
}


class StudentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var key:String = ""
    
    var code:String = ""
    
    var lecture_id:Int = 0
    
    var studentNameArray = [String]()
    var studentEmailArray = [String]()
    var studentIDArray = [Int]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StudentCell")! as! StudentCellTableViewCell
        cell.nameLabel.text = String(self.studentNameArray[indexPath.row])
        cell.emailLabel.text = self.studentEmailArray[indexPath.row]
        
        return cell
    }
    
    
    
    @IBAction func backModules(_ sender: Any) {
        DispatchQueue.main.async {
        
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "Module") as! ModuleViewController
            controller.key = self.key
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
        
        let lecJSONData = self.code.data(using: .utf8)!
        let lecData: Lecture = try! JSONDecoder().decode(Lecture.self, from: lecJSONData)

        
        guard let uploadData = try? JSONEncoder().encode(lecData)else{
            return
        }
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-check/")!
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
                        if let objDict = obj as? NSDictionary{
                            if let lecture_id = objDict.value(forKey: "pk"){
                            self.lecture_id = lecture_id as! Int
                                print(self.lecture_id)
                                
                                let codeTransport = CodeSender(code: self.lecture_id)
                                guard let uploadData = try? JSONEncoder().encode(codeTransport) else{
                                    return
                                }
                                let url = URL(string: "https://project-api-sc17gt.herokuapp.com/class-attendance/")!
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
                                                    if let name = objDict.value(forKey: "username"){
                                                        self.studentIDArray.append(name as! Int)
                                                        
                                                        let userIDTransport = UserSender(userID : name as! Int)
                                                        guard let uploadData = try? JSONEncoder().encode(userIDTransport) else{
                                                            return
                                                        }
                                                        
                                                        
                                                        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/get-user-by-id/")!
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
                                                                            if let name = objDict.value(forKey: "username"){
                                                                                self.studentNameArray.append(name as! String)
                                                                                print(name)
                                                                            }
                                                                            if let name = objDict.value(forKey: "email"){
                                                                                self.studentEmailArray.append(name as! String)
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
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                    
                                task.resume()
        
        
        

        // Do any additional setup after loading the view.
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
                            }

                        }
                    }
                }
            }
            
        }
        task.resume()
    }
}


