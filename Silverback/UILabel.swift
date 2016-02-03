//
//  UILabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

// MARK: - init

extension UILabel
{
    public convenience init(text: String?, color: UIColor?)
    {
        self.init(frame: CGRectZero)
        
        self.text = text
        
        if let c = color
        {
            textColor = c
        }
        
        sizeToFit()
    }
}


//MARK: - Set Text Animated

extension UILabel
{
    /// crossfades the existing text with the `text` parameters in `duration`seconds
    public func setText(text: String, duration: Double, ifDifferent: Bool = true)
    {
        if (ifDifferent && text != self.text) || !ifDifferent
        {
            UIView.transitionWithView(self, duration: duration, options: [.TransitionCrossDissolve], animations: { self.text = text }, completion: nil)
        }
    }
}

// MARK: - Fontname

extension UILabel
{
    public var fontName : String
        {
        get { return font.fontName }
        set { if fontName != newValue { if let newFont = UIFont(name: newValue, size: font.pointSize) { font = newFont } else { debugPrint("Cannot make font with name \(newValue)") } }
        }
        
    }
}

extension UILabel
{
    public func sizeFontToFitWidth(width: CGFloat,
        minSize: CGFloat = 1,
        maxSize: CGFloat = 512)
    {
        let fontSize = font.pointSize
        
        guard minSize < maxSize - 1 else { return }
        
        if let estimatedWidth = text?.sizeWithFont(font).width
        {
            if width > estimatedWidth
            {
                if fontSize >= maxSize
                {
                    font = font.fontWithSize(maxSize)
                }
                else
                {
                    font = font.fontWithSize(ceil((fontSize + maxSize) / 2))
                    
                    sizeFontToFitWidth(width, minSize: fontSize, maxSize: maxSize)
                }
            }
            else if width < estimatedWidth
            {
                if fontSize <= minSize
                {
                    font = font.fontWithSize(minSize)
                }
                else
                {
                    font = font.fontWithSize(floor((fontSize + minSize) / 2))
                    
                    sizeFontToFitWidth(width, minSize: minSize, maxSize: fontSize)
                }
            }
        }
    }
    
    
    public func sizeFontToFit(sizeToFit: CGSize,
        minSize: CGFloat = 1,
        maxSize: CGFloat = 512)
    {
        let fontSize = font.pointSize
        
        guard minSize < maxSize - 1 else { return font = font.fontWithSize(minSize) }
        
        if let aText = self.attributedText
        {
            let estimatedSize = aText.boundingRectWithSize(sizeToFit, options: [ NSStringDrawingOptions.UsesLineFragmentOrigin ], context: nil).size
            
            debugPrint("estimatedSize: \(estimatedSize), sizeToFit: \(sizeToFit)")
            
            if estimatedSize.width < sizeToFit.width &&
                estimatedSize.height < sizeToFit.height
            {
                if fontSize <= minSize
                {
                    font = font.fontWithSize(minSize)
                }
                
                font = font.fontWithSize(floor((fontSize + maxSize) / 2))
                
                sizeFontToFit(sizeToFit, minSize: fontSize, maxSize: maxSize)
            }
            
            if estimatedSize.width > sizeToFit.width ||
                estimatedSize.height > sizeToFit.height
            {
                if fontSize >= maxSize
                {
                    font = font.fontWithSize(maxSize)
                }
                
                font = font.fontWithSize(floor((fontSize + minSize) / 2))
                
                sizeFontToFit(sizeToFit, minSize: minSize, maxSize: fontSize)
            }
        }
    }
    
    public func fontToFitSize(sizeToFit: CGSize, textToMeasure: String? = nil) -> UIFont
    {
        return (textToMeasure ?? text ?? "").fontToFitSize(
            sizeToFit,
            font: font,
            lineBreakMode: lineBreakMode,
            minSize: 4,
            maxSize: floor(min(sizeToFit.height, sizeToFit.width)))
    }
}


public class ClockLabel: UILabel
{
    let timeFormatter = NSDateFormatter(timeStyle: .ShortStyle, dateStyle: .NoStyle)
    
    // MARK: - Lifecycle
    
    func setup()
    {
        scheduleUpdate()
    }

    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit
    {
        unscheduleUpdate()
    }
    
    // MARK: - size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        return super.sizeThatFits(size)
    }
    
    public override func sizeToFit()
    {
        super.sizeToFit()
    }
    
    // MARK: - Update
    
    public func update()
    {
        foreground { self.text = self.timeFormatter.stringFromDate(NSDate()) }
    }
    
    private(set) var started : Bool = false
        {
        didSet
        {
            if started
            {
                scheduleUpdate()
            }
            else
            {
                unscheduleUpdate()
            }
        }
    }
    
    public func start()
    {
        started = true
    }
    
    public func stop()
    {
        started = false
    }
    
    
    // MARK: - Timers
    
    var timer: NSTimer?
    
    func scheduleUpdate()
    {
        unscheduleUpdate()
        
        update()
        
        let now = NSDate().timeIntervalSinceReferenceDate
        
        let timeUntilNextMinuteChange : Double = 60 - (now % 60)
        
        let timer = NSTimer(timeInterval: timeUntilNextMinuteChange, target: self, selector: Selector("scheduleUpdate"), userInfo: nil, repeats: false)
        
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        self.timer = timer
    }
    
    func unscheduleUpdate()
    {
        timer?.invalidate()
        timer = nil
    }
    
}

//MARK: - Size Adjust

extension UILabel
{
    public func adjustFontSizeToFitRect(rect : CGRect)
    {
        guard text != nil else { return }
        
        frame = rect
        
        let MaxFontSize: CGFloat = 512
        let MinFontSize: CGFloat = 4
        
        var q = Int(MaxFontSize)
        var p = Int(MinFontSize)
        
        let constraintSize = CGSize(width: rect.width, height: CGFloat.max)
        
        while(p <= q)
        {
            let currentSize = (p + q) / 2
            
            font = UIFont(descriptor: font.fontDescriptor(), size: CGFloat(currentSize))
            
            let text = NSAttributedString(string: self.text!, attributes: [NSFontAttributeName:font])
            
            let textRect = text.boundingRectWithSize(constraintSize, options: .UsesLineFragmentOrigin, context: nil)
            
            let labelSize = textRect.size
            
            if labelSize.height < frame.height &&
                labelSize.height >= frame.height - 10 &&
                labelSize.width < frame.width &&
                labelSize.width >= frame.width - 10
            {
                break
            }
            else if labelSize.height > frame.height || labelSize.width > frame.width
            {
                q = currentSize - 1
            }
            else
            {
                p = currentSize + 1
            }
        }
    }
}
