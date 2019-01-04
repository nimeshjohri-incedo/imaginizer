//
//  LoginViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 12/28/18.
//  Copyright © 2018 Nimesh Johri. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: userEmail.text!, password: password.text!) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginHome", sender: self)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let userEmailBorder = CALayer()
        let userEmailWidth = CGFloat(1.0)
        let passwordBorder = CALayer()
        let passwordWidth = CGFloat(1.0)
        password.isSecureTextEntry = true
        userEmailBorder.borderColor = UIColor.gray.cgColor
        userEmailBorder.frame = CGRect(x: 0, y: userEmail.frame.size.height - userEmailWidth, width: userEmail.frame.size.width, height: userEmail.frame.size.height)
        userEmailBorder.borderWidth = userEmailWidth
        passwordBorder.borderColor = UIColor.gray.cgColor
        passwordBorder.frame = CGRect(x: 0, y: password.frame.size.height - passwordWidth, width: password.frame.size.width, height: userEmail.frame.size.height)
        passwordBorder.borderWidth = passwordWidth
        userEmail.layer.addSublayer(userEmailBorder)
        userEmail.layer.masksToBounds = true
        password.layer.addSublayer(passwordBorder)
        password.layer.masksToBounds = true
        userEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        signInButton.layer.cornerRadius = 5
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userEmail.resignFirstResponder()
        password.resignFirstResponder()
    }
}
