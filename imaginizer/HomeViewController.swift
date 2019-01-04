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

class HomeViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession!
    var tapRecognizer: UITapGestureRecognizer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    let imagePicker = UIImagePickerController()
    var readyImage: UIImage!
    
    @IBOutlet weak var clickButton: UIButton!
    @IBOutlet weak var selectPhotoButton: UIButton!
    
    @IBAction func selectPhoto(_ sender: Any) {
        print("Photo clicked")
        selectPhotoFromGallery()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupPhotoOutput()
        checkPermission()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
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
        UIApplication.shared.keyWindow!.bringSubviewToFront(clickButton)
        menuButton.addMenuItems([item1, item2])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        print("cancel is clicked")
    }
    func selectPhotoFromGallery() {
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            readyImage = pickedImage
            dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "homeToImage", sender: self.readyImage)
            })
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
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
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
        capturePhoto()
    }
    @IBOutlet weak var cameraPreview: UIView!
    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
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
        }
    }
}



