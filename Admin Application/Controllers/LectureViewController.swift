import UIKit

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
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let lectureID = LectureID(lecID: lec_id)
        
        guard let uploadData = try? JSONEncoder().encode(lectureID)else{
            return
        }

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
        task.resume()
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
