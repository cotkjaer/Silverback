//
//  CircleCell.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

class CircleCell: UICollectionViewCell
{
    let backgroundCircleView = CircleView()
    let selectedBackgroundCircleView = CircleView()
    
    private func setup()
    {
        backgroundCircleView.borderWidth = .Absolute(3)
        backgroundView = backgroundCircleView
        
        selectedBackgroundCircleView.borderWidth = .Absolute(0)
        selectedBackgroundView = selectedBackgroundCircleView
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
    
    private func updateBackgrounds()
    {
        backgroundCircleView.updateBorder()
        selectedBackgroundCircleView.updateBorder()
    }
    
    override var bounds: CGRect { didSet { updateBackgrounds() } }
}


