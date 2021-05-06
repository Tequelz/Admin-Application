import UIKit

class ModuleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var key:String = ""
    var email:String = ""
    var moduleIDArray = [Int]()
    var moduleNameArray = [String]()
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func tableAdd(data:Data){
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSArray{
                for obj in jsonArray{
                    if let objDict = obj as? NSDictionary{
                        if let mod_id = objDict.value(forKey: "mod_id"){
                            self.moduleIDArray.append(mod_id as! Int)
                        }
                        if let mod_name = objDict.value(forKey: "mod_name"){
                            self.moduleNameArray.append(mod_name as! String)
                        }
                        OperationQueue.main.addOperation( {
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func getModules(){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/module-create/?format=json")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.failed(error: "Error in app side (When creating module) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                self.failed(error: "Error in server side (When creating module)")
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
        return self.moduleIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModuleCell")! as! ModuleTableViewCell
        cell.moduleIDLabel.text = String(self.moduleIDArray[indexPath.row])
        cell.moduleNameLabel.text = self.moduleNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "Lecture") as! LectureViewController
            controller.lec_id = String(self.moduleIDArray[indexPath.row])
            controller.key = self.key
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
        
        self.getModules()
    }
    
    
    @IBAction func createButton(_ sender: Any) {
        
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "ModuleAdd") as! ModuleAddViewController
                controller.key = self.key
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
}

