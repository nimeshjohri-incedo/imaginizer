//
//  ImageViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 1/2/19.
//  Copyright © 2019 Nimesh Johri. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var capturedImage: UIImageView!
     @IBOutlet weak var cancelRecognitionButton: UIButton!
    @IBAction func cancelRecognition(_ sender: Any) {
    }
    var image: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let imageView = UIImageView(frame: view.frame)
        capturedImage.image = image
        self.capturedImage.layer.masksToBounds = true
        cancelRecognitionButton.layer.cornerRadius = 10
        //view.addSubview(imageView)
    }
}
