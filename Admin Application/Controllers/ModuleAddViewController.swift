import UIKit

class ModuleAddViewController: UIViewController {
    
    @IBOutlet weak var mod_id: UITextField!
    @IBOutlet weak var mod_name: UITextField!
    
    var key:String = ""
    var email:String = ""
    var userID:Int = 0
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func getUserID(data: Data){
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
            if let jsonArray = jsonObj as? NSDictionary{
                let userID = jsonArray.value(forKey: "pk")
                self.userID = userID as! Int
            }
        }
    }
    
    func requestUser(){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/user/")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                self.failed(error: "Error in app side (When getting user details)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                self.failed(error: "Error in server side (When getting user details)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{
                self.getUserID(data: data)
            }
        }
        task.resume()
    }
    
    func createModule(uploadData: Data){
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/module-create/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                self.failed(error: "Error in app side (When trying to create module) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.failed(error: "Error in server side (When trying to create module)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{
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
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestUser()
    }

    @IBAction func moduleAddButton(_ sender: Any) {
        
        let moduleID = mod_id.text
        let moduleName = mod_name.text

        let module = Module(mod_id: moduleID!, mod_teacher: self.userID, mod_name: moduleName!)
        guard let uploadData = try? JSONEncoder().encode(module) else{
            return
        }
        self.createModule(uploadData: uploadData)
        
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
