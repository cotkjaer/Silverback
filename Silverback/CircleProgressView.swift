//
//  CircleProgressView.swift
//  Silverback
//
//  Created by Christian Otkjær on 12/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

// MARK: - EXPERIMENT

import UIKit

@IBDesignable
public class CircleProgressView: UIView
{
    private let trackLayer = ArcLayer()
    private let progressLayer = ArcLayer()
    
    static let DefaultTrackColor = UIColor(white: 0, alpha: 0.01)
    
    @IBInspectable
    public var trackColor : UIColor = DefaultTrackColor
        {
        didSet { trackLayer.arcColor = trackColor.CGColor }
    }
    
    static let DefaultProgressColor = UIColor.blueColor()
    
    @IBInspectable
    public var progressColor : UIColor = DefaultProgressColor
        {
        didSet { progressLayer.arcColor = progressColor.CGColor }
    }
    
    @IBInspectable
    public var startDegrees : CGFloat
        {
        set { startAngle = degrees2radians(newValue) }
        get { return radians2degrees(startAngle) }
    }
    
    public var startAngle : CGFloat = 0
        {
        didSet
        {
            //            let normalized = startAngle.asNormalizedAngle
            trackLayer.arcStartAngle = startAngle//normalized
            progressLayer.arcStartAngle = startAngle//normalized
            trackLayer.arcEndAngle = endAngle//normalized
            progressLayer.arcEndAngle = progressEndAngle()
        }
    }
    
    @IBInspectable
    public var endDegrees : CGFloat
        {
        set { endAngle = degrees2radians(newValue) }
        get { return radians2degrees(endAngle) }
    }
    
    public var endAngle : CGFloat = π2
        {
        didSet
        {
            //            let normalized = startAngle.asNormalizedAngle
            trackLayer.arcEndAngle = endAngle//normalized
            progressLayer.arcEndAngle = progressEndAngle()
        }
    }
    
    private func progressEndAngle() -> CGFloat
    {
        return startAngle * CGFloat(1 - value) + endAngle * CGFloat(value)
    }
    
    @IBInspectable
    public var clockwise : Bool = true
    
    @IBInspectable
    public var value: Float = 0.5
        {
        didSet
        {
            progressLayer.arcEndAngle = progressEndAngle()
        }
    }
    
    @IBInspectable
    public var arcWidth: CGFloat = 5
        {
        didSet
        {
            trackLayer.arcWidth = arcWidth
            progressLayer.arcWidth = arcWidth
        }
    }
    
    //    override public class func layerClass() -> AnyClass {  return ArcLayer.self }
    
    // MARK: - Size
    
    public override func sizeThatFits(size: CGSize) -> CGSize
    {
        let minDiameter = arcWidth * 4
     
        let diameter = min(size.height, size.width)
        
        return CGSize(widthAndHeight: floor(max(minDiameter, diameter)))
    }
    
    // MARK: - Bounds
    
    override public var bounds : CGRect { didSet { updateLayerFrames() } }
    override public var frame : CGRect { didSet { updateLayerFrames() } }
    
    func updateLayerFrames()
    {
        trackLayer.frame = bounds
        progressLayer.frame = bounds
    }
    
    func updateLayerProperties()
    {
        trackLayer.arcStartAngle = startAngle//.normalizedRadians
        trackLayer.arcClockwise = clockwise
        trackLayer.arcColor = trackColor.CGColor
        trackLayer.arcWidth = arcWidth
        trackLayer.arcEndAngle = endAngle//.normalizedRadians
        
        progressLayer.arcStartAngle = startAngle//.normalizedRadians
        progressLayer.arcClockwise = clockwise
        progressLayer.arcColor = progressColor.CGColor
        progressLayer.arcWidth = arcWidth
        progressLayer.arcEndAngle = startAngle * CGFloat(1 - value) + endAngle * CGFloat(value)//.normalizedRadians
    }
    
    // MARK: - Init
    
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
    
    func setup()
    {
        updateLayerFrames()
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        
        updateLayerProperties()
    }
}
