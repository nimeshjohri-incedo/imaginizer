//
//  HomeViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 12/28/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation
import ExpandingMenu

class HomeViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var tapRecognizer: UITapGestureRecognizer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var readyImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupPhotoOutput()
        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "addicon")!, rotatedImage: UIImage(named: "addicon")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 32.0, y: self.view.bounds.height - 72.0)
        view.addSubview(menuButton)
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Logout", image: UIImage(named: "logout")!, highlightedImage: UIImage(named: "logout")!, backgroundImage: UIImage(named: "logout"), backgroundHighlightedImage: UIImage(named: "logout")) { () -> Void in
            // Do some action
        }
        let item2 = ExpandingMenuItem(size: menuButtonSize, title: "Account", image: UIImage(named: "account")!, highlightedImage: UIImage(named: "account")!, backgroundImage: UIImage(named: "account"), backgroundHighlightedImage: UIImage(named: "account")) { () -> Void in
            // Do some action
        }
        
        menuButton.addMenuItems([item1, item2])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
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
    @IBAction func logout(_ sender: Any) {
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



