import UIKit
import Foundation
import Photos


/*
 You can pass the following content to the Instagram app:
 
 Content    File Types    Description
 Image asset
 JPEG, GIF, or PNG
 -
 File asset
 MKV, MP4
 Minimum duration: 3 seconds Maximum duration: 10 minutes Minimum dimentions: 640x640 pixels
 
 */
class InstagramManager: NSObject, UIDocumentInteractionControllerDelegate {
    
    private let kInstagramURL = "instagram://app"
    private let kUTI = "com.instagram.exclusivegram"
    private let kfileNameExtension = "instagram.igo"
    private let kAlertViewTitle = "Error"
    private let kAlertViewMessage = "Please install the Instagram application"
    
    var documentInteractionController = UIDocumentInteractionController()
    
    // singleton manager
    class var sharedManager: InstagramManager {
        struct Singleton {
            static let instance = InstagramManager()
        }
        return Singleton.instance
    }
    /*
     let url = URL(string: "instagram://library?LocalIdentifier=" + videoLocalIdentifier)
     
     */
    func postVideoToStory(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        if let lastAsset = fetchResult.firstObject {
            let localIdentifier = lastAsset.localIdentifier
            let u = "instagram://library?LocalIdentifier=" + localIdentifier
            let url = NSURL(string: u)!
            print(url)
            if UIApplication.shared.canOpenURL(url as URL) {
                UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
            } else {
                
                let urlStr = "https://itunes.apple.com/in/app/instagram/id389801252?mt=8"
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                    
                } else {
                    UIApplication.shared.openURL(URL(string: urlStr)!)
                }
            }
            
        }
    }
    
    func postImageToInstaStoryA(sharingImageView:UIImage?,instagramCaption:String, view: UIView){
        if let storiesUrl = URL(string: "instagram-stories://share") {
            if UIApplication.shared.canOpenURL(storiesUrl) {
                guard let image = sharingImageView else { return }
                guard let imageData = image.pngData() else { return }
                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.InstagramCaption":instagramCaption,
                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                    "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3"
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]
                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
            } else {
                
                UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
                // print("User doesn't have instagram on their device.")
            }
        }
    }
    
    func postImageToInstagramWithCaption(imageInstagram: UIImage, instagramCaption: String, view: UIView) {
        // called to post image with caption to the instagram application
        
        let instagramURL = NSURL(string: kInstagramURL)
        if UIApplication.shared.canOpenURL(instagramURL! as URL) {
            let jpgPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(kfileNameExtension)
            guard let imgD = imageInstagram.jpegData(compressionQuality: 1.0) else {
                return
            }
            
            do {
                try imgD.write(to: URL(string: jpgPath)!, options: .init(rawValue: 0)) //!.writeToFile(jpgPath, atomically: true)
                
            } catch {
                print("Instagram sharing error")
            }
            
            let rect =  CGRect.init(x: 0, y: 0, width: 612, height: 612) //CGRectMake(0,0,612,612)
            let fileURL = NSURL.fileURL(withPath: jpgPath)
            documentInteractionController.url = fileURL
            documentInteractionController.delegate = self
            documentInteractionController.uti = kUTI
            
            // adding caption for the image
            documentInteractionController.annotation = ["InstagramCaption": instagramCaption]
            
            documentInteractionController.presentOpenInMenu(from: rect, in: view, animated: true)
        } else {
            
            // alert displayed when the instagram application is not available in the device
            UIAlertView(title: kAlertViewTitle, message: kAlertViewMessage, delegate:nil, cancelButtonTitle:"Ok").show()
        }
    }
    
}
