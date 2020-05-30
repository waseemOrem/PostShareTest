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

    @IBOutlet weak var txtV: UITextView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    
    private var imagePicker:ImagePicker?;
    private let pickerController = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
    }

    @IBAction func addImage(_ sender: UIButton) {
         self.imagePicker?.present(from: self.view)
        lblStatus.text = "You are going to share Image on post"
    }
    
    
    @IBAction func addVideo(_ sender: UIButton) {
         lblStatus.text = "You are going to share Video on post"
    }
    
    @IBAction func btnInsta(_ sender: UIButton) {
        
        
        InstagramManager.sharedManager.postImageToInstaStoryA(sharingImageView: self.imgThumb.image, instagramCaption: txtV.text, view: self.view)
        
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
       // guard  let videoData = NSData(contentsOf: videoURL) else {return}
        
        // *** Get documents directory path *** //
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        
        // *** Append video file name *** //
        // let dataPath = FileManager.default .stringByAppendingPathComponent("/videoFileName.mp4")
        
        // *** Write video file data to path *** //
        //  videoData?.writeToFile(dataPath, atomically: false)
        
        print("we found a video url.. \(paths)")
       // var _videoData = [SocialPostDataDictKEYS:Any]()
        
        let urlOfVideo = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        if urlOfVideo != nil
        {
            let videoPath = urlOfVideo as URL?
            
            
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
                self.imgThumb.image = thumbnail
                InstagramManager.sharedManager.postVideoToStory()
                
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
