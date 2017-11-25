//
//  customCell.swift
//  VisualAlert
//
//  Created by ryousuke on 2017/11/22.
//  Copyright © 2017年 ryousuke Takahashi. All rights reserved.
//

import UIKit

class customCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
