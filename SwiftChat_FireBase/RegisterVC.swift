//
//  RegisterVC.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 7/7/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    
    @IBOutlet weak var txtUserName: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    
    var mdata = [AnyHashable: Any]()
    
    //    var userData = [DataSnapshot]()
    var userIDAuth: String = ""
    var emailAuth: String = ""
    var userNameAuth: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // [START auth_listener]
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
        // [END auth_listener]
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // [START remove_auth_listener]
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    @IBAction func onbtnRegister(_ sender: Any) {
        
        let dic: [AnyHashable: Any] = ["user_name": txtUserName.text!, "user_email": txtEmail.text!, "user_password": txtPassword.text!]
        print("\(dic)")
        
        ref = Database.database().reference()
        
        Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { (user, error) in
            
            // [START_EXCLUDE]
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
               let user = Auth.auth().currentUser
                if (user != nil) {
                    self.userIDAuth = (user?.uid)!
                    self.emailAuth = (user?.email!)!
                    self.mdata = [AnyHashable: Any]()
                    //[mdata setValue:_txt_email.text forKey:@"email"];
                    // [mdata setValue:_txt_name.text forKey:@"name"];
                    //[mdata setValue:@"iOS" forKey:@"deviceType"];
                    self.mdata["user_email"] = self.txtEmail.text
                    self.mdata["user_name"] = self.txtUserName.text
                    self.mdata["user_password"] = self.txtPassword.text
                    self.mdata["user_id"] = self.userIDAuth
                    self.ref.child("users").child(self.userIDAuth).updateChildValues(self.mdata)
                    
                    print("\(user!.email!) created")
                    strLoginEmail = user!.email!
//                    strLoginName = self.txtUserName.text!
                    
                    
                    let objAllChatVC = self.storyboard?.instantiateViewController(withIdentifier: "AllChatVC") as! AllChatVC
                    self.navigationController?.pushViewController(objAllChatVC, animated:true)
                    self.txtPassword.text = ""
                    self.txtUserName.text = ""
                    self.txtEmail.text = ""
                }
            }
        }
    }
}
