//
//  HomeViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 12/28/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import AVFoundation
import ExpandingMenu
import BetterSegmentedControl

class HomeViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession!
    var tapRecognizer: UITapGestureRecognizer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    let imagePicker = UIImagePickerController()
    var readyImage: UIImage!
    var serviceType = "analyze" as String
    var photoSourceType = UIImagePickerController.SourceType.camera
    
    @IBOutlet weak var clickButton: UIButton!
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var control1: BetterSegmentedControl!
    @IBAction func segmentedControl1ValueChanged(_ sender: BetterSegmentedControl) {
        print("The selected index is \(sender.index)")
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        print("Photo clicked")
        photoSourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.sourceType = photoSourceType
        print(photoSourceType)
        selectPhotoFromGallery()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupPhotoOutput()
        checkPermission()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        let navigationSegmentedControl = BetterSegmentedControl(
            frame: CGRect(x: 35.0, y: 40.0, width: 300.0, height: 40.0),
            segments: LabelSegment.segments(withTitles: ["Image","Text","Barcode"],
                                            normalFont: UIFont(name: "HelveticaNeue-Light", size: 15.0)!,
                                            normalTextColor: .lightGray,
                                            selectedFont: UIFont(name: "HelveticaNeue-Medium", size: 15.0)!,
                                            selectedTextColor: .white),
            options:[.backgroundColor(.darkGray),
                     .indicatorViewBackgroundColor(UIColor(red:0.24, green:0.77, blue:0.8, alpha:1.00)),
                     .cornerRadius(6.0),
                     .bouncesOnChange(false)])
        navigationSegmentedControl.addTarget(self, action: #selector(HomeViewController.navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        navigationItem.titleView = navigationSegmentedControl
        view.addSubview(navigationSegmentedControl)
        clickButton.frame = CGRect(x: 150, y: 670, width: clickButton.frame.size.width, height: clickButton.frame.size.height)
        selectPhotoButton.frame = CGRect(x: 20, y: 720, width: selectPhotoButton.frame.size.width, height: selectPhotoButton.frame.size.height)
        clickButton.layer.borderWidth = 6
        clickButton.layer.borderColor = UIColor.white.cgColor
        let menuButtonSize: CGSize = CGSize(width: 54.0, height: 54.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "addicon")!, rotatedImage: UIImage(named: "addicon")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        view.addSubview(menuButton)
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Logout", image: UIImage(named: "logout")!, highlightedImage: UIImage(named: "logout")!, backgroundImage: UIImage(named: "logout"), backgroundHighlightedImage: UIImage(named: "logout")) { () -> Void in
            do {
                try Auth.auth().signOut()
            }
            catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initial = storyboard.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = initial
        }
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "Account", image: UIImage(named: "account")!, highlightedImage: UIImage(named: "account")!, backgroundImage: UIImage(named: "account"), backgroundHighlightedImage: UIImage(named: "account")) { () -> Void in
            // Do some action
        }
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "Search History", image: UIImage(named: "account")!, highlightedImage: UIImage(named: "search-history")!, backgroundImage: UIImage(named: "search-history"), backgroundHighlightedImage: UIImage(named: "search-history")) { () -> Void in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let ImagesTableTableViewController = storyBoard.instantiateViewController(withIdentifier: "searchHistory") as! ImagesTableViewController
            self.present(ImagesTableTableViewController, animated:true, completion:nil)
        }
        UIApplication.shared.keyWindow!.bringSubviewToFront(clickButton)
        menuButton.addMenuItems([item1, item2, item3])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            serviceType = "analyze"
            view.backgroundColor = .white
        } else if(sender.index == 1) {
            view.backgroundColor = .darkGray
            serviceType = "ocr"
        } else {
            print("Barcode")
            view.backgroundColor = .darkGray
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("cancel is clicked")
        dismiss(animated: true, completion: nil)
    }
    func selectPhotoFromGallery() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            readyImage = pickedImage
        }
    }
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    private func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            fatalError("Error configuring capture device: \(error)");
        }
        captureSession = AVCaptureSession()
        captureSession.addInput(input)
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        cameraPreview.layer.addSublayer(videoPreviewLayer)
    }
    private func setupPhotoOutput() {
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(capturePhotoOutput!)
    }
    @IBAction func takePhoto(_ sender: Any) {
        photoSourceType = UIImagePickerController.SourceType.camera
        imagePicker.sourceType = photoSourceType
        capturePhoto()
    }
    @IBOutlet weak var cameraPreview: UIView!
    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .off
        capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            fatalError("Failed to capture photo: \(String(describing: error))")
        }
        guard let imageData = photo.fileDataRepresentation() else {
            fatalError("Failed to convert pixel buffer")
        }
        guard let image = UIImage(data: imageData) else {
            fatalError("Failed to convert image data to UIImage")
        }
        readyImage = image
        performSegue(withIdentifier: "homeToImage", sender: readyImage)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let imageViewController = segue.destination as? ImageViewController {
            imageViewController.image = readyImage
            imageViewController.apiType = serviceType
        }
    }
}



