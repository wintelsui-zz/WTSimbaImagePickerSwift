//
//  WTSimbaImageItemCollectionCell.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 24/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit
import Photos

class SelectView: UIView {
    
    let selectView: UIView!
    let selectButton: UIButton!
    let numberView: UIView!
    let numberlabel: UILabel!
    
    var selectButtonCallBack : (() -> Void)?
    
    override init(frame: CGRect) {
        selectView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        selectButton = UIButton(type: .custom)
        numberView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        numberlabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        self.backgroundColor = UIColor.clear
        
        selectView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(selectView)
        
        numberView.backgroundColor = UIColor(red:0.55, green:0.77, blue:0.29, alpha:1.00)
        numberView.layer.cornerRadius = 13.0
        self.addSubview(numberView)
        
        numberlabel.textColor = UIColor.white
        numberlabel.font = UIFont.systemFont(ofSize: 14.0)
        numberlabel.text = ""
        numberlabel.numberOfLines = 1
        numberlabel.textAlignment = .center
        numberView.addSubview(numberlabel)
        
        selectButton.setImage(UIImage(named: "Frameworks/WTSimbaImagePickerSwift.framework/WTSimbaImagePickerSwift.bundle/icon_picker_select_circle"), for: .normal)
        selectButton.setImage(UIImage(named: "Frameworks/WTSimbaImagePickerSwift.framework/WTSimbaImagePickerSwift.bundle/icon_picker_image_clear"), for: .selected)
        selectButton.addTarget(self, action: #selector(selectButtonPressed(sender:)), for: .touchUpInside)
        self.addSubview(selectButton)
        
        
        selectView.translatesAutoresizingMaskIntoConstraints = false;
        selectView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        selectView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        selectView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        selectView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        selectButton.translatesAutoresizingMaskIntoConstraints = false;
        selectButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        selectButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        selectButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        selectButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        numberlabel.translatesAutoresizingMaskIntoConstraints = false;
        numberlabel.topAnchor.constraint(equalTo: numberView.topAnchor, constant: 0).isActive = true
        numberlabel.bottomAnchor.constraint(equalTo: numberView.bottomAnchor, constant: 0).isActive = true
        numberlabel.leftAnchor.constraint(equalTo: numberView.leftAnchor, constant: 5).isActive = true
        numberlabel.centerXAnchor.constraint(equalTo: numberView.centerXAnchor).isActive = true
        
        numberView.translatesAutoresizingMaskIntoConstraints = false;
        numberView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        numberView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        numberView.widthAnchor.constraint(greaterThanOrEqualToConstant: 26.0).isActive = true
        numberView.heightAnchor.constraint(greaterThanOrEqualToConstant: 26.0).isActive = true
        
        updateAnimation(selected: false)
    }
    
    
    func updateAnimation(selected: Bool, animated: Bool = true) {
        
        selectView.isHidden = !selected
        numberView.isHidden = !selected
        selectButton.isSelected = selected
        
        if selected {
            if animated {
                
            }
        }else{
            
        }
    }
    
    @objc func selectButtonPressed(sender: UIButton) {
        if selectButtonCallBack != nil {
            selectButtonCallBack!()
        }
    }
}

@objc protocol WTSimbaImageItemCollectionCellDelegate : NSObjectProtocol {
    
    @objc optional func collectionCellSelectButtonPressed(cell: WTSimbaImageItemCollectionCell?, indexPath: IndexPath?)
    
}


class WTSimbaImageItemCollectionCell: UICollectionViewCell {
    
    weak var delegate: WTSimbaImageItemCollectionCellDelegate?
    
    let bgView: UIView!
    let imageView: UIImageView!
    let selectView: SelectView!
    
    var imageAsset: PHAsset?
    
    override init(frame: CGRect) {
        bgView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        selectView = SelectView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentView.addSubview(bgView)
        
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        bgView.addSubview(imageView)
        
        
        bgView.addSubview(selectView)
        selectView.selectButtonCallBack = {() in
            if self.delegate != nil {
                if self.delegate!.responds(to: #selector(WTSimbaImageItemCollectionCellDelegate.collectionCellSelectButtonPressed(cell:indexPath:))) {
                    
                    self.delegate?.collectionCellSelectButtonPressed?(cell: self, indexPath: nil)
                }
            }
        }
        
        
        bgView.translatesAutoresizingMaskIntoConstraints = false;
        bgView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 1).isActive = true
        bgView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 1).isActive = true
        bgView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -1).isActive = true
        bgView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -1).isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        imageView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: 0).isActive = true
        
        selectView.translatesAutoresizingMaskIntoConstraints = false;
        selectView.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 0).isActive = true
        selectView.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 0).isActive = true
        selectView.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: 0).isActive = true
        selectView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: 0).isActive = true
    }
    
    func loadImage(asset: PHAsset) {
        imageAsset = asset
        let width = UIScreen.main.bounds.size.width / CGFloat(4)
        let scale = UIScreen.main.scale
        let widthFinal = width * scale
        
        if imageAsset != nil {
            WTSimbaImageAssistant.image(asset: imageAsset!, resultHandler: { [unowned self] (img) in
                self.imageView.image = img
            }, sizeMode: .thumbnail, thumbnailSize: CGSize(width: widthFinal, height: widthFinal))
        }else{
            self.imageView.image = nil
        }
        
    }
    
    func updateSelect(_ selected: Bool, index: Int, animated: Bool = true) {
        if selected {
            selectView.numberlabel.text = "\(index)"
        }else{
            selectView.numberlabel.text = ""
        }
        selectView.updateAnimation(selected: selected, animated: animated)
        
    }
}
