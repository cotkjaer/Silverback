//
//  NSFileManager.swift
//  Silverback
//
//  Created by Christian Otkjær on 27/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Document Directory

extension NSFileManager
{
    public class func documentsDirectoryURL() -> NSURL?
    {
        if let path = documentDirectoryPath()
        {
            return NSURL(fileURLWithPath: path, isDirectory: true)
        }
        
        return nil
    }
    
    public class func documentDirectoryPath() -> String?
    {
        return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last
    }
}

