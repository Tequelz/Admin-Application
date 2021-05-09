import UIKit

class ModuleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate { //This class provides the code to create a view for seeing all modules on the screen, taking in methods from the following protocols and classes
    
    @IBOutlet weak var tableView: UITableView! //Use an outlet to link the tableView to the class

    var key:String = ""
    var email:String = "" //These two values are assigned by the previous view controller
    var moduleIDArray = [Int]() //Two arrays that store the information uploaded to the Module tableView
    var moduleNameArray = [String]()
    
    func failed(error: String) { //Failed function that is run when any error occurs that the user should be aware of
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func tableAdd(data:Data){ //This function is run when the collection of objects is retrieved from the API, with this code being able to split each collection and get the unique values for each module appending them to the array and then reloading the tableView
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
                        OperationQueue.main.addOperation( { //Sets thread to main and then reloads the tableView
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func getModules(){ //This function creates and sends a GET request to the module-create path, in an attempt to obtain all module objects that have the current user's id as the teacher, if correct the data is then passed into the tableAdd function for adding to the table
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {// This is a function needed for the creation of the tableView and generates the number of rows/cells in the view
        return self.moduleIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //This function is used by tableView to generate each cell that ia added to it, with the data being passed in obtained from the arrays using indexPath.row for each cell. The cell is then returned for adding to the table
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModuleCell")! as! ModuleTableViewCell
        cell.moduleIDLabel.text = String(self.moduleIDArray[indexPath.row])
        cell.moduleNameLabel.text = self.moduleNameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // This function handles what happens upon the clicking of a cell in the table, if a cell is clicked a Lecture view controller is instantiated and the id is obtained from the array and passed to the next view
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
    
    override func viewDidLoad() { //This function sets the appropraite tableView methods to operate on the current view, and then runs the function to get all Modules for the current teacher
        super.viewDidLoad()
         
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.getModules()
    }
    
    
    @IBAction func createButton(_ sender: Any) {// A function that handles what happens when the create button is clicked, if so the ModuleAdd view is loaded taking in the values for key and email
        
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

