import UIKit

class LectureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var key: String = ""
    var lec_id: String = ""
    var email:String = ""
    var lectureNumberArray = [Int]()
    var lectureLengthArray = [Int]()
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func tableAdd(data: Data){
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
    
    func getLectures(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/lecture-view/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                self.failed(error: "Error in app side (When getting lectures) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.failed(error: "Server error in app side (When getting lectures)")
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
    
    @IBAction func createLectureButton(_ sender: Any) {
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let lectureID = LectureID(lecID: lec_id)
        guard let uploadData = try? JSONEncoder().encode(lectureID)else{
            return
        }
        self.getLectures(uploadData: uploadData)
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
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
