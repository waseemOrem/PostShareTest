//
//  ViewController.swift
//  PostShareTest
//
//  Created by admin on 30/05/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import MobileCoreServices
//import SDWebImage
import MobileCoreServices
import AssetsLibrary

import TwitterKit

class ViewController: UIViewController {

    @IBOutlet weak var txtV: UITextView?
    @IBOutlet weak var lblStatus: UILabel?
    @IBOutlet weak var imgThumb: UIImageView?
    
    private var imagePicker:ImagePicker?;
    private let pickerController = UIImagePickerController();
    var choiceImage = true
    var path:URL?
    var videoDataIs:NSData?
    var imgDataIs:NSData?
    
    private var store: TWTRSessionStore {
        return TWTRTwitter.sharedInstance().sessionStore
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }

    @IBAction func addImage(_ sender: UIButton) {
        choiceImage = true
         self.imagePicker?.present(from: self.view)
    lblStatus?.textColor = .white
        lblStatus?.text = "You are going to share Image on post"
    }
    
    
    @IBAction func addVideo(_ sender: UIButton) {
        choiceImage = false
         lblStatus?.textColor = .white
         lblStatus?.text = "You are going to share Video on post"
        openVideoPicker(sourceType: .photoLibrary)
    }
    
    @IBAction func btnInsta(_ sender: UIButton) {
        if sender.tag == 0 {
            if choiceImage{
                SocialPostManager.sharedManager.postImageToInstaStoryV2(sharingImageView: self.imgThumb?.image, instagramCaption: "heloo test Caption", view: self.view)
              //  SocialPostManager.sharedManager.postImageToInstaStoryV1(imageInstagram: self.imgThumb.image!, instagramCaption: txtV.text, view: self.view)
            }else {
//                guard (path != nil) else {
//                    self.lblStatus.text = "Hey video path is nil"
//                    return
//                }
               SocialPostManager.sharedManager.shareVideoToInstagramV2(videoData: self.videoDataIs, imageData: self.imgDataIs, caption: "Hello test caption")
            }
        }
        else if sender.tag == 1 {
            
            login(completion: {  [weak self] ifTrue, _ in
                
                if ifTrue{
                    if (self?.choiceImage)!{
                        self!.uploadImageOnTwitter(withText: "twitter test ", image: (self?.imgThumb?.image)!)
                    }else {
                        guard (self?.path != nil) else {
                            self?.lblStatus?.text = "Hey video path is nil"
                            return
                        }
                        self!.uploadVideoOnTwitter(withText: "twitter video test", videoData: self?.videoDataIs as! Data)
                        // SocialPostManager.sharedManager.shareVideoToInstagramV2(videoURL: path!, caption: txtV.text)
                    }
                }
                
            })
           
        }
          }
    
    
    
    //MARK: -Twitter SHARING
    
    func uploadImageOnTwitter(withText text: String, image: UIImage) {
        guard let userId = store.session()?.userID else { return }
        let client = TWTRAPIClient.init(userID: userId)
        client.sendTweet(withText: text, image: image) {
            (tweet, error) in
            
            if (error != nil) {
                // Handle error
                print(error?.localizedDescription)
                
            } else {
                // Handle Success
                print(tweet)
            }
        }
    }
    
    
    func uploadVideoOnTwitter(withText text: String, videoData: Data?) {
        guard let userId = store.session()?.userID else { return }
        let client = TWTRAPIClient.init(userID: userId)
        // Get data from Url
//        guard let videoData = Data(contentsOf: videoUrl) else {
//            // Handle if data is nil
//            return
//        }
        
        guard   videoData != nil else {
            // Handle if data is nil
            return
        }
        client.sendTweet(withText: text, videoData: videoData!) {
            (tweet, error) in
            
            if (error != nil) {
                // Handle error
                print(error?.localizedDescription)
                
            } else {
                // Handle Success
                print(tweet)
            }
        }
    }
    
    func login(completion: @escaping (Bool, String?) -> Void) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if session != nil {
                print("\(String(describing: session?.userName))")
                completion(true, nil)
            } else {
                let message = error?.localizedDescription
                completion(false, message)
                print("error: " + (message ?? ""))
            }
        })
    }
    
    func logout() {
        for case let session as TWTRSession in store.existingUserSessions() {
            store.logOutUserID(session.userID)
        }
    }
}


//MARK:  ImagePickerDelegate

extension ViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        if image != nil {
            self.imgThumb?.image = image
            self.dismiss(animated: true , completion: nil)
            
            //imageData =   self.imgProfile.image?.jpegData(compressionQuality: 0.5)
        }
        
    }
}

extension ViewController:AVPlayerViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func openVideoPicker(sourceType:UIImagePickerController.SourceType){
        
        let videoPickerController = UIImagePickerController()
        // let s = videoPickerController.sourceType
        videoPickerController.sourceType = sourceType
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.delegate = self
        videoPickerController.videoMaximumDuration = 15.0
        
        present(videoPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // *** store the video URL returned by UIImagePickerController *** //
        guard  let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
            return
        }
        
        // *** load video data from URL *** //
        guard  let videoData = NSData(contentsOf: videoURL) else {
            self.lblStatus?.text = "Unable to get video data "
            self.lblStatus?.textColor = .red
            return}
        
        self.videoDataIs = videoData
        
        // *** Get documents directory path *** //
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        
        // *** Append video file name *** //
        // let dataPath = FileManager.default .stringByAppendingPathComponent("/videoFileName.mp4")
        
        // *** Write video file data to path *** //
         // videoData?.writeToFile(dataPath, atomically: false)
        
        print("we found a video url.. \(paths)")
       // var _videoData = [SocialPostDataDictKEYS:Any]()
        
        let urlOfVideo = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        if urlOfVideo != nil
        {
            let videoPath = urlOfVideo as URL?
            path = videoPath
            
            // print(mypath!)
            print("we found a video url.. \(videoPath)")
            
            
            do
            {
                let asset = AVURLAsset(url: videoPath! , options: nil)
                let durationInSeconds = asset.duration.seconds
                print("SEC ARE \(durationInSeconds)")
                //                    let videoReso = CommonMethods.Manager.getVideoResolution(with: urlOfVideo! as URL)
                //
                //                    print("is video is 480 p \(videoReso)")
                
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let  thumbnail = UIImage(cgImage: cgImage)
                
                print("Thumbnail image \(thumbnail)")
                self.imgThumb?.image = thumbnail
                
                guard let imageData =  self.imgThumb?.image?.pngData() else {
                    self.lblStatus?.text = "Unable to get video data "
                    self.lblStatus?.textColor = .red
                    return }
                
                self.imgDataIs = imageData as NSData
               
                
            }
            catch let error
            {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            
            
        }
        
        // }
        self.dismiss(animated: true, completion: nil )
        
       // closeVideoPopUp(videoData: _videoData)
    }
    
    
    
    //    func openVideoEditor(){
    //        if UIVideoEditorController.canEditVideo(atPath: (mypath?.absoluteString)!) {
    //            let editController = UIVideoEditorController()
    //            editController.videoPath = (mypath?.absoluteString)!
    //            editController.delegate = self
    //            present(editController, animated:true)
    //        }
    //    }
}

/*TASKS
 
 
 
 */
