//
//  RecordTableViewCell.swift
//  WaJinCool
//
//  Created by Willy Wu on 2017/9/13.
//  Copyright © 2017年 Willy Wu. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photoImageView.layer.masksToBounds = false
        photoImageView.layer.cornerRadius = photoImageView.frame.height/2
        photoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
