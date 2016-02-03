//
//  UIPickerView.swift
//  Silverback
//
//  Created by Christian Otkjær on 08/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import UIKit

extension UIPickerView
{
    public func maxSizeForRowsInComponent(component: Int) -> CGSize
    {
        var size = CGSizeZero
        
        if let delegate = self.delegate, let dataSource = self.dataSource, let widthToFit = delegate.pickerView?(self, widthForComponent: component)
        {
            let sizeToFit = CGSize(width: widthToFit , height: 10000)
            
            for row in 0..<dataSource.pickerView(self, numberOfRowsInComponent: component)
            {
                let view = delegate.pickerView!(self, viewForRow: row, forComponent: component, reusingView: nil)
                
                let wantedSize = view.sizeThatFits(sizeToFit)
                
                size.width = max(size.width, wantedSize.width)
                size.height = max(size.height, wantedSize.height)
            }
        }
        
        return size
    }
}
