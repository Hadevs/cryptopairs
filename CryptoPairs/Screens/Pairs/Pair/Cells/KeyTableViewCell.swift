//
//  KeyTableViewCell.swift
//  CryptoPairs
//
//  Created by hadevs on 11.04.2023.
//

import UIKit

class KeyTableViewCell: UITableViewCell, NibLoadable {

    @IBOutlet private weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(by key: Key) {
        label.text = key.publicKey
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
