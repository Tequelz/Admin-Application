import UIKit

class LoginViewController: UIViewController { //This class is created for logging the user into the application
    
    @IBOutlet weak var buttonLog: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField! //here the four text fields located on the log in view are connected to teh class for data transfer
    
    func popUp(error: String) { //a function that creates an alert popup for the user
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func loginAPI(uploadData: Data){ //This function passes data into the API in attempt to get a succesfull login request response, if done correctlty the user is provided with data of the Token for their session this is decoded using the AuthKey structure, once obtained the next view controller Module can be loaded
        let url = URL(string: "https://project-api-sc17gt.herokuapp.com/rest-auth/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                self.popUp(error: "Error in app side (When getting logging in) Error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                self.popUp(error: "Error in server side (When getting logging in)")
                return
            }
            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data{

                    let authKey: AuthKey = try! JSONDecoder().decode(AuthKey.self, from: data)
                    
                    DispatchQueue.main.async {
                        let story = UIStoryboard(name: "Main",bundle:nil)
                        let controller = story.instantiateViewController(identifier: "Module") as! ModuleViewController
                            controller.key = authKey.key
                        controller.email = self.email.text!
                            controller.modalPresentationStyle = .fullScreen
                            controller.modalTransitionStyle = .crossDissolve
                            self.present(controller, animated: true, completion: nil)
                    }
                }
        }
        task.resume()
    }
    
    override func viewDidLoad() {// Function that sets the password entry box to be blacked out
        super.viewDidLoad()
        password.isSecureTextEntry = true
    }
    
    @IBAction func loginButton(_ sender: Any) { // This function runs whenever the login button is pressed packaging all the data up and then sending it via the loginAPI function
        let user = username.text!
        let mail = email.text
        let pass = password.text
                

        let login = Login(username: user, email : mail!, password : pass!)
        guard let uploadData = try? JSONEncoder().encode(login) else {
            return
        }
        self.loginAPI(uploadData: uploadData)
    }
}
    
