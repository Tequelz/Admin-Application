import UIKit

class ModuleAddViewController: UIViewController { //State that the class will be a UIViewController
    
    @IBOutlet weak var mod_id: UITextField!
    @IBOutlet weak var mod_name: UITextField! //Create outlets for the two text fields so the data can be retrieved
    
    var key:String = ""
    var email:String = ""// Key and email are used to take in data from the previous controller for the corresponding value
    var userID:Int = 0 //This value will be changed upon the retrieval of the current user's id
    
    func popUp(error: String) { //Create popUp function for providing pop ups to the user
        DispatchQueue.main.async { //Set thread to main
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert) //Create alert controller
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default)) //Allow the controller to be clossed with a Dismiss button
            self.present(ac,animated: true) //Show the popup
        }
    }
    
    func getUserID(data: Data){ //Function that converts the data returned by a request into a individual user id value and assigns it to userID
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){ //Convert Data into a JSON object
            if let jsonArray = jsonObj as? NSDictionary{ //Convert object into an NSDictionary
                let userID = jsonArray.value(forKey: "pk") //Obtain the pk value from the Dictionary
                self.userID = userID as! Int //Assign found value to userID instance variable
            }
        }
    }
    
    func requestUser(){ //This function obtains the current user's details, and passes it into the getUserID for conversion
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/user/")! //Set url to the correct user details path
        var request = URLRequest(url: url) //Convert URL value into a URLRequest
        request.httpMethod = "GET" //Make use of GET HTTP
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //Set the contents of the request to JSON
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization") //Pass in the users token for permission to use the API
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in //Get some data using the request
            if let error = error { //If theres an error run
                print ("error: \(error)")
                self.popUp(error: "Error in app side (When getting user details)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else { //If HTTP request provides a status code out of range run this section
                print ("server error")
                self.popUp(error: "Error in server side (When getting user details)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{ // If other statements are false run this section and save data
                self.getUserID(data: data) //Call the getUserID instance function passing in the retrieved data
            }
        }
        task.resume() // Perform the URLSession
    }
    
    func createModule(uploadData: Data){ //This function uploads the users inputted data to the API to create a module
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/module-create/")! //URL is set to the module-create path
        var request = URLRequest(url: url)//Create URLRequest with the url
        request.httpMethod = "POST" //Set request to POST method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token " + self.key, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in //This sends some data using the request made prior
            if let error = error {
                self.popUp(error: "Error in app side (When trying to create module) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.popUp(error: "Error in server side (When trying to create module)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{ //If the data returns correctly run this section
                    DispatchQueue.main.async {
                            
                        let story = UIStoryboard(name: "Main",bundle:nil) //Set the story to the Main.storyboard
                        let controller = story.instantiateViewController(identifier: "Module") as! ModuleViewController // Instantiate the Module view controller on the storyboard
                            controller.key = self.key //Pass in the variables values for the loading of Module
                            controller.email = self.email
                            controller.modalPresentationStyle = .fullScreen //Set how the controller will appear and transition on the screen
                            controller.modalTransitionStyle = .crossDissolve
                            self.present(controller, animated: true, completion: nil) //Set the screen to be the new controller
                    }
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestUser() //Begin by calling the function to obtain the current users details
    }

    @IBAction func moduleAddButton(_ sender: Any) { //This is the button that attempts to create a module from the users entered information
        
        let moduleID = mod_id.text
        let moduleName = mod_name.text //Obtain the values entered into the text fields

        let module = Module(mod_id: moduleID!, mod_teacher: self.userID, mod_name: moduleName!) //Create a Module structure instance passing in the corresponding values from the class
        guard let uploadData = try? JSONEncoder().encode(module) else{ //Attempt to encode the module instance into NSData for transfer via a request
            return
        }
        self.createModule(uploadData: uploadData) //Call function for making a module passing in the data of the encoded module instance
        
    }
    
    @IBAction func backButton(_ sender: Any) { //A button that allows the user to go back to the module screen
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
