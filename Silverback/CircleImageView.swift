//
//  CircleImageView.swift
//  Silverback
//
//  Created by Christian Otkjær on 09/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

@IBDesignable
public class CircleImageView: UIImageView
{
    private var imageView = UIImageView(frame: CGRectZero)
    
    @IBInspectable
    override public var image : UIImage?
        {
        set { imageView.image = newValue }
        get { return imageView.image }
    }
    
    override public var bounds: CGRect { didSet { roundCorners() } }
    
    @IBInspectable
    public var topInset : CGFloat
        {
        set { imageInsets.top = newValue }
        get { return imageInsets.top }
    }
    
    @IBInspectable
    public var bottomInset : CGFloat
        {
        set { imageInsets.bottom = newValue }
        get { return imageInsets.bottom }
    }
    
    @IBInspectable
    public var leftInset : CGFloat
        {
        set { imageInsets.left = newValue }
        get { return imageInsets.left }
    }
    
    @IBInspectable
    public var rightInset : CGFloat
        {
        set { imageInsets.right = newValue }
        get { return imageInsets.right }
    }
    
    public var imageInsets : UIEdgeInsets = UIEdgeInsetsZero { didSet { setNeedsLayout() } }
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        var insetSize = size
        
        insetSize.width = max(0, insetSize.width - (imageInsets.left + imageInsets.right))
        insetSize.height = max(0, insetSize.height - (imageInsets.top + imageInsets.bottom))
        
        var sizeThatFits = imageView.sizeThatFits(insetSize)
        
        sizeThatFits.width += imageInsets.left + imageInsets.right
        sizeThatFits.height += imageInsets.top + imageInsets.bottom
        
        return sizeThatFits
    }
    
    public override func layoutSubviews()
    {
        super.layoutSubviews()
        
        imageView.frame = UIEdgeInsetsInsetRect(bounds, imageInsets)
        imageView.roundCorners()
        
        roundCorners()
    }
    
    // MARK: - Init
    
    override public convenience init(image: UIImage?, highlightedImage: UIImage? = nil)
    {
        self.init(frame: CGRectZero)
        
        imageView = UIImageView(image: image, highlightedImage: highlightedImage)
        
        setup()
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup()
    {
        clipsToBounds = true

        addSubview(imageView)
        roundCorners()
    }
}