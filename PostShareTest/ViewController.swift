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
            if choiceImage{
                
              
                
                //SocialPostManager.sharedManager.shareTextWithImageOnTwitter(captionText: txtV.text, tweetURL: "")
            }else {
                guard (path != nil) else {
                    self.lblStatus?.text = "Hey video path is nil"
                    return
                }
               // SocialPostManager.sharedManager.shareVideoToInstagramV2(videoURL: path!, caption: txtV.text)
            }
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
