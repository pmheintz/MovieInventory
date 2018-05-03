//
//  MovieTableViewCell.swift
//  MovieInventory
//
//  Created by Paul Heintz on 5/2/18.
//  Copyright © 2018 Paul Heintz. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    //MARK: Properties
    
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var barcodeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
