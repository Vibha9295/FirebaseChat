//
//  ChatTableViewCell.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 7/11/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgReceiver: UIImageView!
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var lblSenderMsg: UILabel!
    @IBOutlet weak var lblRecieverMsg: UILabel!
    
    @IBOutlet weak var imgViewPlaySender: UIImageView!
    @IBOutlet weak var imgPlayReceiver: UIImageView!
    
    @IBOutlet weak var lblReceiverImgTime: UILabel!
    @IBOutlet weak var lblSenderImgTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
