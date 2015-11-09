//
//  UILabel.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

//MARK: - Set Text Animated

extension UILabel
{
    /// crossfades the existing text with the `text` parameters in `duration`seconds
    public func setText(text: String, duration: Double)
    {
        UIView.transitionWithView(self, duration: duration, options: [.TransitionCrossDissolve], animations: { self.text = text }, completion: nil)
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
