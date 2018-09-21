//
//  AllChatVC.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 7/6/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit
import Firebase

class AllChatVC: UIViewController ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tblAllChat: UITableView!
    var ref: DatabaseReference!
    var refHandle:UInt!
    var userList = [DataSnapshot]()
    var childdata : NSDictionary = [:]
    var temarray = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.AllRecordFetch()
        
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        ref.child("users").removeObserver(withHandle: refHandle)
    }
    
    func AllRecordFetch(){
        
        ref = Database.database().reference()
        refHandle = ref!.child("users").observe(.childAdded, with:  { (snapshot) in
            print(snapshot.value!)
            //            let dict = snapshot.value as? [String: AnyObject]
            //            print(dict!)
            self.userList.append(snapshot)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                for i in 0..<self.userList.count {
                    let strStorage = ((self.userList[i] as DataSnapshot).value as! [String:AnyObject])["user_email"] as? String
                    if ( strStorage == strLoginEmail)
                    {
                       strLoginName = (((self.userList[i] as DataSnapshot).value as! [String:AnyObject])["user_name"] as? String)!
                        self.userList.remove(at: i)
                        break
                    }
                }
                print(self.userList)
                
                self.tblAllChat.delegate = self
                self.tblAllChat.dataSource = self
                self.tblAllChat.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "AllChatCell") as? AllChatTblViewCell
        
        cell?.lblUserName.text = ((self.userList[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["user_name"] as? String
        cell?.lblUserEmail.text = ((self.userList[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["user_email"] as? String
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objChatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        self.navigationController?.pushViewController(objChatVC, animated: true)
        
        objChatVC.strChatUser = (((self.userList[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["user_name"] as? String)!
        objChatVC.strSelectedID = (((self.userList[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["user_id"] as? String)!
        objChatVC.strSelectedEmail  = (((self.userList[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["user_email"] as? String)!
               
    }
    
    @IBAction func onbtnLogout(_ sender: Any) {
        //signOut
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            _ = navigationController?.popViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
