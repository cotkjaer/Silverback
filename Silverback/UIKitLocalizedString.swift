//
//  UIKitLocalizedString.swift
//  Silverback
//
//  Created by Christian Otkjær on 15/01/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation

// MARK: - Localization

public enum UIKitLocalizeableString : String
{
    case Search = "Search"
    case Done = "Done"
    case Cancel = "Cancel"
    case Delete = "Delete"
    case Edit = "Edit"

    var localizedString: String
        {
        return NSBundle(identifier: "com.apple.UIKit")?.localizedStringForKey(rawValue, value: nil, table: nil) ?? rawValue
    }
}

/// localized System UIKit Strings, like "Search", "Cancel", "Done", "Delete"
public func UIKitLocalizedString(key: String) -> String
{
    return NSBundle(identifier: "com.apple.UIKit")?.localizedStringForKey(key, value: nil, table: nil) ?? key
}

/// localized System UIKit Strings, like "Search", "Cancel", "Done", "Delete"
public func UIContactsLocalizedString(key: String) -> String
{
    return NSBundle(identifier: "com.apple.ContactsUI")?.localizedStringForKey(key, value: nil, table: nil) ?? key
}

