import UIKit


class StudentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var key:String = ""
    var code:String = ""
    var email:String = ""
    var lecture_id:Int = 0
    var studentNameArray = [String]()
    var studentEmailArray = [String]()
    var studentIDArray = [Int]()
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func getStudents(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-check/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
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
                let data = data{
                    self.pkOfLecture(data: data)
                
                    let codeTransport = CodeSender(code: self.lecture_id)
                    guard let uploadData = try? JSONEncoder().encode(codeTransport) else{
                        return
                    }
                
                    self.classAttendance(uploadData: uploadData)
                }
        }
        task.resume()
    }
    
    func pkOfLecture(data: Data){
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSArray{
                for obj in jsonArray{
                    if let objDict = obj as? NSDictionary{
                        if let lecture_id = objDict.value(forKey: "pk"){
                            self.lecture_id = lecture_id as! Int
                        }
                    }
                }
            }
        }
    }
    
    func classAttendance(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/class-attendance/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
            
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
                let data = data{
                    self.userIDs(data: data)
                    print(self.studentIDArray.count)
                    if self.studentIDArray.count == 0{
                        return
                    }else{
                        for user in 0...(self.studentIDArray.count-1){
                            let userIDTransport = UserSender(userID: self.studentIDArray[user])
                            guard let uploadData = try? JSONEncoder().encode(userIDTransport) else{
                                return
                            }
                            self.getUserByID(uploadData: uploadData)
                        }
                    }
                }
        }
        task.resume()
    }
    
    func userIDs(data: Data){
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSArray{
                for obj in jsonArray{
                    if let objDict = obj as? NSDictionary{
                        if let username = objDict.value(forKey: "username"){
                            self.studentIDArray.append(username as! Int)
                        }
                    }
                }
            }
        }
    }
    
    func getUserByID(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/get-user-by-id/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
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
                let data = data{
                self.addUsersToArray(data: data)
            }
        }
        task.resume()
    }
    
    func addUsersToArray(data: Data){
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSArray{
                for obj in jsonArray{
                    if let objDict = obj as? NSDictionary{
                        if let username = objDict.value(forKey: "username"){
                            self.studentNameArray.append(username as! String)
                        }
                        if let email = objDict.value(forKey: "email"){
                            self.studentEmailArray.append(email as! String)
                        }
                        OperationQueue.main.addOperation( {
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StudentCell")! as! StudentCellTableViewCell
        cell.nameLabel.text = String(self.studentNameArray[indexPath.row])
        cell.emailLabel.text = self.studentEmailArray[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let lecJSONData = self.code.data(using: .utf8)!
        
        self.getStudents(uploadData: lecJSONData)
        
    }
    
    @IBAction func backModules(_ sender: Any) {
        DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "Module") as! ModuleViewController
            controller.key = self.key
            controller.email = self.email
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "StudentList") as! StudentListViewController
            controller.code = self.code
            controller.key = self.key
            controller.email = self.email
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            self.present(controller, animated: true, completion: nil)
        }
    }
    
}
