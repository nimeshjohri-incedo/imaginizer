//
//  SignUpViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 12/28/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userRePassword: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signupSubmit(_ sender: Any) {
        if userPassword.text != userRePassword.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: userEmail.text!, password: userPassword.text!){ (user, error) in
                if error == nil {
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let uid = user.uid
                        let email = user.email
                        var initialImageDict = [String:Any]()
                        var userInitialImages:Array<AnyObject> = []
                        initialImageDict.updateValue("initialName", forKey: "name")
                        initialImageDict.updateValue("initialURL", forKey: "url")
                        userInitialImages.append((initialImageDict as AnyObject))
                        let ref = Database.database().reference().child(uid)
                        ref.setValue(["uid": uid, "username": self.userName.text!, "email": email ?? "", "creationDate": String(describing: Date()), "imageCount": 0, "imagesLimit": 100, "images":userInitialImages])
                        self.performSegue(withIdentifier: "signupHome", sender: self)
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let usernameBorder = CALayer()
        let usernameWidth = CGFloat(1.0)
        let userEmailBorder = CALayer()
        let userEmailWidth = CGFloat(1.0)
        let passwordBorder = CALayer()
        let passwordWidth = CGFloat(1.0)
        let rePasswordBorder = CALayer()
        let rePasswordWidth = CGFloat(1.0)
        userPassword.isSecureTextEntry = true
        userRePassword.isSecureTextEntry = true
        usernameBorder.borderColor = UIColor.gray.cgColor
        usernameBorder.frame = CGRect(x: 0, y: userEmail.frame.size.height - usernameWidth, width: userEmail.frame.size.width, height: userEmail.frame.size.height)
        usernameBorder.borderWidth = usernameWidth
        userEmailBorder.borderColor = UIColor.gray.cgColor
        userEmailBorder.frame = CGRect(x: 0, y: userEmail.frame.size.height - userEmailWidth, width: userEmail.frame.size.width, height: userEmail.frame.size.height)
        userEmailBorder.borderWidth = userEmailWidth
        passwordBorder.borderColor = UIColor.gray.cgColor
        passwordBorder.frame = CGRect(x: 0, y: userEmail.frame.size.height - passwordWidth, width: userEmail.frame.size.width, height: userEmail.frame.size.height)
        
        passwordBorder.borderWidth = passwordWidth
        rePasswordBorder.borderColor = UIColor.gray.cgColor
        rePasswordBorder.frame = CGRect(x: 0, y: userEmail.frame.size.height - rePasswordWidth, width: userEmail.frame.size.width, height: userEmail.frame.size.height)
        
        rePasswordBorder.borderWidth = rePasswordWidth
        userEmail.layer.addSublayer(userEmailBorder)
        userEmail.layer.masksToBounds = true
        userName.layer.addSublayer(usernameBorder)
        userName.layer.masksToBounds = true
        userPassword.layer.addSublayer(passwordBorder)
        userPassword.layer.masksToBounds = true
        userRePassword.layer.addSublayer(rePasswordBorder)
        userRePassword.layer.masksToBounds = true
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        let image = UIImage(named: "email")
//        imageView.image = image
//        userEmail.leftView = imageView
//        userEmail.leftViewMode = UITextField.ViewMode.always
//        userEmail.leftViewMode = .always
        userEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        userName.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        userPassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        userRePassword.attributedPlaceholder = NSAttributedString(string: "Retype Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        signUpButton.layer.cornerRadius = 5
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userEmail.resignFirstResponder()
        userPassword.resignFirstResponder()
        userRePassword.resignFirstResponder()
        userName.resignFirstResponder()
    }

}
