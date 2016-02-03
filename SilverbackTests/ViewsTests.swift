//
//  ViewsTests.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import XCTest

class ViewsTests: XCTestCase
{
 
    func testSmileyView()
    {
        let smileyView = SmileyView()
        smileyView.bounds = CGRect(size: CGSize(widthAndHeight: 900))
        
        smileyView.snapshot().saveAsPNG("smileyWithBorder")
        
        smileyView.faceBorder = false

        smileyView.snapshot().saveAsPNG("smileyNoBorder")
    }

    func testSpeechBubbleView()
    {
        let view = SpeechBubbleView()
        view.bounds = CGRect(size: CGSize(widthAndHeight: 900))
        
        view.snapshot().saveAsPNG("speech")
    }
    
    
    func testArcAndSpikeView()
    {
        let view = ArcAndSpikeView()
        view.bounds = CGRect(size: CGSize(widthAndHeight: 900))
        
        view.snapshot().saveAsPNG("plusArcWithSpike")
        
        view.spike = nil

        view.snapshot().saveAsPNG("plusArc")
    }
}
