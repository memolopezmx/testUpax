//
//  SelfieTableViewCell.swift
//  testUpax-David-Guillermo-Lopez-Vazquez
//
//  Created by David Lopez on 1/25/22.
//

import UIKit

class SelfieTableViewCell: UITableViewCell, SelfieDelegate {

    static let identifier = "SelfieTableViewCell"
    
    @IBOutlet weak var selfieImage: UIImageView!
    @IBOutlet weak var blueLayer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(selfieImage: UIImage) {
        self.selfieImage.image = selfieImage
        self.blueLayer.isHidden = true
    }
}
