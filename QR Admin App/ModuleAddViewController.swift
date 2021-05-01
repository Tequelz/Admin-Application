//
//  ModuleAddViewController.swift
//  QR Admin App
//
//  Created by John Doe on 01/05/2021.
//

import UIKit

struct Module: Codable {
    let mod_id: String
    let mod_teacher:Int
    let mod_name:String
}

class ModuleAddViewController: UIViewController {
    
    var key:String = ""
    
    var userID:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/user/")!
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
                if let jsonArray = jsonObj as? NSDictionary{
                    let userID = jsonArray.value(forKey: "pk")
                    print(userID)
                    self.userID = userID as! Int
                    print(self.userID)
                
            
            }
            }
        }
        task.resume()
        
        

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var mod_id: UITextField!
    
    
    @IBOutlet weak var mod_name: UITextField!
    
    
    @IBAction func moduleAddButton(_ sender: Any) {
        
        let moduleID = mod_id.text
        let moduleName = mod_name.text
        
        let module = Module(mod_id: moduleID!, mod_teacher: self.userID, mod_name: moduleName!)
        
        let jsonData = key.data(using: .utf8)!
        let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: jsonData)

        print(authKey.key)
        
        guard let uploadData = try? JSONEncoder().encode(module) else{
            return
        }
        print(module)
        
        print(uploadData)
        
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/module-create/")!
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
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
                DispatchQueue.main.async {
                        
                            let story = UIStoryboard(name: "Main",bundle:nil)
                            let controller = story.instantiateViewController(identifier: "ManualCodeView") as! ManualCodeViewController
                            controller.key = self.key
                            let navigation = UINavigationController(rootViewController: controller)
                            self.view.addSubview(navigation.view)
                            self.addChild(navigation)
                            navigation.didMove(toParent: self)

                }
            }
        }
        task.resume()
        
        
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
