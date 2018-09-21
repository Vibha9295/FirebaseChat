//
//  AllChatTblViewCell.swift
//  SwiftChat_FireBase
//
//  Created by jayati on 7/6/17.
//  Copyright © 2017 com.zaptechsolutions. All rights reserved.
//

import UIKit

class AllChatTblViewCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserEmail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
