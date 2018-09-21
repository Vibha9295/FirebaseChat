//
//  ViewController.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 6/28/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit
import Firebase

var strLoginEmail = String()
var strLoginID: String = ""
var strLoginName = String()

class ViewController: UIViewController {
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onbtnLogin(_ sender: Any) {
        Auth.auth().signIn(withEmail: txtUserName.text! , password: txtPassword.text!) { (user, error) in
            
            if((error) != nil){
                print(error!)
            }
            else{
                
                if let user = user {
                    // The user's ID, unique to the Firebase project.
                    // Do NOT use this value to authenticate with your backend server,
                    // if you have one. Use getTokenWithCompletion:completion: instead.
                    print(user)
                    let uid = user.uid
                    let email = user.email
                    strLoginEmail = email!
                    strLoginID = uid
                    print(uid)
                    print(email!)
                }
                let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "AllChatVC") as! AllChatVC
                self.navigationController?.pushViewController(secondViewController, animated: true)
            }
        }
    }
    
    @IBAction func onbtnRegister(_ sender: Any) {
        let objRegisterVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(objRegisterVC, animated: true)
    }
}

