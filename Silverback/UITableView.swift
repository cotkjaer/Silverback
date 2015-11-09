//
//  UITableView.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/11/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

extension UITableView
{
    public func refreshCellHeights()
    {
        beginUpdates()
        endUpdates()
    }
}