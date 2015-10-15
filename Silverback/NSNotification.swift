//
//  NSNotification.swift
//  Silverback
//
//  Created by Christian Otkjær on 02/10/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Foundation

public func postNotificationNamed(name: String, object: AnyObject? = nil)
{
    NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
}

//public func postNotificationNamed(name: String, object: AnyObject? = nil, keyValuePairs:(NSObject, AnyObject)...)
//{
//    var userInfo = Dictionary<NSObject, AnyObject>()
//    
//    for (key, value) in keyValuePairs
//    {
//        userInfo[key] = value
//    }
//    
//    if userInfo.isEmpty
//    {
//        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
//    }
//    else
//    {
//        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: userInfo)
//    }
//}
