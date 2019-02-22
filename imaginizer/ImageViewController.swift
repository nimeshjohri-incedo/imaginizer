//
//  ImageViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 1/2/19.
//  Copyright © 2019 Nimesh Johri. All rights reserved.
//

import UIKit
import Firebase
import SpriteKit
import Alamofire
import FirebaseAuth
import ParticlesLoadingView

class ImageViewController: UIViewController {
    
    @IBOutlet weak var capturedImage: UIImageView!
     @IBOutlet weak var cancelRecognitionButton: UIButton!
    @IBAction func cancelRecognition(_ sender: Any) {
    }
    @IBOutlet weak var imageStatus: UILabel!
    var image: UIImage!
    var apiType: String?
    let apiURL = "https://westcentralus.api.cognitive.microsoft.com/vision/v2.0/analyze?visualFeatures=Categories%2CTags%2CDescription%2CFaces&details=Celebrities%2CLandmarks&language=en"
    let params = "visualFeatures=Categories%2CTags%2CDescription%2CFaces&details=Celebrities%2CLandmarks&language=en"
    let headers: HTTPHeaders = [
        "Ocp-Apim-Subscription-Key": "25f9c4f719e2483b8c7ce6c487530628",
        "Content-Type": "application/json"
    ]
    var objectNameCount = 1
    //lazy var vision = Vision.vision()
    lazy var loadingView: ParticlesLoadingView = {
        let view = ParticlesLoadingView(frame: CGRect(x: 55, y: 210, width: 266, height: 351))
        view.particleEffect = .bokeh
        view.duration = 2.5
        view.particlesSize = 15.0
        view.clockwiseRotation = true
        view.layer.cornerRadius = 15.0
        return view
    }()
    var resultsText = ""
    override func viewWillAppear(_ animated: Bool) {
        imageStatus.text = "Sending your image to moon"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        capturedImage.image = image
        print("\(apiType ?? "")")
        var imageDict = [String:Any]()
        self.capturedImage.layer.masksToBounds = true
        cancelRecognitionButton.layer.cornerRadius = 10
        guard let profileImage = self.capturedImage.image else{return}
        if let uploadData = profileImage.jpegData(compressionQuality: 0.6){
            objectNameCount = objectNameCount + 1
            let closestOption = "sample12" + String(objectNameCount)
           // var proceed = true
            let StorageRef = Storage.storage().reference()
            let user = Auth.auth().currentUser
            view.addSubview(loadingView)
            loadingView.startAnimating()
            self.imageStatus.text = "Churning up our models"
            
//            let options = VisionLabelDetectorOptions(
//                confidenceThreshold: Constants.labelConfidenceThreshold
//            )
//            let labelDetector = vision.labelDetector(options: options)
//            let imageMetadata = VisionImageMetadata()
//            let visionImage = VisionImage(image: capturedImage.image!)
//            visionImage.metadata = imageMetadata
//            labelDetector.detect(in: visionImage) { features, error in
//                guard error == nil, let features = features, !features.isEmpty else {
//                    proceed = false
//                    let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
//                    self.resultsText = "On-Device label detection failed with error: \(errorString)"
//                    self.showResults()
//                    return
//                }
//                self.resultsText = features.map { feature -> String in
//                    proceed = true
//                    return "Label: \(String(describing: feature.label)), " +
//                        "Confidence: \(feature.confidence), " +
//                    "EntityID: \(String(describing: feature.entityID))"
//                    }.joined(separator: "\n")
//                self.showResults()
//                if(proceed == true) {
                    //closestOption = features[0].label
                    let StorageRefChild = StorageRef.child(user!.uid).child("\(closestOption).jpg")
                    StorageRefChild.putData(uploadData, metadata: nil) { (metadata, err) in
                        if let err = err {
                            print("unable to upload Image into storage due to \(err)")
                        }
                        StorageRefChild.downloadURL(completion: { (url, err) in
                            if let err = err {
                                print("Unable to retrieve URL due to error: \(err.localizedDescription)")
                            }
                            self.imageStatus.text = "Saving the image in your search history"
                            let profilePicUrl = url?.absoluteString
                            let apiRequest: [String: AnyObject] = [
                                "url": profilePicUrl as AnyObject
                            ]
                            Alamofire.request(self.apiURL, method: .post, parameters: apiRequest, encoding:JSONEncoding.default, headers: self.headers).responseJSON { response in
                                guard response.result.isSuccess else {
                                    print(response.result.error!)
                                    return
                                }
                                let apiResponse = response.result.value as? NSDictionary
                                let descriptionText = apiResponse?["description"] as! NSDictionary
                                let captions: NSArray?   = descriptionText.object(forKey: "captions") as? NSArray
                                var finalText: String?
                                for (item) in captions!
                                {
                                    finalText = (item as AnyObject).object(forKey: "text") as? String
                                }
                                let resultsAlertController = UIAlertController(
                                    title: "Detection Results",
                                    message: nil,
                                    preferredStyle: .actionSheet
                                )
                                resultsAlertController.addAction(
                                    UIAlertAction(title: "OK", style: .destructive) { _ in
                                        resultsAlertController.dismiss(animated: true, completion: nil)
                                    }
                                )
                                resultsAlertController.message = finalText
                                resultsAlertController.popoverPresentationController?.sourceView = self.view
                                self.present(resultsAlertController, animated: true, completion: nil)
                                if let user = user {
                                    let uid = user.uid
                                    var userImageCount = Int()
                                    var userSearchedImages:Array<AnyObject> = []
                                    let ref = Database.database().reference().child(uid)
                                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                                        let value = snapshot.value as? NSDictionary
                                        userImageCount = value?["imageCount"] as? Int ?? 0
                                        userSearchedImages = value?["images"] as! Array<AnyObject>
                                        userImageCount = userImageCount + 1
                                        imageDict.updateValue(finalText ?? "No Title", forKey: "name")
                                        imageDict.updateValue(profilePicUrl!, forKey: "url")
                                        userSearchedImages.append((imageDict as AnyObject))
                                        ref.updateChildValues(["imageCount": userImageCount, "images":userSearchedImages])
                                        self.performSegue(withIdentifier: "resultsPage", sender: self.image)
                                    }) { (error) in
                                        print(error.localizedDescription)
                                    }
                                }
                                print("Profile Image successfully uploaded into storage with url: \(profilePicUrl ?? "" )")
                            }
                        })
                    }
//                } else {
//                    return
//                }
//            }
        }
    }
    private func showResults() {
        let resultsAlertController = UIAlertController(
            title: "Detection Results",
            message: nil,
            preferredStyle: .actionSheet
        )
        resultsAlertController.addAction(
            UIAlertAction(title: "OK", style: .destructive) { _ in
                resultsAlertController.dismiss(animated: true, completion: nil)
            }
        )
        resultsAlertController.message = resultsText
        resultsAlertController.popoverPresentationController?.sourceView = self.view
        present(resultsAlertController, animated: true, completion: nil)
    }
}
//private enum Constants {
//    static let images = ["grace_hopper.jpg", "barcode_128.png", "qr_code.jpg", "beach.jpg",
//                         "image_has_text.jpg", "liberty.jpg"]
//    static let modelExtension = "tflite"
//    static let localModelName = "mobilenet"
//    static let quantizedModelFilename = "mobilenet_quant_v1_224"
//
//    static let detectionNoResultsMessage = "No results returned."
//    static let failedToDetectObjectsMessage = "Failed to detect objects in image."
//
//    static let labelConfidenceThreshold: Float = 0.60
//    static let smallDotRadius: CGFloat = 5.0
//    static let largeDotRadius: CGFloat = 10.0
//    static let lineColor = UIColor.yellow.cgColor
//    static let fillColor = UIColor.clear.cgColor
//}
