import UIKit //https://www.devfright.com/ibeacons-tutorial-swift/
import CoreLocation
import CoreBluetooth //Before class can be created the CoreLocation and CoreBluetooth must be imported first

class TransmitBTViewController: UIViewController,  CBPeripheralManagerDelegate { //This class begins by making it aware it shall use the Core Bluetooth Peripheral Manager protocol, meaning it will be able to handle Bluetooth within the view
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var identityLabel: UILabel! //These two labels are connected to the transmission page and show the user the values if the transmission begins
    
    
    var myUUID = "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A0" //This is the uuid value used for the bluetooth connection, and enables connections
    var code:String = ""
    var email:String = ""
    var key:String = ""
    var lec_id:String = ""
    var lecture_number:String = ""
    var lecture_length:String = "" //These varaibles are used to either take in values from the previous controller or store values that make up a lecture
    var beaconRegion : CLBeaconRegion!
    var beaconPeripheralData : NSDictionary!
    var peripheralManager : CBPeripheralManager! //These three variables are used for creating the connection between the central device and peripherals
    
    
    func popUp(error: String) { //A function used to show error pop ups within the program
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) { //This function lets the delegate know if the peripheral managers state has changed allowing the view to know if the iBeacon is transmitting or not
        if (peripheral.state == .poweredOn) {
                peripheralManager .startAdvertising(beaconPeripheralData as? [String : Any])
                print("Powered On")
            } else {
                peripheralManager .stopAdvertising()
                print("Not Powered On, or some other error")
            }
    }
    
    func initBeaconRegion() { // This function is used to create the beaconRegion taking in the code data and then converting it into a Lecture instance, retrieving the individual values for lecture number and length. The function then checks the length of the lecture_length instance variable if equal to one then two 0s are added to the front, if two then one 0 is added to the front, this is so there is a uniform size for the lecture_length. Once done the major and minor values are made by converting the instance variables into unsigned 16-bit integers with major being the lecture id and minor being the lecture nimber and length. Once done the data made here along with the uuid and email is passed into a CLBeaconRegion to create a beaconRegion that can begin to be transmitted
        
        let jsonData = code.data(using: .utf8)!
        let decCode: Lecture = try! JSONDecoder().decode(Lecture.self, from: jsonData)
        
        self.lecture_number = String(decCode.lec_number)
        self.lecture_length = String(decCode.lec_length)
        
        if self.lecture_length.count == 1 {
            self.lecture_length = "00"+self.lecture_length
        }
        if self.lecture_length.count == 2 {
            self.lecture_length = "0"+self.lecture_length
        }
        
        
        let mjr = UInt16(self.lec_id)
        let min = UInt16(self.lecture_number+String(self.lecture_length))
        
        
        beaconRegion = CLBeaconRegion.init(uuid: UUID.init(uuidString: self.myUUID)!,
                                           major: mjr!,
                                           minor: min!,
                                           identifier: self.email)
    }
    
    func setLabels() { //This is used to show the values of the transmission on the attached labels
        uuidLabel.text = beaconRegion.uuid.uuidString
        identityLabel.text = beaconRegion.identifier
    }

    override func viewDidLoad() { //Function begins by creating the beaconRegion and setting the labels
            super.viewDidLoad()

        self.initBeaconRegion()
        self.setLabels()
            // Do any additional setup after loading the view.
        }
     
    @IBAction func transmitButtonTapped(_ sender: UIButton) { //This button is pressed to start the transmisiion, with the first line retrieving data for use to advertise the beaconRegion as a beacon. After this the CBPeripheralManager is then initalised starting the transmission process within the application, once setup the user will then be showed a popup with the corresponding values
        beaconPeripheralData = beaconRegion .peripheralData(withMeasuredPower: nil)
            peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil)
        self.popUp(error: "Managed to begin transmission with ID: \(self.email) and UUID: \(self.myUUID)")
    }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButton(_ sender: Any) { //This is used to take the user back to TechChoice view, if there is a Bluetooth signal being generated itll stop advertising then load the previous view
        if peripheralManager != nil {
            peripheralManager.stopAdvertising()
        }
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main",bundle:nil)
            let controller = story.instantiateViewController(identifier: "TechChoice") as! TechChoiceViewController
                controller.code = self.code
                controller.key = self.key
                controller.lec_id = self.lec_id
                controller.email = self.email
                controller.modalPresentationStyle = .fullScreen
                controller.modalTransitionStyle = .crossDissolve
                self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func transmitViewStudentsButton(_ sender: Any) { //This button takes the user to the StudentList view, if a connection has begun within the application it'll be stopped first then the next page shall be loaded
        if peripheralManager != nil {
            peripheralManager.stopAdvertising()
        }
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
