import UIKit
import CoreBluetooth

class QRBTViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        guard central.state == .poweredOn else { return }
        let service = CBUUID(string: "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A0")
        centralManager.scanForPeripherals(withServices: [service],options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.connect(peripheral, options: nil)
        
        self.peripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        
        peripheral.delegate = self
        
        let service = CBUUID(string: "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A0")
        peripheral.discoverServices([service])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            print("Cannot discover service: \(error.localizedDescription)")
            return
        }
        
        let characteristic = CBUUID(string: "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A1")
        
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([characteristic], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error {
            print("Unable discover characteristics: \(error.localizedDescription)")
        }
        
        let characteristicUUID = CBUUID(string: "E06F95E4-FCFC-42C6-B4F8-F6BAE87EA1A1")
        
        service.characteristics?.forEach { characteristic in
            guard characteristic.uuid == characteristicUUID else {return}
            
            
            peripheral.setNotifyValue(true, for: characteristic)
            
            self.characteristic = characteristic
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("Failed \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {return}
        
        let message = String(decoding: data, as: UTF8.self)
    }
    
    func sendDataToPer(){
        let data = "Hello world".data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic,type: .withResponse)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let centralManager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }
}
