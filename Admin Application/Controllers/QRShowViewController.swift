import UIKit
import MessageUI //Import the MessageUI package for creating emails

class QRShowViewController: UIViewController, MFMailComposeViewControllerDelegate{ //This controller generates the QR code and then offers the ability to send it via email using the protocol passed in to obtain the correct methods
    
    @IBOutlet weak var imgQRCode: UIImageView! //Connect the class to the UIImageView on the storyboard
    
    var code:String = ""
    var email:String = ""
    var key:String = ""
    var lec_id:String = "" //Create these variables so the data from the previous view can be passed in
    var qrcodeImage: CIImage! //Create a variable to store the image of the QR code
    
    func qrCheck() { //This function checks whether a QR code can be made, if so it proceeds to use a filter to generate the code taking in the converted Data and applying a correction level of Q or 25%. Following this the output image of this is then saved to the qrcodeImage made before, this image is then used to be displayed on the storyboard
        if self.qrcodeImage == nil {
            if self.code == "" {
                return
            }
            let data = self.code.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("Q", forKey: "inputCorrectionLevel")
            self.qrcodeImage = filter?.outputImage
            displayQRCodeImage()
        }else{
            self.imgQRCode.image = nil
            self.qrcodeImage = nil
        }
    }
    
    func displayQRCodeImage() { //This function transforms the QR code if it is too large or small for the UIImageView, if its either the image is then scaled using affine transformations in the x and y. With the new transformed image being displayed on the view
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        imgQRCode.image = UIImage(ciImage: transformedImage)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //This handles what happens to the mail view controller when a message is sent or the view is closed
        controller.dismiss(animated: true, completion: {() -> Void in})
    }
    
    
    override func viewDidLoad() {// First function to run is whether the QR code can be generated within the application
        super.viewDidLoad()
        qrCheck()
    }
    
    @IBAction func emailButton(_ sender: Any) { //This function runs when the email button is clicked, it loads up the mail view controller setting values for all aspects of sending the email and attaches the QR code in a Data format. Once loaded the controller is then shown on the screen
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            print(self.email)
            mail.mailComposeDelegate = self
            mail.setToRecipients([self.email])
            mail.setSubject("Lesson ID: "+self.lec_id)
            mail.setMessageBody("Here is the lesson ID for "+self.lec_id+" use attachment.", isHTML: false)
            let imageData: NSData = imgQRCode.image!.pngData()! as NSData
            mail.addAttachmentData(imageData as Data, mimeType: "qr/png", fileName: "File_"+self.lec_id+"_QR.png")
            self.present(mail,animated:true,completion: {() -> Void in})
        }
    }
    
    
    
    @IBAction func studentViewButton(_ sender: Any) { //If this button is pressed the students list view is loaded taking in the values for the code, key and email. With code allowing for the specific class to be viewed
        DispatchQueue.main.async {
            self.qrcodeImage = nil
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
    
    
    @IBAction func backButton(_ sender: Any) { //This button is used to send the user back to the previous page
        qrcodeImage = nil
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
}

