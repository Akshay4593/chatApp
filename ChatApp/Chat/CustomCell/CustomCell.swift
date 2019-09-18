//
//  CustomCell.swift
//  ChatApp
//
//  Created by Akshay Shedge on 17/09/19.
//  Copyright © 2019 Akshay Shedge. All rights reserved.
//

import UIKit
import Firebase

class CustomCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var senderLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: MessageModel) {
        
        guard let message = data.message,
            let sender = data.sender,
            let userEmail = Auth.auth().currentUser?.email else {
                return
        }
        msgLbl.text = message
        senderLbl.text = sender
        
        if sender == userEmail {
            setDataForUser()
        }
        else{
            setDataForSender()
        }
        
    }

    private func setDataForUser(){
        msgLbl.textAlignment = NSTextAlignment.right
        imgView.image = UIImage(named: "ic_angel")
        containerView.backgroundColor = Color.lineBackgroundColor.value.withAlphaComponent(0.5)
    }
    
    private func setDataForSender(){
        msgLbl.textAlignment = NSTextAlignment.left
        imgView.image = UIImage(named: "ic_devil")
        containerView.backgroundColor = UIColor.white
        
    }
    
}
