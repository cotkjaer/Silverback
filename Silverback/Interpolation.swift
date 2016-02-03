//
//  Interpolation.swift
//  Silverback
//
//  Created by Christian Otkjær on 30/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation
import UIKit

func cubicSplineFunction(points: [CGPoint]) -> (Int, CGFloat) -> CGFloat
{
    let len = points.count
    var x = points.map{$0.x}
    var y = points.map{$0.y}
    
    var h = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var u = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var lam = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)

    for i in 0..<len-1
    {
        h[i] = x[i+1] - x[i]
    }
    
    for i in 1..<len - 1
    {
        u[i] = h[i-1]/(h[i] + h[i-1])
        lam[i] = h[i]/(h[i] + h[i-1])
    }
    
    var a = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var b = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var c = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)

    var m = Array<Array<CGFloat>>()
    
    for i in 0..<len
    {
        m.append(Array<CGFloat>(count: len, repeatedValue: CGFloatZero))
        
        for j in 0..<len
        {
            m[i][j] = 0
        }
        if (i == 0)
        {
            m[i][0] = 2;
            m[i][1] = 1;
            
            b[0] = 2;
            c[0] = 1;
        }
        else if (i == (len - 1))
        {
            m[i][len - 2] = 1;
            m[i][len - 1] = 2;
            
            a[len-1] = 1;
            b[len-1] = 2;
        }
        else
        {
            m[i][i-1] = lam[i];
            m[i][i] = 2;
            m[i][i+1] = u[i];
            
            a[i] = lam[i];
            b[i] = 2;
            c[i] = u[i];
        }
    }
    
    var g = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    
    g[0] = 3 * (y[1] - y[0])/h[0]
    g[len-1] = 3 * (y[len - 1] - y[len - 2])/h[len - 2]
    
    for i in 1..<len - 1
    {
        let s = u[i] * (y[i+1] - y[i])/h[i]
        let t = lam[i] * (y[i] - y[i-1])/h[i-1]
        g[i] = 3 * ( t + s )
    }
    
    //< Solve the Equations
    
    var p = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var q = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)

    p[0] = b[0]
    
    for i in 0..<len - 1
    {
        q[i] = c[i]/p[i]
    }
    
    for i in 1..<len
    {
        p[i] = b[i] - a[i]*q[i-1]
    }
    
    var su = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var sq = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)
    var sx = Array<CGFloat>(count: len, repeatedValue: CGFloatZero)

    su[0] = c[0]/b[0]
    sq[0] = g[0]/b[0]
    
    for i in 1..<len - 1
    {
        su[i] = c[i]/(b[i] - su[i-1]*a[i])
    }
    
    for i in 1..<len
    {
        sq[i] = (g[i] - sq[i-1]*a[i])/(b[i] - su[i-1]*a[i]);
    }
    
    sx[len-1] = sq[len-1];
    for i in Array(0..<len - 1).reverse()
    {
        sx[i] = sq[i] - su[i]*sx[i+1];
    }
    
    let ph = h;
    let px = x;
    let psx = sx;
    let py = y;

    let f = { (k: Int, vX: CGFloat) -> CGFloat in
        
        let vX_pXk = vX - px[k]
        let vX_pXk1 = vX - px[k+1]
        
        let pow_vX_pXk = vX_pXk * vX_pXk
        let pow_vX_pXk1 = vX_pXk1 * vX_pXk1
        
        let phk2 = ph[k] * ph[k]
        let phk3 = phk2 * ph[k]

        let p1 =  (ph[k] + 2 * vX_pXk) * (pow_vX_pXk1) * py[k] / phk3
        let p2 =  (ph[k] - 2 * vX_pXk1) * pow_vX_pXk * py[k+1] / phk3
        let p3 =  vX_pXk * pow_vX_pXk1 * psx[k] / phk2
        let p4 =  vX_pXk1 * pow_vX_pXk * psx[k+1] / phk2

//        let p1 =  (ph[k] + 2 * (vX - px[k])) * ((vX - px[k+1]) * (vX - px[k+1])) * py[k] / (ph[k] * ph[k] * ph[k])
//        let p2 =  (ph[k] - 2 * (vX - px[k+1])) * pow((vX - px[k]), 2) * py[k+1] / pow(ph[k], 3)
//        let p3 =  (vX - px[k]) * pow((vX - px[k+1]), 2) * psx[k] / pow(ph[k], 2)
//        let p4 =  (vX - px[k+1]) * pow((vX - px[k]), 2) * psx[k+1] / pow(ph[k], 2)

        return p1 + p2 + p3 + p4
    }
    
    return f
}

func drawCubicSplineInRect(rect: CGRect, points: [CGPoint], inContext context: CGContextRef)
{
    let path = UIBezierPath()
    
    let f = cubicSplineFunction(points)
    
    for (i, pt) in points.enumerate()
    {
        if (i == 0)
        {
            path.moveToPoint(pt)
        }
        else
        {
            let curP = points[i-1]
            let delta = CGFloat(1)
            for var pointX = curP.x; abs(pointX - pt.x) > 1e-5; pointX += delta
            {
                let pointY = f(i-1, pointX)
                
                path.addLineToPoint(CGPoint(x: pointX, y: pointY))
            }
        }
    }

    path.lineWidth = 1
    UIColor.blackColor().setStroke()
    path.stroke()
}