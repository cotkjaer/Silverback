//
//  Dropbox.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

public class ConnectionEndpoint
{
    public enum Type
    {
        case None, InnerEllipse //, OuterEllipse, Frame, Border
        
        func pathForFrame(frame: CGRect?) -> UIBezierPath
        {
            if let f = frame
            {
                switch self
                {
                case .None:
                    return UIBezierPath()
                case .InnerEllipse:
                    return UIBezierPath(ovalInRect: f)
                    
                }
            }
            
            return UIBezierPath()
        }
    }
    
    required public init() { }
    
    public var type : Type = .None
    
    func pathForFrame(frame:CGRect?) -> UIBezierPath
    {
        return type.pathForFrame(frame)
    }
    
    func pointOnRimAtAngle(theta: CGFloat?, forFrame frame:CGRect?) -> CGPoint?
    {
        if let f = frame, let a = theta
        {
            switch type
            {
            case .None:
                return f.center
            case .InnerEllipse:
                return CGPoint(x: cos(a) * f.width / 2, y: sin(a) * f.height / 2) + f.center
            }
        }
        
        return nil
    }
}

public class Connection: CAShapeLayer
{
    var location = CGPointZero
    
    private let fromEndpoint = ConnectionEndpoint()
    private let toEndpoint = ConnectionEndpoint()
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override public init()
    {
        super.init()
        
        setup()
    }
    
    func setup()
    {
        fillColor = nil
        fillRule = kCAFillRuleNonZero
        
        lineCap = kCALineCapRound
        lineDashPattern = nil
        lineDashPhase = 0.0
        lineJoin = kCALineJoinRound
        lineWidth = 0.66
        
        miterLimit = lineWidth * 2
        
        strokeColor = UIColor.grayColor().CGColor
        
        fromEndpoint.type = .InnerEllipse
        toEndpoint.type = .InnerEllipse
    }
    
    public enum ConnectionAnchor
    {
        case
        Right,
        Left,
        Up,
        Down,
        None
        
        var opposite : ConnectionAnchor
            {
                switch self
                {
                case .Up:
                    return .Down
                case .Down:
                    return .Up
                case .Left:
                    return .Right
                case .Right:
                    return .Left
                case .None:
                    return .None
                }
        }
        
        var angle : CGFloat?
            {
                switch self
                {
                case .Up:
                    return 3 * π / 2
                case .Down:
                    return π / 2
                case .Left:
                    return π
                case .Right:
                    return 0
                case .None:
                    return nil
                }
        }
    }
    
    public var fromFrame: CGRect?
        { didSet { if oldValue != fromFrame { updateConnection() } } }
    
    public var toFrame: CGRect?
        { didSet { if oldValue != toFrame { updateConnection() } } }
    
    public var fromAnchor : ConnectionAnchor = .None
        { didSet { if oldValue != fromAnchor { updateConnection() } } }
    
    public var toAnchor : ConnectionAnchor = .None
        { didSet { if oldValue != toAnchor { updateConnection() } } }
    
    public func updateConnection()
    {
        let bezierPath = fromEndpoint.pathForFrame(fromFrame)
        
        if let fromFrame = self.fromFrame, let toFrame = self.toFrame
        {
            var controlPoint1 = CGPoint()
            var controlPoint2 = CGPoint()
            
            var fromPoint = CGPoint()
            var toPoint = CGPoint()
            
            if let point = fromEndpoint.pointOnRimAtAngle(fromAnchor.angle, forFrame:fromFrame)
            {
                fromPoint = point
                bezierPath.moveToPoint(fromPoint)
            }
            
            if let point = toEndpoint.pointOnRimAtAngle(toAnchor.angle, forFrame:toFrame)
            {
                toPoint = point
            }
            
            bezierPath.moveToPoint(fromPoint)
            
            switch toAnchor
            {
            case .Up:
                toPoint = toFrame.topCenter
                controlPoint2 = toPoint.with(y: (fromPoint.y + toPoint.y) / 2)
            case .Down:
                toPoint = toFrame.bottomCenter
                controlPoint2 = toPoint.with(y: (fromPoint.y + toPoint.y) / 2)
            case .Left:
                toPoint = toFrame.centerLeft
                controlPoint2 = toPoint.with(x: (fromPoint.x + toPoint.x) / 2)
            case .Right:
                toPoint = toFrame.centerRight
                controlPoint2 = toPoint.with(x: (fromPoint.x + toPoint.x) / 2)
            case .None:
                bezierPath.removeAllPoints()
                path = nil
                return
            }
            
            switch fromAnchor
            {
            case .Up:
                controlPoint1 = fromPoint.with(y: (fromPoint.y + toPoint.y) / 2)
            case .Down:
                controlPoint1 = fromPoint.with(y: (fromPoint.y + toPoint.y) / 2)
            case .Left:
                controlPoint1 = fromPoint.with(x: (fromPoint.x + toPoint.x) / 2)
            case .Right:
                controlPoint1 = fromPoint.with(x: (fromPoint.x + toPoint.x) / 2)
            case .None:
                bezierPath.removeAllPoints()
                path = nil
                return
            }
            
            bezierPath.addCurveToPoint(toPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            
            bezierPath.appendPath(toEndpoint.pathForFrame(toFrame))
            
        }
        
        path = bezierPath.CGPath
    }
    
    //MARK: - Animation
    
    public var animatePath : Bool = false
    
    override public func actionForKey(event: String) -> CAAction?
    {
        if event == "path" && animatePath
        {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = CATransaction.animationDuration()
            animation.timingFunction = CATransaction.animationTimingFunction()
            
            return animation
        }
        
        return super.actionForKey(event)
    }
}


// MARK: - CNContactPickerViewController

@available(iOS 9.0, *)
extension CNContactPickerViewController
{
    @available(iOS 9.0, *)
    public convenience init(delegate: CNContactPickerDelegate)
    {
        self.init()
        self.delegate = delegate
    }
}



@IBDesignable
public class BarsView: IconView
{
    @IBInspectable
    public var bars: Int = 4
    
    public override func pathsForRect(rect: CGRect) -> [UIBezierPath]
    {
        var paths = Array<UIBezierPath>()
        
        let center = rect.center
        let diameter = min(rect.width, rect.height)
        
        let sizedRect = CGRect(center: center, size: CGSize(widthAndHeight: diameter * sizeFactor))
        
        switch abs(bars)
        {
        case 0:
            break
            
        case 1:
            
            let barPath = UIBezierPath()
            
            barPath.moveToPoint(sizedRect.centerLeft)
            barPath.addLineToPoint(sizedRect.centerRight)
            
            barPath.lineCapStyle = .Round
            
            paths.append(barPath)
            
        default:
            
            let spaces = CGFloat(bars - 1)
            
            for bar in 0..<bars
            {
                let barPath = UIBezierPath()
                let factor = bar / spaces
                
                barPath.moveToPoint(lerp(sizedRect.topLeft, sizedRect.bottomLeft, factor))
                barPath.addLineToPoint(lerp(sizedRect.topRight, sizedRect.bottomRight, factor))
                
                barPath.lineCapStyle = .Round
                
                paths.append(barPath)
            }
        }
        
        return paths
    }
}


@IBDesignable
public class PlusView: IconView
{
    @IBInspectable
    public var border: Bool = true
    
    public override func pathsForRect(rect: CGRect) -> [UIBezierPath]
    {
        var paths = Array<UIBezierPath>()
        
        let center = rect.center
        let diameter = min(rect.width, rect.height)
        
        let sizedRect = CGRect(center: center, size: CGSize(widthAndHeight: diameter * sizeFactor))
        
        if border
        {
            paths.append(UIBezierPath(ovalInRect: rect))
        }
        
        let plusPath = UIBezierPath()
        
        plusPath.moveToPoint(sizedRect.topCenter)
        plusPath.addLineToPoint(sizedRect.bottomCenter)
        
        plusPath.moveToPoint(sizedRect.centerLeft)
        plusPath.addLineToPoint(sizedRect.centerRight)
        
        plusPath.lineJoinStyle = .Round
        plusPath.lineCapStyle = .Round
        
        paths.append(plusPath)
        
        return paths
    }
}


