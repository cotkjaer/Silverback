//
//  HexCollectionViewCell.swift
//  Silverback
//
//  Created by Christian Otkjær on 22/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

class HexCollectionViewCell: UICollectionViewCell
{
    let backgroundHexView = HexView()
    let selectedBackgroundHexView = HexView()
    
    private func setup()
    {
        backgroundHexView.hexBorderWidth = .Absolute(3)
        backgroundView = backgroundHexView
        
        selectedBackgroundHexView.hexBorderWidth = .Absolute(0)
        selectedBackgroundView = selectedBackgroundHexView
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
//    private func updateBackgrounds()
//    {
//        backgroundHexView.updateBorder()
//        selectedBackgroundHexView.updateBorder()
//    }
//    
//    override var bounds: CGRect { didSet { updateBackgrounds() } }
}


