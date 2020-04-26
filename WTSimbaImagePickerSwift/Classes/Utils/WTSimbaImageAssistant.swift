//
//  WTSimbaImageAssistant.swift
//  LilysFriends
//
//  Created by smalltalk on 22/3/2020.
//  Copyright © 2020 wintelsui. All rights reserved.
//

import Foundation
import UIKit
import Photos

public enum WTSimbaImagePickerMediaTypes {
    case video
    case image
    case all
}

public enum WTSimbaAssetImageSizeMode {
    case thumbnail
    case screenSize
    case fullResolution
}

fileprivate let WTSimbaImageAssistantInstance = WTSimbaImageAssistant()

@objcMembers
open class WTSimbaImageAssistant: NSObject {
    
    fileprivate var _albumsGroup: [PHAssetCollection] = [PHAssetCollection]()
    
    open class var shared: WTSimbaImageAssistant {
        return WTSimbaImageAssistantInstance
    }
    
    fileprivate override init() {
        super.init()
        
    }
    
    open class func collectionsDefaut() -> [PHAssetCollection] {
        return WTSimbaImageAssistant.collections()
    }
    
    open class func collections(ignoreEmpty: Bool = false, mediaType: WTSimbaImagePickerMediaTypes = .all) -> [PHAssetCollection] {
        var collections = [PHAssetCollection]()
        
        let userAlbumsOptions = PHFetchOptions()
//        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: userAlbumsOptions)
        
        smartAlbums.enumerateObjects { (collection, idx1, stop) in
            
            let title = collection.localizedTitle ?? ""
            print("B1:title:\(collection.localizedTitle ?? "") (\(collection.estimatedAssetCount))")
            
            if title == "最近项目" ||
                title == "Recents" ||
                title == "相机胶卷" ||
                title == "Camera Roll" ||
                title == "所有照片" ||
                title == "All Photos" {
                
                if ignoreEmpty {
                    let assets = WTSimbaImageAssistant.assets(from: collection, mediaType: mediaType)
                    if assets.count > 0 {
                        collections.insert(collection, at: 0)
                    }
                }else{
                    collections.insert(collection, at: 0)
                }
            }else{
                if ignoreEmpty {
                    let assets = WTSimbaImageAssistant.assets(from: collection, mediaType: mediaType)
                    if assets.count > 0 {
                        collections.append(collection)
                    }
                }else{
                    collections.append(collection)
                }
            }
        }
        
        let userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection>
        if userAlbums != nil {
            userAlbums!.enumerateObjects { (collection, idx1, stop) in

                print("B2:title:\(collection.localizedTitle ?? "")")
                if collection .isMember(of: PHAssetCollection.self) {
                    
                    if ignoreEmpty {
                        let assets = WTSimbaImageAssistant.assets(from: collection, mediaType: mediaType)
                        if assets.count > 0 {
                            collections.append(collection)
                        }
                    }else{
                        collections.append(collection)
                    }
                }
            }
        }
        
        return collections
    }
    
    open class func assets(from collection: PHAssetCollection, mediaType: WTSimbaImagePickerMediaTypes = .all) -> [PHAsset] {
        var assets = [PHAsset]()
        
        let fetchOptions = PHFetchOptions()
        let assetsResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        
        assetsResult.enumerateObjects { (asset, idx1, stop) in
            if mediaType == .all {
                assets.append(asset)
            }else{
                let imageMediaType = asset.mediaType
                if imageMediaType == .image && mediaType == .image{
                    assets.append(asset)
                }else if imageMediaType == .video && mediaType == .video{
                    assets.append(asset)
                }
            }
        }
        
        return assets
    }
    
    
    open class func firstAssets(from collection: PHAssetCollection) -> PHAsset? {
        
        let fetchOptions = PHFetchOptions()
        let assetsResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        let asset = assetsResult.firstObject
        
        return asset
    }
    
    
}

// MARK: - Attach Start

public extension WTSimbaImageAssistant {
    
    @available(iOS 8, *)
    class func authorizationStatus() -> PHAuthorizationStatus {
        
        return PHPhotoLibrary.authorizationStatus()
    }
    
    @available(iOS 8, *)
    class func authorizationStatusRequestIfNotDetermined(_ handler: @escaping (PHAuthorizationStatus) -> Void) -> PHAuthorizationStatus{
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (statusFinal) in
                
                handler(statusFinal)
            }
        }
        
        return status
    }
    
    class func image(asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void, sizeMode: WTSimbaAssetImageSizeMode = .fullResolution, thumbnailSize: CGSize = CGSize(width: 100, height: 100)) {
        
        var targetSize = PHImageManagerMaximumSize
        let contentMode: PHImageContentMode = .aspectFit
        
        if sizeMode == .screenSize {
            let width = UIScreen.main.bounds.size.width < UIScreen.main.bounds.size.height ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
            let height = UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
            targetSize = CGSize(width: width, height: height)
        }else if sizeMode == .thumbnail {
            targetSize = thumbnailSize
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: nil) { (img, _ ) in
            resultHandler(img)
        }
    }
    
    class func imageFullResolution(asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void) {
        
        WTSimbaImageAssistant.image(asset: asset, resultHandler: resultHandler)
    }
    
    class func imageScreenSize(asset: PHAsset, thumbnailSize: CGSize, resultHandler: @escaping (UIImage?) -> Void) {
        
        WTSimbaImageAssistant.image(asset: asset, resultHandler: resultHandler, sizeMode: .screenSize)
    }
    
    class func imageThumbnail(asset: PHAsset, thumbnailSize: CGSize, resultHandler: @escaping (UIImage?) -> Void) {
        
        WTSimbaImageAssistant.image(asset: asset, resultHandler: resultHandler, sizeMode: .thumbnail, thumbnailSize: thumbnailSize)
    }
    
    
    func saveImage(image: UIImage, album: PHAssetCollection? = nil, completionHandler: ((Bool, PHAsset?, Error?) -> Void)? = nil) {
        
        var assetPlaceholder: PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            assetPlaceholder = changeRequest.placeholderForCreatedAsset
            if (album != nil){
//                PHAssetCollectionChangeRequest.collect
            }
        }) { (success, error) in
            var asset: PHAsset? = nil
            if (success) {
                if assetPlaceholder != nil {
                    let result = PHAsset.fetchAssets(withLocalIdentifiers: [assetPlaceholder!.localIdentifier], options: nil)
                    asset = result.firstObject
                }
            }
            if (completionHandler != nil) {
                completionHandler!(success, asset, error)
            }
        }
    }
    
}
