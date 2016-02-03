//
//  CircleCell.swift
//  Silverback
//
//  Created by Christian Otkjær on 16/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class CircleCell: UICollectionViewCell
{
    public let backgroundCircleView = CircleView()
    public let selectedBackgroundCircleView = CircleView()
    
    private func setup()
    {
        backgroundCircleView.borderWidth = .Absolute(3)
        backgroundView = backgroundCircleView
        
        selectedBackgroundCircleView.borderWidth = .Absolute(0)
        selectedBackgroundView = selectedBackgroundCircleView
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func updateBackgrounds()
    {
        backgroundCircleView.updateBorder()
        selectedBackgroundCircleView.updateBorder()
    }
    
    public override var bounds: CGRect { didSet { updateBackgrounds() } }
}


