//
//  CustomCollectionViewCell.swift
//  Soundboard
//
//  Created by lefevluc on 04/04/2022.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerViewColored: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerViewColored.layer.cornerRadius = 10
    }

    //Changer la couleur de la cellule
    func configure(_ index : Int, _ color : UIColor) {
        containerViewColored.backgroundColor =  color
    }
    
    //Modifier le texte de la cellule
    func text(_ index : Int, _ text : String) {
        titleLabel.text = text
    }
}
