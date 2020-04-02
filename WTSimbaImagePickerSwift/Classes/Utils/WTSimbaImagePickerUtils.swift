//
//  WTSimbaImagePickerUtils.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 24/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit
import Foundation

open class WTSimbaImagePickerUtils: NSObject {
    
    open class func imageSquare(_ fullColor: UIColor, in size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        fullColor.set()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let pressedColorImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return pressedColorImg
    }
    
    open class func imageCircle(radius: CGFloat, fill fillColor: UIColor, strokeWidth: CGFloat, stroke strokeColor: UIColor?) -> UIImage? {
        
        return self.imageCircle(diameter: radius * 2, fill: fillColor, strokeWidth: strokeWidth, stroke: strokeColor)
    }
    
    open class func imageCircle(diameter: CGFloat, fill fillColor: UIColor, strokeWidth: CGFloat, stroke strokeColor: UIColor?) -> UIImage? {
        let size = CGSize(width: diameter, height: diameter)
        
        return self.imageCircle(from: size, fill: fillColor, strokeWidth: strokeWidth, stroke: strokeColor)
    }
    
    open class func imageCircle(from size: CGSize, fill fillColor: UIColor, strokeWidth: CGFloat, stroke strokeColor: UIColor?) -> UIImage? {
        
        let scale = UIScreen.main.scale
        let sizeReal = CGSize(width: size.width * scale, height: size.height * scale)
        let lineWidthReal = strokeWidth * scale
        
        UIGraphicsBeginImageContextWithOptions(sizeReal, _: false, _: 1.0)
        
        if lineWidthReal > 0 && lineWidthReal < sizeReal.width && lineWidthReal < sizeReal.height {
            
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: lineWidthReal / 2.0, y: lineWidthReal / 2.0, width: sizeReal.width - lineWidthReal, height: sizeReal.height - lineWidthReal))
            fillColor.setFill()
            ovalPath.fill()
            strokeColor?.setStroke()
            ovalPath.lineWidth = lineWidthReal
            ovalPath.stroke()
        } else {
            
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: sizeReal.width, height: sizeReal.height))
            fillColor.setFill()
            ovalPath.fill()
        }
        
        let pressedColorImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if pressedColorImg != nil {
            let data = pressedColorImg!.pngData()
            if data != nil {
                let image = UIImage(data: data!, scale: scale)
                return image
            }
        }
        return nil
    }
    
    open class func localizedString(_ obj:AnyObject, key: String) -> String {
        
        let b1 = Bundle(for: type(of: obj))
        let path2 = b1.bundlePath + "/WTSimbaImagePickerSwift.bundle"
        let b2 = Bundle(path: path2) ?? b1
        
        return NSLocalizedString(key, bundle: b2, comment: key)
    }
}
