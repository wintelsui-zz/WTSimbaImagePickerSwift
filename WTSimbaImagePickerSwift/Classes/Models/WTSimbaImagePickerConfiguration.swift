//
//  WTSimbaImagePickerConfiguration.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 24/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit

@objcMembers
open class WTSimbaImagePickerConfiguration: NSObject {
    
    open var navigationBarColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
    open var navigationBarTextColor = UIColor.white
    open var previewEnable = false
    open var ignoreEmptyAlbum = false
    open var selectNumberMin = 1
    open var selectNumberMax = INT_MAX
    open var mediaType = WTSimbaImagePickerMediaTypes.all
    
    
    func isSingleSelect() -> Bool {
        return (selectNumberMin == selectNumberMax) && (selectNumberMin == 1)
    }
}
