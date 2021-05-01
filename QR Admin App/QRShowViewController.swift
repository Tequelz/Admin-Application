//
//  ViewController.swift
//  testApp
//
//  Created by John Doe on 11/02/2021.
//

import UIKit
import MessageUI

var qrcodeImage: CIImage!


class QRShowViewController: UIViewController, MFMailComposeViewControllerDelegate{


    
    var code:String = ""
    
    var email:String = ""
    
    var key:String = ""
    
    
    
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func performButtonAction(_ sender: Any) {
        
//        if qrcodeImage == nil {
//            if self.code == "" {
//                return
//            }
//            print(code)
//            let data = code.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
//
//            let filter = CIFilter(name: "CIQRCodeGenerator")
//
//            filter?.setValue(data, forKey: "inputMessage")
//
//            filter?.setValue("Q", forKey: "inputCorrectionLevel")
//
//            qrcodeImage = filter?.outputImage
//
//            btnAction.setTitle("Clear", for: .normal)
//
//            displayQRCodeImage()
//        }else{
//            imgQRCode.image = nil
//            qrcodeImage = nil
//            btnAction.setTitle("Generate", for: .normal)
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if qrcodeImage == nil {
            if self.code == "" {
                return
            }
            print(code)
            let data = code.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter?.outputImage
            
            
            displayQRCodeImage()
        }else{
            imgQRCode.image = nil
            qrcodeImage = nil
           // btnAction.setTitle("Generate", for: .normal)
        }
    }
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
    
    
    @IBAction func emailButton(_ sender: Any) {
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.email])
            mail.setSubject("Lesson Code: "+self.code)
            mail.setMessageBody("Here is the lesson code for "+self.code+" use attachment.", isHTML: false)
            let imageData: NSData = imgQRCode.image!.pngData()! as NSData
            mail.addAttachmentData(imageData as Data, mimeType: "qr/png", fileName: "File_"+self.code+"_QR.png")
            self.present(mail,animated:true,completion: {() -> Void in})
            print("Hey")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: {() -> Void in})
    }
    
    
    @IBAction func studentViewButton(_ sender: Any) {
        DispatchQueue.main.async {
        
        let story = UIStoryboard(name: "Main",bundle:nil)
        let controller = story.instantiateViewController(identifier: "StudentListViewController") as! StudentListViewController
            controller.code = self.code
            controller.key = self.key
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            
            self.present(controller, animated: true, completion: nil)
        }
    }
}

