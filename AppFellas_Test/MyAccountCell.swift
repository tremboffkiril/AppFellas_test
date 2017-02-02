//
//  MyAccountCell.swift
//  AppFellas_Test
//
//  Created by Kiril Trembovetskiy on 2/1/17.
//  Copyright © 2017 Kiril Trembovetskiy. All rights reserved.
//

import UIKit

class MyAccountCell: UITableViewCell {

    @IBOutlet weak var lMyName: UILabel!
    @IBOutlet weak var imMyAvatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
