//
//  GradientView.swift
//  Silverback
//
//  Created by Christian Otkjær on 07/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable

class GradientView: UIView
{
    @IBInspectable
    var startPoint : CGPoint = CGPoint(x: 0, y: 0.5) { didSet { updateGradientLayer() } }
    
    @IBInspectable
    var endPoint : CGPoint = CGPoint(x: 1, y: 0.5) { didSet { updateGradientLayer() } }
    
    @IBInspectable
    var startColor : UIColor = UIColor(white: 0.98, alpha: 1) { didSet { updateGradientLayer() } }
    
    @IBInspectable
    var endColor : UIColor = UIColor(white: 0.98, alpha: 0) { didSet { updateGradientLayer() } }
    
    var otherColors = Array<UIColor>() { didSet { updateGradientLayer() } }
    
    var colors : [UIColor] { return [startColor] + otherColors + [endColor] }
    
    private lazy var myGradientLayer : CAGradientLayer = { let layer = CAGradientLayer(); self.layer.addSublayer(layer); return layer }()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        updateGradientLayer()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        updateGradientLayer()
    }
    
    func updateGradientLayer()
    {
        myGradientLayer.opaque = false //colors.all{ $0.opaque }

        myGradientLayer.startPoint = startPoint
        myGradientLayer.endPoint = endPoint
        
        let count = colors.count
        if count > 1
        {
            myGradientLayer.colors = self.colors.map{ $0.CGColor }
            myGradientLayer.locations = nil// (0..<count).map{ CGFloat($0) / CGFloat(count-1) }
        }
    }
    
    override func layoutSubviews()
    {
        myGradientLayer.frame = layer.bounds
    }
}
