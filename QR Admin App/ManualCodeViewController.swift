//
//  ManualCodeViewController.swift
//  Login Page
//
//

import UIKit

struct AuthKey: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }

    let key: String
    
}

struct LessonView: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }
    
    let lectureID: Int
    let lectureName: String
}

class ManualCodeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    
    
    @IBOutlet weak var tableView: UITableView!

    var key:String = ""
    
    var email:String = ""

    @IBOutlet weak var label: UILabel!
    
    var lectureIDArray = [Int]()
    var lectureNameArray = [String]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lectureIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MyCell")! as! MyCellTableViewCell
        cell.lectureIDLabel.text = String(self.lectureIDArray[indexPath.row])
        cell.lectureNameLabel.text = self.lectureNameArray[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        print("Cell cliked value is \(indexPath.row)")
        
        
        DispatchQueue.main.async {
        
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "QRShowView") as! QRShowViewController
            controller.code = String(self.lectureIDArray[indexPath.row])
            controller.email = self.email
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            
            self.present(controller, animated: true, completion: nil)
//        let navigation = UINavigationController(rootViewController: controller)
//        self.view.addSubview(navigation.view)
//        self.addChild(navigation)
//        navigation.didMove(toParent: self)
        }
       
     }
    
    @IBAction func createButton(_ sender: Any) {
        
        DispatchQueue.main.async {
        
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "LessonAdd") as! LessonAddViewController
            controller.key = self.key
        let navigation = UINavigationController(rootViewController: controller)
        self.view.addSubview(navigation.view)
        self.addChild(navigation)
        navigation.didMove(toParent: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lesson-create/?format=json")!
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
                if let jsonArray = jsonObj as? NSArray{
                    for obj in jsonArray{
                        print(obj)
                        if let objDict = obj as? NSDictionary{
                            if let name = objDict.value(forKey: "lec_id"){
                                self.lectureIDArray.append(name as! Int)
                                print(name)
                            }
                            if let name = objDict.value(forKey: "lec_name"){
                                self.lectureNameArray.append(name as! String)
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
        
        let url2 = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/user/")!
        var request2 = URLRequest(url: url2)
        request2.httpMethod = "GET"
        request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request2.setValue("Token " + authKey.key, forHTTPHeaderField: "Authorization")
        
        let task2 = URLSession.shared.dataTask(with: request2) { data, response, error in
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
                        let email = jsonArray.value(forKey: "email")
                        print(email)
                        self.email = email as! String
                    }
                }
            }
        task2.resume()

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

