//
//  AlbumTrackListCell.swift
//  Charts
//
//  Created by Admin on 8/30/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

class AlbumTrackListCell: UITableViewCell {
    
    @IBOutlet var trackName: UILabel!
    @IBOutlet var trackDuration: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
