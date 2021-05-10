import UIKit


class StudentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { //This class shall show all the users present according to the current lecture that is passed in, with the ability to go back to the modules and refresh the page
    
    @IBOutlet weak var tableView: UITableView! //Link the tableView to the class for the ability to change contents of the table
    
    var key:String = ""
    var code:String = ""
    var email:String = "" //Create variables to take in data from previous view
    var lecture_id:Int = 0
    var studentNameArray = [String]() //Create three arrays for users data to be stored
    var studentEmailArray = [String]()
    var studentIDArray = [Int]()
    
    func getStudents(uploadData: Data){// Function that is used to obtain all the students from the API taking in some Data refering to the current lecture, if works correctly the primary key of the lecture is obtained with that anwser being converted to Data and then passed into the class attendance function
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
    
    func pkOfLecture(data: Data){ //This function allows for pk field to be obtained from the retrieved JSON object
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
    
    func classAttendance(uploadData: Data){ //This function is used to store all the current students in the class in an array, taking the users information as data and passing that into userIDs function. Follwoing this the size of studentIDArray is checked to see the number of students present. If greater than 0 a UserSender structure instance is made for that user and then the geUserByID function is called to get that user's information
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
    
    func userIDs(data: Data){ //This function enables the JSON object made from the data to have its individual username values obtained, with these values added to an array for use in displaying the current users
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
    
    func getUserByID(uploadData: Data){ //This function gets the users details from an associated id, with the returned data being passed into the addUsersToArray function
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
    
    func addUsersToArray(data: Data){ //This function takes in data and breaks it up into dictionaries of the objects, meaning each objects username and email can be obtained and added to the tableView, with that being reloaded after each object is added to the arrays.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //This function returns the number of cells to make for the table
        return self.studentNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //This function tells view how the cells should be made and where to get the values from with the cell beign returned at the end
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StudentCell")! as! StudentCellTableViewCell
        cell.nameLabel.text = String(self.studentNameArray[indexPath.row])
        cell.emailLabel.text = self.studentEmailArray[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() { //Here the tableView protocols are assigned to this view followed by the conversion of code to Data, with that data passed into the getStudents function
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let lecJSONData = self.code.data(using: .utf8)!
        
        self.getStudents(uploadData: lecJSONData)
        
    }
    
    @IBAction func backModules(_ sender: Any) { //This button returns the users view to the module view so they can generate another lecture
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
    
    @IBAction func refreshButton(_ sender: Any) { //This button enables the reloading of the view so the table can update with any new users
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
