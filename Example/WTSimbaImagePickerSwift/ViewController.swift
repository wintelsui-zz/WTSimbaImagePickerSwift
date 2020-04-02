//
//  ViewController.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 23/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit
import Photos
import WTSimbaImagePickerSwift

class ViewController: UIViewController {

    private var clickBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        
        if clickBtn == nil {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 20, y: 100, width: 80, height: 40)
            button.setTitle("Picker", for: .normal)
            button.setImage(nil, for: .normal)
            button.addTarget(self, action: #selector(clickBtnPressed), for: .touchUpInside)
            
            clickBtn = button
        }
        
        self.view.addSubview(clickBtn)
        
        clickBtn.translatesAutoresizingMaskIntoConstraints = false;
        NSLayoutConstraint.activate([
            clickBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            clickBtn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            clickBtn.widthAnchor.constraint(equalToConstant: 100),
            clickBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        
//        let collections = WTSimbaImageAssistant.collections()
//
//        for collection in collections {
//            let assets = WTSimbaImageAssistant.assets(from: collection)
//
//            print("title:\(collection.localizedTitle ?? "") (\(assets.count))")
//
//
//            for asset in assets {
//
//                print("burstIdentifier:\(asset.burstIdentifier) width:\(asset.pixelWidth) height:\(asset.pixelHeight)")
//            }
//
//
//        }
        
    }
    
    @objc private func clickBtnPressed() {
        let configuration = WTSimbaImagePickerConfiguration()
        configuration.selectNumberMin = 2
        configuration.selectNumberMax = 10
        configuration.mediaType = .image
        configuration.ignoreEmptyAlbum = true
        let picker = WTSimbaImagePickerController(configuration: configuration)
        picker.modalPresentationStyle = .formSheet
        
        self.present(picker, animated: true, completion: nil)
        
        picker.pickerDelegate = self
    }


}

extension ViewController: WTSimbaImagePickerControllerDelegate {
    
    func simbaImagePickerControllerDidFinish(picker: WTSimbaImagePickerController?, images:[PHAsset], editedImages:[PHAsset: WTSimbaImagePickerImageEditedModel]) {
        
        picker?.dismiss(animated: true) {
            
        }
    }
}


