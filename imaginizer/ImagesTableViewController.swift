//
//  ImagesTableTableViewController.swift
//  imaginizer
//
//  Created by Nimesh Johri on 2/5/19.
//  Copyright © 2019 Nimesh Johri. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import PreviewTransition
import ExpandingMenu
import Alamofire
import AlamofireImage

class ImagesTableViewController: PTTableViewController{
        
    @IBOutlet var imagesTable: UITableView!
    var userImages:Array<AnyObject> = []
    var updatedImages = [] as Array<AnyObject>
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        let uid = user!.uid
        let ref = Database.database().reference().child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userImages = value?["images"] as! Array<AnyObject>
            self.updatedImages = Array(self.userImages[1..<self.userImages.count])
            DispatchQueue.main.async {
                print(self.updatedImages)
                self.imagesTable.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
        
        // set font
        if let font = UIFont(name: "HelveticaNeue" , size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.font : font
            ]
        }
        let images = ImagesTableViewController(nibName: "ImagesTableViewController", bundle: nil)
        images.title = "Images"
        self.tableView.register(ParallaxCell.self, forCellReuseIdentifier: "customImageCell")
        let menuButtonSize: CGSize = CGSize(width: 54.0, height: 54.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size: menuButtonSize), image: UIImage(named: "addicon")!, rotatedImage: UIImage(named: "addicon")!)
        menuButton.center = CGPoint(x: UIScreen.main.bounds.width - 32.0, y: UIScreen.main.bounds.height - 72.0)
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
        let item3 = ExpandingMenuItem(size: menuButtonSize, title: "Home", image: UIImage(named: "home")!, highlightedImage: UIImage(named: "home")!, backgroundImage: UIImage(named: "home"), backgroundHighlightedImage: UIImage(named: "home")) { () -> Void in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let HomeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
            self.present(HomeViewController, animated:true, completion:nil)
        }
        //UIApplication.shared.keyWindow!.bringSubviewToFront(clickButton)
        menuButton.addMenuItems([item1, item2, item3])
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
    public override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.updatedImages.count
    }
    public override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ParallaxCell else {
            return
        }
        let imageName = self.updatedImages[indexPath.row]
        let imageTitle = imageName["name"] as! String
        let urlString = imageName["url"] as! String
        let url = URL(string: urlString)
//        let data = try? Data(contentsOf: url!)
        Alamofire.request(url!).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                cell.setImage(image, title: "\(imageTitle)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "customImageCell", for: indexPath)
    }
}
