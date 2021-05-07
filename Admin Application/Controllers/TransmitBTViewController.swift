import UIKit
import CoreLocation
import CoreBluetooth

class TransmitBTViewController: UIViewController,  CBPeripheralManagerDelegate {
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var identityLabel: UILabel!
    
    
    var myUUID = "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A0"
    var code:String = ""
    var email:String = ""
    var key:String = ""
    var lec_id:String = ""
    var lecture_number:String = ""
    var lecture_length:String = ""
    var beaconRegion : CLBeaconRegion!
    var beaconPeripheralData : NSDictionary!
    var peripheralManager : CBPeripheralManager!
    
    
    func failed(error: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title:error, message: nil,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(ac,animated: true)
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == .poweredOn) {
                peripheralManager .startAdvertising(beaconPeripheralData as? [String : Any])
                print("Powered On")
            } else {
                peripheralManager .stopAdvertising()
                print("Not Powered On, or some other error")
            }
    }
    
    func initBeaconRegion() {
        
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
        
        
        beaconRegion = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: self.myUUID)!,
                                           major: mjr!,
                                           minor: min!,
                                           identifier: self.email)
    }
    
    func setLabels() {
        uuidLabel.text = beaconRegion.uuid.uuidString
        identityLabel.text = beaconRegion.identifier
    }

    override func viewDidLoad() {
            super.viewDidLoad()

        self.initBeaconRegion()
        self.setLabels()
            // Do any additional setup after loading the view.
        }
     
    @IBAction func transmitButtonTapped(_ sender: UIButton) {
        beaconPeripheralData = beaconRegion .peripheralData(withMeasuredPower: nil)
            peripheralManager = CBPeripheralManager.init(delegate: self, queue: nil)
        self.failed(error: "Managed to begin transmission with ID: \(self.email) and UUID: \(self.myUUID)")
    }
     
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButton(_ sender: Any) {
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
    
    @IBAction func transmitViewStudentsButton(_ sender: Any) {
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
