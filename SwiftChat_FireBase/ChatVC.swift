 //
 //  ChatVC.swift
 //  SwiftChat_FireBase
 //
 //  Created by jayati on 6/30/17.
 //  Copyright © 2017 com.zaptechsolutions. All rights reserved.
 //
 
 import UIKit
 import Firebase
 import IQKeyboardManagerSwift
 import SDWebImage
 import MobileCoreServices
 import AVFoundation
 import Photos
 import MapKit
 import CoreLocation
 
 class ChatVC: UIViewController ,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIDocumentInteractionControllerDelegate,CLLocationManagerDelegate{
    
    //,AVAudioRecorderDelegate,AVAudioPlayerDelegate 
    @IBOutlet weak var tblViewChat: UITableView!
    @IBOutlet weak var btnattachment: UIButton!
    @IBOutlet weak var btnSendMsg: UIButton!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var txtVieMsg: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnSendLocationOut: UIButton!
    

    var ref: DatabaseReference?
    var _refHandle = DatabaseHandle()
    var resultMsg: String = ""
    var strSelectLibrary: String = ""
    var dicSender = [AnyHashable: Any]()
    var dicReceiver = [AnyHashable: Any]()
    var msgViewFrame = CGRect.zero
    var tmpFrame = CGRect.zero
    
    var storageRef: StorageReference?
    var messages = [DataSnapshot]()
    var remoteConfig: RemoteConfig?
    
    var strSelectedID: String = ""
    var strSelectedEmail: String = ""
    var strChatUser: String = ""
    //Attachment
    //img
    var objImagePicker: UIImagePickerController?
    var profileImage: UIImage?
    var url: URL?
    var strProfileImageURL: String = ""

    //video audio
    var imgGetUrl: URL?
    var videoGetUrl: URL?
    var videoUrl: URL?
    var strVideoPath: String = ""
    var audioUrl: URL?
    var avPlayer: AVPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isAudioRecord: Bool = false
    
    //map
    var locationManager: CLLocationManager?
    var geocoder: CLGeocoder?
    var placemark: CLPlacemark?
    var myCurrentLocation: CLLocation?
    var strLat: String = ""
    var strLong: String = ""
    var strMapLat: String = ""
    var strMapLong: String = ""
    var deviceToken: String = ""
    var strCity: String = ""
    var latitude_UserLocation: Double = 0.0
    var longitude_UserLocation: Double = 0.0
    var isSelectMap: Bool = false
    var mapUrl: URL?
    var dataMap: Data?
    var dateFormatter: DateFormatter?
    var dateFormat: DateFormatter?
    var formatter: DateFormatter?
    var dateFormatterDate: DateFormatter?
    var myTime: Date?
    var now: Date?
    var TimeString: String = ""
    var formatString: String = ""
    var date: String = ""
    var formatStringDate: String = ""
    var timestamp: Double = 0.0
    var timeInMilisInt64: Int64 = 0
    var dateStr: String = ""
      var strTime: String = ""
    
    // MARK : Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(strChatUser)"
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = true
        
        txtVieMsg.delegate = self
        txtVieMsg.scrollRangeToVisible(NSRange(location: 0, length: 4))
        tblViewChat.reloadData()
        configureDatabase()
        configureStorage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //   msgViewFrame = viewMessage.frame
        //   tmpFrame = txtVieMsg.frame
    }
    
    // MARK: - Firebase Methods
    deinit {
        ref?.child("chat_data").removeObserver(withHandle: _refHandle)
        ref?.child("pictures").removeObserver(withHandle: _refHandle)
    }
    func configureRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig?.configSettings = remoteConfigSettings!
    }
    func configureStorage() {
        storageRef = Storage.storage().reference()
    }
    func configureDatabase() {
        ref = Database.database().reference()
        ref?.child("chat_data").child(strLoginID).child(strSelectedID).observe(.childAdded, with: {(_ snapshot: DataSnapshot) -> Void in
            
            self.messages.append(snapshot)
            self.tblViewChat.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tblViewChat.scrollToRow(at: indexPath, at: .top, animated: true)
        })
    }
    
    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (strSelectLibrary == "videos") {
            let mediaType: String = info[UIImagePickerControllerMediaType] as? String ?? ""
            if CFStringCompare((mediaType as? CFString), kUTTypeMovie, CFStringCompareFlags(rawValue: 0)) == CFComparisonResult.compareEqualTo {
                videoUrl = (info[UIImagePickerControllerMediaURL] as? URL)
                strVideoPath = (videoUrl?.path)!
                sendVideo()
                UISaveVideoAtPathToSavedPhotosAlbum(strVideoPath, nil, nil, nil)
            }
            dismiss(animated: true) { _ in }
        }
        else{
            picker.delegate = self
            profileImage = info[UIImagePickerControllerEditedImage] as! UIImage?
            sendImage()
            dismiss(animated: false) { _ in }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { _ in }
    }
    
    // MARK: - UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tblViewChat.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth: CGFloat = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame: CGRect = textView.frame
        newFrame.size = CGSize(width: CGFloat(fmaxf(Float(newSize.width), Float(fixedWidth))), height: newSize.height)
        if txtVieMsg.frame.size.height < 100 {
            tblViewChat.frame = CGRect(x: 0, y: tblViewChat.frame.origin.y, width: tblViewChat.frame.size.width, height: tblViewChat.frame.size.height - (newFrame.size.height - textView.frame.size.height))
            
            txtVieMsg.frame = CGRect(x: btnattachment.frame.size.width, y: txtVieMsg.frame.origin.y - (newFrame.size.height - textView.frame.size.height), width: txtVieMsg.frame.size.width, height: txtVieMsg.frame.size.height + (newFrame.size.height - textView.frame.size.height))
        }
        else if tmpFrame.size.height > newFrame.size.height {
            tblViewChat.frame = CGRect(x: 0, y: tblViewChat.frame.origin.y, width: tblViewChat.frame.size.width, height: tblViewChat.frame.size.height - (newFrame.size.height - textView.frame.size.height))
            
            txtVieMsg.frame = CGRect(x: btnattachment.frame.size.width, y: txtVieMsg.frame.origin.y - (newFrame.size.height - textView.frame.size.height), width: txtVieMsg.frame.size.width, height: txtVieMsg.frame.size.height + (newFrame.size.height - textView.frame.size.height))
        }
        tmpFrame = txtVieMsg.frame
        
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tblViewChat.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellId: String = ""
        
        //choose a cell idetifier
        if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["type"] as? String)! == "send") {
            
            if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "text") {
                cellId = "SenderMsg"
            }
            else {
                cellId = "senderImg"
            }
        }
        else {
            if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "text") {
                cellId = "ReceiverMsg"
            }
            else {
                cellId = "recieverImg"
            }
        }
        
        var cell  = tableView.dequeueReusableCell(withIdentifier: cellId) as? ChatTableViewCell
        if cell == nil {
            cell = ChatTableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        //For sender message
        if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["type"] as? String)! == "send") {
            if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "text") {
                cell!.lblSenderMsg.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!
            }
                
            else if((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "image"){
                
                DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                    self.url = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
                    cell?.imgSender?.sd_setImage(with: self.url, placeholderImage: nil)
                    
                    cell?.lblSenderImgTime.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                })
            }
            else if((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "video"){
                DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                    self.videoGetUrl = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
                    let asset = AVURLAsset(url: self.videoGetUrl!, options: nil)
                    let generateImg = AVAssetImageGenerator(asset: (asset as? AVAsset)! )
                    generateImg.appliesPreferredTrackTransform = true
                    let error: Error? = nil
                    let duration: CMTime = asset.duration
                    
                    
                    let durationInSeconds:CGFloat = CGFloat(duration.timescale)
                    //    var time: CMTime = CMTimeMakeWithSeconds(durationInSeconds * 0.5, Int(duration.value))
                    let time : CMTime = CMTimeMakeWithSeconds(0.5, Int32(duration.value))
                    
                    do{
                        let refImg: CGImage = try generateImg.copyCGImage(at: time, actualTime: nil)
                        print("error==\(error), Refimage==\(refImg)")
                        let frameImage = UIImage(cgImage: refImg)
                        cell?.imgSender.sd_setImage(with: self.videoGetUrl, placeholderImage: frameImage)
                           cell?.imgViewPlaySender.isHidden = false
                        cell?.lblSenderImgTime.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                        
                    }catch{
                        
                    }
                })
            }
            
            else if((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "location"){
                
                
                let urlString: String = "http://maps.google.com/maps/api/staticmap?center=\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["latitude"] as? String)!),\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["longitude"] as? String)!)&markers=size:mid|color:red|label:E|\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["latitude"] as? String)!),\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["longitude"] as? String)!)&size=300x300&sensor=false"
                
                DispatchQueue.main.async(execute: {() -> Void in
                    self.mapUrl = URL(string: urlString.addingPercentEscapes(using: String.Encoding.utf8)!)
                    
                    cell?.imgSender?.sd_setImage(with: self.url, placeholderImage: nil)
                    cell?.lblSenderImgTime?.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                })
            }
            
        }
        //for receiver
        else{
            if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "text") {
                cell!.lblRecieverMsg.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!
                //   cell.lblReceivermsgTime.text = "\(messages[indexPath.row].value.value(forKey: "time"))"
            }
            else if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "image") {
                DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                    self.url = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
                    cell?.imgReceiver.sd_setImage(with: self.url, placeholderImage: nil)
                    cell?.lblReceiverImgTime.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                    
                    
                })
            }
            else if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "video") {
                DispatchQueue.global(qos: .default).async(execute: {() -> Void in
                    self.videoGetUrl = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
                    let asset = AVURLAsset(url: self.videoGetUrl!, options: nil)
                    let generator = AVAssetImageGenerator(asset: (asset as? AVAsset)!)
                    let error: Error? = nil
                    let requestedTime: CMTime = CMTimeMake(1, 60)
                    // To create thumbnail image
                    
                    //        let refImg: CGImage = try generateImg.copyCGImage(at: time, actualTime: nil)
                    
                    do{
                        let imgRef: CGImage = try generator.copyCGImage(at: requestedTime, actualTime: nil)
                        print("error==\(error), Refimage==\(imgRef)")
                        let frameImage = UIImage(cgImage: imgRef)
                        //   cell?.imgSender.sd_setImage(with: self.url, placeholderImage: frameImage)
                        
                        cell?.imgReceiver.sd_setImage(with: self.videoGetUrl, placeholderImage: frameImage)
                              cell?.imgPlayReceiver.isHidden = false
                        cell?.lblReceiverImgTime.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                        
                    }catch{
                        
                    }
                })
            }
            else if((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "map"){
                
                
                let urlString: String = "http://maps.google.com/maps/api/staticmap?center=\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["latitude"] as? String)!),\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["longitude"] as? String)!)&markers=size:mid|color:red|label:E|\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["latitude"] as? String)!),\((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["longitude"] as? String)!)&size=300x300&sensor=false"
                
                DispatchQueue.main.async(execute: {() -> Void in
                    self.mapUrl = URL(string: urlString.addingPercentEscapes(using: String.Encoding.utf8)!)
                    
                    cell?.imgReceiver?.sd_setImage(with: self.url, placeholderImage: nil)
                    cell?.lblReceiverImgTime?.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["time"] as? String)!
                })
            }
            
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str: String? = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!
        let size: CGSize = getSizeOf(str!)
        return size.height + 30
    }
    
    //MARK: Custom Method
    func getSizeOf(_ str: String) -> CGSize {
        let myFont = UIFont(name: "Helvetica", size: CGFloat(14))
        let constraintRect = CGSize(width: CGFloat(view.frame.size.width / 1.7), height: CGFloat(9999))
        let myStringSize = str.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: myFont!], context: nil).size
        
        return myStringSize
    }
    
    func sendMessage() {
        ref = Database.database().reference()
//        dicSender = [AnyHashable: Any]()
//        dicReceiver = [AnyHashable: Any]()
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "HH:mm:ss"
        //20160217 13:14:22
        myTime = Date()
        TimeString = (dateFormatter?.string(from: myTime!))!
        timestamp = Date().timeIntervalSince1970
        timeInMilisInt64 = Int64(timestamp * 1000)
        strTime = "\(timeInMilisInt64)"
        dateFormat = DateFormatter()
        dateFormat?.dateFormat = "ddMMyyHHmmss"
        now = Date()
        formatter = DateFormatter()
        formatString = "ddMMyyyy"
        formatter?.dateFormat = formatString
        date = "\((formatter?.string(from: now!))!)"
        dateFormatterDate = DateFormatter()
        formatStringDate = "dd/MM/yyyy"
        dateFormatterDate?.dateFormat = formatStringDate
        dateStr = "\((dateFormatterDate?.string(from: now!))!)"
        
        //sender dic
        self.dicSender["date"] = dateStr
        dicSender["device_type"] = "iOS"
        dicSender["duplicate"] = false
        dicSender["sender_email"] = strLoginEmail
        dicSender["receiver_email"] = strSelectedEmail
        dicSender["latitude"] = ""
        dicSender["longitude"] = ""
        dicSender["location"] = ""
        dicSender["msg"] = resultMsg
        dicSender["msg_type"] = "text"
        dicSender["receiver_id"] = strSelectedID
        dicSender["sender_id"] = strLoginID
        
        dicSender["receiver_name"] = strChatUser
        dicSender["sender_name"] = strLoginName
        
        dicSender["type"] = "send"
        //[dateFormatter setDateFormat:@"dd/mm/yyyy"];  //20160217 13:14:22
        //NSString *dateString = [dateFormatter stringFromDate: myDate];
        //[dicSender setValue:dateString forKey:@"date"];
        dicSender["time"] = TimeString
        dicSender["token"] = ""
        
        //        let strSenderID: String = "\(strLoginID)\("_")\(strSelectedID)"
        //        print(strSenderID)
        let strSendingTime: String = "\(date)\(strTime)"
        ref?.child("chat_data").child(strLoginID).child(strSelectedID).child("\(strSendingTime)").updateChildValues(dicSender)
        //receiver

        dicReceiver["date"] = dateStr
        dicReceiver["device_type"] = "iOS"
        dicReceiver["duplicate"] = false
        dicReceiver["sender_email"] = strLoginEmail
        dicReceiver["receiver_email"] = strSelectedEmail
        dicReceiver["latitude"] = ""
        dicReceiver["longitude"] = ""
        dicReceiver["location"] = ""
        dicReceiver["msg"] = resultMsg
        dicReceiver["msg_type"] = "text"
        dicReceiver["receiver_id"] = strSelectedID
        dicReceiver["sender_id"] = strLoginID
        dicReceiver["receiver_name"] = self.strChatUser
        dicReceiver["sender_name"] = strLoginName
        
        dicReceiver["time"] = TimeString
        dicReceiver["token"] = ""
        dicReceiver["type"] = "receive"
        
        ref?.child("chat_data").child(strSelectedID).child(strLoginID).child("\(strSendingTime)").updateChildValues(dicReceiver)
        txtVieMsg.text = ""
    }
    func sendImage(){
        ref = Database.database().reference()
        //    if (profileImage != nil)
        //    {
        let imageID: String = UUID().uuidString
        // NSString *imageName = [NSString stringWithFormat:@"photos/%@.jpg",imageID];
        let imageName: String = "photos/"
        let profilePicRef: StorageReference? = storageRef?.child(imageName).child(strLoginID).child(strSelectedID).child("\(imageID).jpg")
        //FIRStorageReference *profilePicRef = [storageRef child:imageName];
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageData: Data? = UIImageJPEGRepresentation(profileImage!, 0.8)
        
        
        //      profilePicRef?.putData(imageData!, metadata: metadata) { (metadata, error) in
        
        profilePicRef?.putData(imageData!, metadata: metadata, completion: {(metadata, error) -> Void in
            if error == nil {
                
                self.strProfileImageURL = (metadata!.downloadURL()?.absoluteString)!
                var dictimg = [AnyHashable: Any]()
                dictimg["Name"] = self.strProfileImageURL
                self.dateFormatter = DateFormatter()
                self.dateFormatter?.dateFormat = "HH:mm:ss"
                //20160217 13:14:22
                self.myTime = Date()
                self.TimeString = (self.dateFormatter?.string(from: self.myTime!))!
                self.timestamp = Date().timeIntervalSince1970
                self.timeInMilisInt64 = Int64(self.timestamp * 1000)
                self.strTime = "\(self.timeInMilisInt64)"
                self.dateFormat = DateFormatter()
                self.dateFormat?.dateFormat = "ddMMyyHHmmss"
                self.now = Date()
                self.formatter = DateFormatter()
                self.formatString = "ddMMyyyy"
                self.formatter?.dateFormat = self.formatString
                self.date = "\((self.formatter?.string(from: self.now!))!)"

                self.dateFormatterDate = DateFormatter()
                self.formatStringDate = "dd/MM/yyyy"
                self.dateFormatterDate?.dateFormat = self.formatStringDate
                self.dateStr = "\((self.dateFormatterDate?.string(from: self.now!))!)"
                
                //sender dic
                self.dicSender["date"] = self.dateStr
                self.dicSender["device_type"] = "iOS"
                self.dicSender["duplicate"] = false
                self.dicSender["sender_email"] = strLoginEmail
                self.dicSender["receiver_email"] = self.strSelectedEmail
                self.dicSender["latitude"] = ""
                self.dicSender["longitude"] = ""
                self.dicSender["location"] = ""
//                self.dicSender["contact_name"] = ""
//                self.dicSender["contact_number"] = ""
                self.dicSender["msg"] = self.strProfileImageURL
                self.dicSender["msg_type"] = "image"                //self.dicSender["content_type"] ="image"
                self.dicSender["receiver_id"] = self.strSelectedID
                self.dicSender["sender_id"] = strLoginID
                self.dicSender["receiver_name"] = self.strChatUser
                self.dicSender["sender_name"] = strLoginName
                self.dicSender["type"] = "send"
                
                self.self.dicSender["time"] = self.TimeString
                self.self.dicSender["token"] = ""
                let strSendingTime: String = "\(self.date)\(self.strTime)"
                self.ref?.child("chat_data").child(strLoginID).child(self.strSelectedID).child("\(strSendingTime)").updateChildValues(self.dicSender)
                
                //receiver

                self.dicReceiver["date"] = self.dateStr
                self.dicReceiver["device_type"] = "iOS"
                self.dicReceiver["duplicate"] = false
                self.dicReceiver["sender_email"] = strLoginEmail
                self.dicReceiver["receiver_email"] = self.strSelectedEmail
                self.dicReceiver["latitude"] = self.strLat
                self.dicReceiver["longitude"] = self.strLong
                self.dicReceiver["location"] = ""
//                self.dicReceiver["contact_name"] = ""
//                self.dicReceiver["contact_number"] = ""
                self.dicReceiver["msg"] = self.strProfileImageURL
                self.dicReceiver["msg_type"] = "image"
                // self.dicReceiver["content_type"] = "image"
                self.dicReceiver["receiver_id"] = self.strSelectedID
                self.dicReceiver["sender_id"] = strLoginID
                self.dicReceiver["receiver_name"] = self.strChatUser
                self.dicReceiver["sender_name"] = strLoginName
                self.dicReceiver["time"] = self.TimeString
                self.dicReceiver["token"] = ""
                self.dicReceiver["type"] = "receive"
                //NSString *strReceiverID = [NSString stringWithFormat:@"%@%@%@",_strSelectedID,@"_",_strLoginID];
                self.ref?.child("chat_data").child(self.strSelectedID).child(strLoginID).child("\(strSendingTime)").updateChildValues(self.dicReceiver)
                
                self.txtVieMsg.text = ""
            }
            else if((error) != nil){
                print("fail")
            }
            
        })
        
    }
    
    func sendVideo() {
        ref = Database.database().reference()
        let videoId: String = UUID().uuidString
        // NSString *videoName = [NSString stringWithFormat:@"video/%@.mp4",videoId];
        let videoName: String = "videos/"
        let videoRef: StorageReference? = storageRef?.child(videoName).child(strLoginID).child(strSelectedID).child("\(videoId).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        //profilePicRef?.putData(imageData!, metadata: metadata, completion: {(metadata, error) -> Void in
        
        videoRef?.putFile(from: videoUrl!, metadata: metadata, completion: {(metadata,error) -> Void in
            if error == nil {
                self.strVideoPath = (metadata!.downloadURL()?.absoluteString)!
                var dictimg = [AnyHashable: Any]()
                dictimg["Name"] = self.strVideoPath
                
                self.dicSender = [AnyHashable: Any]()
                self.dicReceiver = [AnyHashable: Any]()
                let dateFormatter = DateFormatter()
                let myTime = Date()
                dateFormatter.dateFormat = "HH:mm:ss"
                //20160217 13:14:22
                let TimeString: String = dateFormatter.string(from: myTime)
                let timestamp: Double = Date().timeIntervalSince1970
                let timeInMilisInt64: Int64 = Int64(timestamp * 1000)
                //  NSDate *myDate = [[NSDate alloc] init];
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "ddMMyyHHmmss"
                
                let now = Date()
                let formatter = DateFormatter()
                let formatString: String = "ddMMyyyy"
                formatter.dateFormat = formatString
                let date: String = "\(formatter.string(from: now))"
                let strTime: String = "\(timeInMilisInt64)"
                let dateFormatterDate = DateFormatter()
                let formatStringDate: String = "dd/MM/yyyy"
                
                dateFormatterDate.dateFormat = formatStringDate
                self.dateStr = "\((dateFormatterDate.string(from: now)))"
                
                //sender dic
                self.dicSender["date"] = self.dateStr
                self.dicSender["device_type"] = "iOS"
                self.dicSender["duplicate"] = "false"
                self.dicSender["file_path"] = ""
                self.dicSender["local_file_path"] = ""
                self.dicSender["latitude"] = ""
                self.dicSender["longitude"] = ""
                self.dicSender["location"] = ""
//                self.dicSender["contact_name"] = ""
//                self.dicSender["contact_number"] = ""
                self.dicSender["msg"] = self.strVideoPath
                self.dicSender["msg_type"] = "video"
                //[dicSender setValue:@"video" forKey:@"content_type"];
                self.dicSender["receiver_id"] = self.strSelectedID
                self.dicSender["sender_id"] = strLoginID
                self.dicSender["receiver_name"] = self.strChatUser
                self.dicSender["sender_name"] = strLoginName
                self.dicSender["type"] = "send"
                
                self.dicSender["time"] = TimeString
                self.dicSender["token"] = ""
                let strSendingTime: String = "\(date)\(strTime)"
                self.ref!.child("chat_data").child(strLoginID).child(self.strSelectedID).child("\(strSendingTime)").updateChildValues(self.dicSender)
                //receiver
                self.dicReceiver["date"] = self.dateStr
                self.dicReceiver["device_type"] = "iOS"
                self.dicReceiver["duplicate"] = "false"
                self.dicReceiver["file_path"] = ""
                self.dicReceiver["local_file_path"] = ""
                self.dicReceiver["latitude"] = ""
                self.dicReceiver["longitude"] = ""
                self.dicReceiver["location"] = ""
//                self.dicReceiver["contact_name"] = ""
//                self.dicReceiver["contact_number"] = ""
                self.dicReceiver["msg"] = self.strVideoPath
                self.dicReceiver["msg_type"] = "video"
                //[dicReceiver setValue:@"video" forKey:@"content_type"];
                self.dicReceiver["receiver_id"] = self.strSelectedID
                self.dicReceiver["sender_id"] = strLoginID
                self.dicReceiver["receiver_name"] = self.strChatUser
                self.dicReceiver["sender_name"] = strLoginName
                
                self.dicReceiver["time"] = TimeString
                self.dicReceiver["token"] = ""
                self.dicReceiver["type"] = "receive"
                
                self.ref?.child("chat_data").child(self.strSelectedID).child(strLoginID).child("\(strSendingTime)").updateChildValues(self.dicReceiver)
                self.txtVieMsg.text = ""
            }
            else if error != nil {
                // NSLog(@"Fail");
            }
            
        })
        
    }
    
    func sendLocation() {
        ref = Database.database().reference()
       // deviceToken = UserDefaults.standard.object(forKey: "MyAppDeviceToken") as! String
//        dicSender = [AnyHashable: Any]()
//        dicReceiver = [AnyHashable: Any]()
        dateFormatter = DateFormatter()
        dateFormatter?.dateFormat = "HH:mm:ss"
        //20160217 13:14:22
        myTime = Date()
        TimeString = (dateFormatter?.string(from: myTime!))!
        timestamp = Date().timeIntervalSince1970
        timeInMilisInt64 = Int64(timestamp * 1000)
        strTime = "\(timeInMilisInt64)"
        dateFormat = DateFormatter()
        dateFormat?.dateFormat = "ddMMyyHHmmss"
        now = Date()
        formatter = DateFormatter()
        formatString = "ddMMyyyy"
        formatter?.dateFormat = formatString
        date = "\((formatter?.string(from: now!))!)"
        dateFormatterDate = DateFormatter()
        formatStringDate = "dd/MM/yyyy"
        dateFormatterDate?.dateFormat = formatStringDate
        dateStr = "\((dateFormatterDate?.string(from: now!))!)"

        //sender dic
        dicSender["date"] = dateStr
        dicSender["device_type"] = "iOS"
        dicSender["duplicate"] = "false"
        dicSender["file_path"] = ""
        dicSender["local_file_path"] = ""
        dicSender["latitude"] = strLat
        dicSender["longitude"] = strLong
        dicSender["location"] = strCity
//        dicSender["contact_name"] = ""
//        dicSender["contact_number"] = ""
        dicSender["msg"] = ""
        dicSender["msg_type"] = "location"
        //[dicSender setValue:@"location" forKey:@"content_type"];
        dicSender["receiver_id"] = strSelectedID
        dicSender["sender_id"] = strLoginID
        dicSender["receiver_name"] = strChatUser
        dicSender["sender_name"] = strLoginName
        dicSender["type"] = "send"
        dicSender["time"] = TimeString
        dicSender["token"] = ""
        //NSString *strSenderID = [NSString stringWithFormat:@"%@%@%@",_strLoginID,@"_",_strSelectedID];
        let strSendingTime: String = "\(date)\(strTime)"
        ref?.child("chat_data").child(strLoginID).child(strSelectedID).child("\(strSendingTime)").updateChildValues(dicSender)
        
        //receiver
        dicReceiver["date"] = dateStr
        dicReceiver["device_type"] = "iOS"
        dicReceiver["duplicate"] = "false"
        dicReceiver["file_path"] = ""
        dicReceiver["local_file_path"] = ""
        dicReceiver["latitude"] = strLat
        dicReceiver["longitude"] = strLong
        dicReceiver["location"] = strCity
//        dicReceiver["contact_name"] = ""
//        dicReceiver["contact_number"] = ""
        dicReceiver["msg"] = ""
        dicReceiver["msg_type"] = "location"
        dicReceiver["receiver_id"] = strSelectedID
        dicReceiver["sender_id"] = strLoginID
        dicReceiver["receiver_name"] = strChatUser
        dicReceiver["sender_name"] = strLoginName
        dicReceiver["time"] = TimeString
        dicReceiver["token"] = ""
        dicReceiver["type"] = "receive"
        ref?.child("chat_data").child(strSelectedID).child(strLoginID).child("\(strSendingTime)").updateChildValues(dicReceiver)
    }

    
    // MARK: - Action sheet actions - Take Photo and Choose Photo Method
    func takePhoto() {
        objImagePicker = UIImagePickerController()
        objImagePicker?.delegate = self
        objImagePicker?.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            objImagePicker?.sourceType = .camera
            present(objImagePicker!, animated: true) { _ in }
        }
        else {
            //   view.makeToast("Camera is not available")
        }
    }
    
    func choosePhoto() {
        strSelectLibrary = "images"
        objImagePicker = UIImagePickerController()
        objImagePicker?.delegate = self
        objImagePicker?.allowsEditing = true
        objImagePicker?.sourceType = .photoLibrary
        present(objImagePicker!, animated: true) { _ in }
    }
    func shareVideo() {
        strSelectLibrary = "videos"
        objImagePicker = UIImagePickerController()
        objImagePicker?.delegate = self
        objImagePicker?.allowsEditing = true
        objImagePicker?.sourceType = .photoLibrary
        objImagePicker?.mediaTypes = [(kUTTypeMovie as? String)!]
        present(objImagePicker!, animated: true) { _ in }
    }
    func shareLocation() {
        mapView.isHidden = false
        btnSendLocationOut.isHidden = false
        geocoder = CLGeocoder()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        mapView.showsUserLocation = true
        loadUserLocation()
        
    }
    func shareContact() {
        
    }
    
    //MARK: - Location methods
    func loadUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self        
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if (locationManager?.responds(to: #selector(locationManager?.requestWhenInUseAuthorization)))! {
            locationManager?.requestWhenInUseAuthorization()
        }
        locationManager?.startUpdatingLocation()
        
    }
    func loadMapView() {
        if isSelectMap {
            let Doublelat = CDouble(strMapLat)
            let Doublelong = CDouble(strMapLong)
            var objCoor2D = CLLocationCoordinate2D()
            objCoor2D.latitude = Doublelat!
            objCoor2D.longitude = Doublelong!
            var objCoorSpan = MKCoordinateSpan()
            objCoorSpan.latitudeDelta = 0.2
            objCoorSpan.longitudeDelta = 0.2
            
            let objMapRegion:MKCoordinateRegion = MKCoordinateRegionMake(objCoor2D, objCoorSpan)

            mapView.region = objMapRegion
            let annotation = MKPointAnnotation()
            annotation.coordinate = objCoor2D
         //   self.mapView.showsUserLocation = true
            // pView?.addAnnotation(annotation)
            isSelectMap = false
        }
        else {
            var objCoor2D = CLLocationCoordinate2D()
            objCoor2D.latitude = latitude_UserLocation
            objCoor2D.longitude = longitude_UserLocation
            var objCoorSpan = MKCoordinateSpan()
            objCoorSpan.latitudeDelta = 0.2
            objCoorSpan.longitudeDelta = 0.2
            
            let objMapRegion:MKCoordinateRegion = MKCoordinateRegionMake(objCoor2D, objCoorSpan)

            mapView.region = objMapRegion
            let annotation = MKPointAnnotation()
            annotation.coordinate = objCoor2D
            annotation.title = "Title"
            //You can set the subtitle too
            mapView?.addAnnotation(annotation)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        locationManager?.stopUpdatingLocation()
        let errorAlert = UIAlertView(title: "Error", message: "There was an error retrieving your location", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
        errorAlert.show()
    }
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations[0] as? CLLocation 
        latitude_UserLocation = (newLocation?.coordinate.latitude)!
        longitude_UserLocation = (newLocation?.coordinate.longitude)!
        strLat = "\(newLocation?.coordinate.latitude)"
        strLong = "\(newLocation?.coordinate.longitude)"
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(newLocation!, completionHandler: {(placemarks, error) in
            
            let placemarkPlace = placemarks?[0]
            //(((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)!
            self.strCity = placemarkPlace!.addressDictionary!["City"] as! String
        })
        
        loadMapView()
    }
    
    
    //MARK: Custom button
    @IBAction func onbtnSendLocation(_ sender: Any) {
        let cgpoint = CGPoint(x: view.center.x, y: view.center.y)
        let grabRect = CGRect(x: cgpoint.x - 100, y: cgpoint.y - 100, width: 200, height: 200)
        //for retina displays
        if (UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale))) {
            UIGraphicsBeginImageContextWithOptions(grabRect.size, false, UIScreen.main.scale)
        }
        else {
            UIGraphicsBeginImageContext(grabRect.size)
        }

        let ctx: CGContext? = UIGraphicsGetCurrentContext()
        ctx?.translateBy(x: -grabRect.origin.x, y: -grabRect.origin.y)
        view.layer.render(in: ctx!)
        let viewImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(viewImage!, nil, nil, nil)
        dataMap = UIImagePNGRepresentation(viewImage!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(1 * Double(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {() -> Void in
            self.mapView.isHidden = true
            //tblViewChat.hidden = false;
            self.btnSendLocationOut.isHidden = true
            self.sendLocation()
            self.tblViewChat.reloadData()
        })
        locationManager?.stopUpdatingLocation()
    }
    
    @IBAction func onbtnAttachment(_ sender: Any) {
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let alertTakePhoto = UIAlertAction(title: "Take Photo", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.performSelector(inBackground: #selector(self.takePhoto), with: nil)
        })
        let alertGallery = UIAlertAction(title: "Choose from Photo Library", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.performSelector(inBackground: #selector(self.choosePhoto), with: nil)
        })
        let alertVideo = UIAlertAction(title: "Share Video", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.performSelector(inBackground: #selector(self.shareVideo), with: nil)
        })
        let alertLocation = UIAlertAction(title: "Share Location", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.performSelector(inBackground: #selector(self.shareLocation), with: nil)
        })
        let alertContact = UIAlertAction(title: "Share Contact", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.performSelector(inBackground: #selector(self.shareContact), with: nil)
        })
        let alertCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            actionSheetController.dismiss(animated: true) { _ in }
        })
        actionSheetController.addAction(alertTakePhoto)
        actionSheetController.addAction(alertGallery)
        actionSheetController.addAction(alertVideo)
        actionSheetController.addAction(alertContact)
        actionSheetController.addAction(alertLocation)
        actionSheetController.addAction(alertCancel)
        actionSheetController.view.tintColor = UIColor.black
        
        actionSheetController.popoverPresentationController?.sourceView = self.view
        actionSheetController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        actionSheetController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        present(actionSheetController, animated: true, completion: nil)
     //   present(actionSheetController, animated: true) { _ in }
        
    }
    @IBAction func onbtnSendMsg(_ sender: Any) {
        let charSet = CharacterSet.whitespaces
        let trimmedString: String = txtVieMsg.text.trimmingCharacters(in: charSet)
        if (trimmedString == "") {
            
        }
        else {
            resultMsg = txtVieMsg.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            tblViewChat.reloadData()
        }
        sendMessage()
    }
 }
 
 
 //                    DispatchQueue.global(qos: .default).async(execute: {() -> Void in
 //                        self.url = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
 //                        ///
 //                        let asset = AVURLAsset(url: self.url!, options: nil)
 //                        let generateImg = AVAssetImageGenerator(asset: (asset as? AVAsset)! )
 //                        generateImg.appliesPreferredTrackTransform = true
 //                        let error: Error? = nil
 //                        let duration: CMTime = asset.duration
 //                        let durationInSeconds:CGFloat = CGFloat(duration.timescale)
 //                    //    var time: CMTime = CMTimeMakeWithSeconds(durationInSeconds * 0.5, Int(duration.value))
 //                     let time : CMTime = CMTimeMakeWithSeconds(0.5, Int32(duration.value))
 //
 //                        do{
 //                            let refImg: CGImage = try generateImg.copyCGImage(at: time, actualTime: nil)
 //                            print("error==\(error), Refimage==\(refImg)")
 //                             let frameImage = UIImage(cgImage: refImg)
 //                            cell?.imgSender.sd_setImage(with: self.url, placeholderImage: frameImage)
 //                        }catch{
 //
 //                        }
 //                    })
 
 
 //receiver messages
 //        else {
 //            if ((((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg_type"] as? String)! == "attachment") {
 //
 //                DispatchQueue.global(qos: .default).async(execute: {() -> Void in
 //                    self.url = URL(string: (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!)
 //                    cell?.imgReceiver.sd_setImage(with: self.url, placeholderImage: nil)
 //                })
 //
 //
 //            }
 //            else {
 //                cell!.lblRecieverMsg.text = (((self.messages[indexPath.row] as DataSnapshot).value as! [String:AnyObject])["msg"] as? String)!
 //            }
 //            return cell!
 //        }
 //    }
       
