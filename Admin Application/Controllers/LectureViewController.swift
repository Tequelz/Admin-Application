import UIKit

class LectureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { //This class shows all the lectures that are associated to a module for the user, allowing them to click on a lecture and generate the QR or Bluetooth functionality
    
    @IBOutlet weak var tableView: UITableView! //Connect the tableView on the storyboard to the class
    
    var key: String = ""
    var lec_id: String = ""
    var email:String = "" //Used for passing in data from previous controller
    var lectureNumberArray = [Int]() //Create two arrays for storing the lectures details
    var lectureLengthArray = [Int]()
    
    func popUp(error: String) { // Function that creates a pop up for the user if theres an error
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func tableAdd(data: Data){ //This function takes some input data converting it into an JSON object, then to an Array and then each index becomes a dictionary that can be broken up and then appended to the associated array, with the tableView being reloaded at the end
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSArray{
                for obj in jsonArray{
                    if let objDict = obj as? NSDictionary{
                        if let lec_number = objDict.value(forKey: "lec_number"){
                            self.lectureNumberArray.append(lec_number as! Int)
                        }
                        if let lec_length = objDict.value(forKey: "lec_length"){
                            self.lectureLengthArray.append(lec_length as! Int)
                        }
                        OperationQueue.main.addOperation( {
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func getLectures(uploadData: Data){ //This function is used to obtain the data containing all the lectures, here the user sends a request with some upload data and in return they recieve the data that is then added to the table using the tableAdd function
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-view/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                self.popUp(error: "Error in app side (When getting lectures) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.popUp(error: "Server error in app side (When getting lectures)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{
                self.tableAdd(data: data)
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { //Function that returns the number of rows within the tableView
        return self.lectureNumberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //Function that allows for the elements within the cell to be assigned values with the new cell being returned so it is added to the table
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LectureCell")! as! LectureTableViewCell
        cell.lectureNumberLabel.text = String(self.lectureNumberArray[indexPath.row])
        cell.lectureLengthLabel.text = String(self.lectureLengthArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //Function that determines what happens if a row is to be clicked, if clicked the lecture number and length are obtained from the arrays and then used to create a Lecture instance that is encoded and then passed into the next controller as a String. Once made the code, and a few other variables are passed along to the TechChoice view that allows the user to choose a technology for tracking attendance
        DispatchQueue.main.async {
            let lecture = Lecture(lec_id: Int(self.lec_id)!, lec_number: self.lectureNumberArray[indexPath.row], lec_length: self.lectureLengthArray[indexPath.row])
            guard let uploadData = try? JSONEncoder().encode(lecture) else{
                return
            }
            let dataString = String(data: uploadData, encoding: .utf8)
        
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "TechChoice") as! TechChoiceViewController
                controller.code = dataString!
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
     }
    
    @IBAction func createLectureButton(_ sender: Any) { //This button allows the user to open the LectureAdd view where theyre able to add lectures for the tableView
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "LectureAdd") as! LectureAddViewController
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() { //Upon calling the function the current view is set as the place to run all tableView protocols, followed by the creation of a LectureID instance with that being encoded and then uploaded to the getLectures function
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let lectureID = LectureID(lecID: lec_id)
        guard let uploadData = try? JSONEncoder().encode(lectureID)else{
            return
        }
        self.getLectures(uploadData: uploadData)
        
    }
    
    
    @IBAction func backButton(_ sender: Any) { //Button that takes the user back to the module upon being clicked
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
}
