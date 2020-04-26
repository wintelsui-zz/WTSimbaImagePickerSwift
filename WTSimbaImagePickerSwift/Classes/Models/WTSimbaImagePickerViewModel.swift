//
//  WTSimbaImagePickerViewModel.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 24/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit
import Photos

open class WTSimbaImagePickerViewModel: NSObject {
    
    var collections = [PHAssetCollection]()
    var currentIndex = 0
    var currentAssets = [PHAsset]()
    
    var selectedAssets = [PHAsset]()
    var editedAssets = [PHAsset: WTSimbaImagePickerImageEditedModel]()
}

open class WTSimbaImagePickerImageEditedModel: NSObject {
    
    open var imagePath = ""
    open var image: UIImage? = nil
    
    open func getImageCache() -> UIImage? {
        
        return nil
    }
}
