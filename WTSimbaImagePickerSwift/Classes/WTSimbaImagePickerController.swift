//
//  WTSimbaImagePickerController.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 23/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit
import Photos

@objcMembers
open class WTSimbaImagePickerController: UINavigationController {
    
    open weak var pickerDelegate: WTSimbaImagePickerControllerDelegate?
    
    var configuration = WTSimbaImagePickerConfiguration()
    
    private override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    public init() {
        let viewController = WTSimbaImagePickerViewController()
        super.init(rootViewController: viewController)
        viewController.imagePicker = self
        viewController.configuration = configuration
        self.modalPresentationStyle = .fullScreen
    }
    
    public init(configuration: WTSimbaImagePickerConfiguration = WTSimbaImagePickerConfiguration()) {
        let viewController = WTSimbaImagePickerViewController()
        super.init(rootViewController: viewController)
        viewController.imagePicker = self
        viewController.configuration = configuration
        self.modalPresentationStyle = .fullScreen
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}

@objc public protocol WTSimbaImagePickerControllerDelegate : NSObjectProtocol {
    
    @objc optional func simbaImagePickerControllerDidFinish(picker: WTSimbaImagePickerController?, images:[PHAsset], editedImages:[PHAsset: WTSimbaImagePickerImageEditedModel])
    
    @objc optional func simbaImagePickerControllerCancel(picker: WTSimbaImagePickerController?)
}

// MARK: - ImagePickerViewController Start

fileprivate class WTSimbaImagePickerViewController: UIViewController {
    
    weak var imagePicker: WTSimbaImagePickerController?
    var configuration = WTSimbaImagePickerConfiguration()
    
    let navigationTitleView = UIView()
    let titleLabel = UILabel()
    let titleIcon = UIImageView()
    
    let albumListView = UIControl()
    let albumListTable = UITableView()
    
    var albumListViewTopAnchorShow: NSLayoutConstraint!
    var albumListViewBottomAnchorShow: NSLayoutConstraint!
    var albumListViewHeightAnchorHidden: NSLayoutConstraint!
    var albumListViewBottomAnchorHidden: NSLayoutConstraint!
    
    let limitView = UIView()
    let limitLabel = UILabel()
    let limitButton = UIButton(type: .custom)
    
    let cellIdentifier = "cellIdentifier"
    var assetsCollection: UICollectionView!
    var flowLayout5: UICollectionViewFlowLayout {
        let width = UIScreen.main.bounds.size.width / CGFloat(4)
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        flow.scrollDirection = .vertical
        flow.itemSize = CGSize(width: width, height: width)
        
        return flow
    }
    
    let toolBarView = UIView()
    let toolBarViewBackground = UIView()
    let toolBarDoneButton = UIButton(type: .custom)
    let toolBarPreviewButton = UIButton(type: .custom)
    
    
    let viewMode = WTSimbaImagePickerViewModel()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //先生成UI,进入界面后家在数据
        self.perform(#selector(loadDataFirst), with: nil, afterDelay: 0)
    }
    
    func setupUI() {
        self.view.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        
        setupNavigationUI()
        setupToolBarViewUI()
        setupLimitViewUI()
        setupAssetsViewUI()
        setupAlbumListViewUI()
        
        if configuration.previewEnable == false {
            toolBarPreviewButton.isHidden = true
        }
        
        showAlbumListView(false, animated: false)
    }
    
    func setupNavigationUI() {
        // 导航栏
        if #available(iOS 13, *) {
            self.navigationController?.navigationBar.barStyle = .black
        }else{
            self.navigationController?.navigationBar.barStyle = .blackOpaque
        }
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationController?.navigationBar.barTintColor = configuration.navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: configuration.navigationBarTextColor]
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        cancelButton.setTitle(WTSimbaImagePickerUtils.localizedString(self, key:"cancel"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.setImage(nil, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .touchUpInside)
        
        let cancelItem = UIBarButtonItem(customView: cancelButton)
        self.navigationItem.leftBarButtonItem = cancelItem
        
        self.navigationTitleView.isHidden = true
        
        let widthMax = UIScreen.main.bounds.size.width - 2.0 * (60 + 20)
        
        let titleButton = UIButton(type: .custom)
        titleButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        titleButton.backgroundColor = UIColor(red:0.29, green:0.29, blue:0.29, alpha:1.00)
        titleButton.layer.cornerRadius = 15;
        titleButton.setTitle("", for: .normal)
        titleButton.setImage(nil, for: .normal)
        titleButton.addTarget(self, action: #selector(titleButtonPressed(sender:)), for: .touchUpInside)
        
        navigationTitleView.addSubview(titleButton)
        titleButton.translatesAutoresizingMaskIntoConstraints = false;
        titleButton.centerYAnchor.constraint(equalTo: navigationTitleView.centerYAnchor, constant: 0).isActive = true
        titleButton.rightAnchor.constraint(equalTo: navigationTitleView.rightAnchor, constant: 0).isActive = true
        titleButton.leftAnchor.constraint(equalTo: navigationTitleView.leftAnchor, constant: 0).isActive = true
        
        navigationTitleView.frame = CGRect(x: 0, y: 0, width: widthMax, height: 40)
        navigationTitleView.backgroundColor = UIColor.clear
        self.navigationItem.titleView = navigationTitleView
        
        let titleWidthMax = widthMax - (6 * 3 + 20)
        titleLabel.frame = CGRect(x: 6, y: 0, width: titleWidthMax, height: 40)
        titleLabel.numberOfLines = 1;
        titleLabel.textColor = UIColor.white;
        
        navigationTitleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.topAnchor.constraint(equalTo: navigationTitleView.topAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: navigationTitleView.leftAnchor, constant: 10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: navigationTitleView.bottomAnchor, constant: 0).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: titleWidthMax).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 1.0).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: navigationTitleView.centerXAnchor, constant: -13.0).isActive = true
        
        titleIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        titleIcon.image = UIImage(named: "Frameworks/WTSimbaImagePickerSwift.framework/WTSimbaImagePickerSwift.bundle/icon_picker_arrow_down")
        
        navigationTitleView.addSubview(titleIcon)
        titleIcon.translatesAutoresizingMaskIntoConstraints = false;
        titleIcon.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 6).isActive = true
        titleIcon.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        titleIcon.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        titleIcon.centerYAnchor.constraint(equalTo: navigationTitleView.centerYAnchor, constant: 0).isActive = true
        
    }
    
    func setupLimitViewUI() {
        limitView.backgroundColor = self.view.backgroundColor
        limitView.isHidden = true
        self.view.addSubview(limitView)
        limitView.addSubview(limitLabel)
        limitView.addSubview(limitButton)
        
        limitLabel.textColor = UIColor.white
        limitLabel.font = UIFont.systemFont(ofSize: 15.0)
        limitLabel.textAlignment = .center
        limitLabel.numberOfLines = 0
        limitLabel.text = WTSimbaImagePickerUtils.localizedString(self, key:"Allow App to access your photos in your device's \"Setting\" > \"Privacy\"  > \"Photos\"")
        
        let imgNomal = WTSimbaImagePickerUtils.imageCircle(diameter: 40, fill: UIColor(red:0.13, green:0.75, blue:0.39, alpha:1.00), strokeWidth: 0, stroke: nil)
        
        limitButton.setTitle(WTSimbaImagePickerUtils.localizedString(self, key:"Open system setting"), for: .normal)
        limitButton.setBackgroundImage(imgNomal?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 20), for: .normal)
        limitButton.addTarget(self, action: #selector(limitButtonPressed(sender:)), for: .touchUpInside)
        
        
        limitView.translatesAutoresizingMaskIntoConstraints = false;
        limitView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        limitView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        limitView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        limitView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        limitLabel.translatesAutoresizingMaskIntoConstraints = false;
        limitLabel.leftAnchor.constraint(greaterThanOrEqualTo: limitView.leftAnchor, constant: 15).isActive = true
        limitLabel.centerXAnchor.constraint(equalTo: limitView.centerXAnchor, constant: 0).isActive = true
        limitLabel.bottomAnchor.constraint(equalTo: limitView.centerYAnchor, constant: -10).isActive = true
        
        limitButton.translatesAutoresizingMaskIntoConstraints = false;
        limitButton.centerXAnchor.constraint(equalTo: limitView.centerXAnchor, constant: 0).isActive = true
        limitButton.topAnchor.constraint(equalTo: limitView.centerYAnchor, constant: 10).isActive = true
        limitButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        limitButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    func setupToolBarViewUI() {
        toolBarView.clipsToBounds = false
        toolBarView.backgroundColor = UIColor.clear
        self.view.addSubview(toolBarView)
        
        toolBarViewBackground.backgroundColor = UIColor(red:0.14, green:0.14, blue:0.14, alpha:1.00)
        toolBarView.addSubview(toolBarViewBackground)
        
        let imgNomal = WTSimbaImagePickerUtils.imageCircle(diameter: 10, fill: UIColor(red:0.13, green:0.75, blue:0.39, alpha:1.00), strokeWidth: 0, stroke: nil)
        let imgUnable = WTSimbaImagePickerUtils.imageCircle(diameter: 10, fill: UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00), strokeWidth: 0, stroke: nil)
        toolBarDoneButton.setBackgroundImage(imgNomal?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .normal)
        toolBarDoneButton.setBackgroundImage(imgUnable?.stretchableImage(withLeftCapWidth: 5, topCapHeight: 5), for: .disabled)
        toolBarDoneButton.setTitle(WTSimbaImagePickerUtils.localizedString(self, key:"done"), for: .normal)
        toolBarDoneButton.setTitleColor(UIColor(red:1, green:1, blue:1, alpha:1.00), for: .normal)
        toolBarDoneButton.setTitleColor(UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.00), for: .disabled)
        toolBarDoneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        toolBarDoneButton.addTarget(self, action: #selector(toolBarDoneButtonPressed(sender:)), for: .touchUpInside)
        toolBarView.addSubview(toolBarDoneButton)
        
        toolBarPreviewButton.setTitle(WTSimbaImagePickerUtils.localizedString(self, key:"preview"), for: .normal)
        toolBarPreviewButton.setTitleColor(UIColor(red:1, green:1, blue:1, alpha:1.00), for: .normal)
        toolBarPreviewButton.setTitleColor(UIColor(red:0.30, green:0.30, blue:0.30, alpha:1.00), for: .disabled)
        toolBarPreviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        toolBarPreviewButton.addTarget(self, action: #selector(toolBarDoneButtonPressed(sender:)), for: .touchUpInside)
        toolBarView.addSubview(toolBarPreviewButton)
        
        
        
        toolBarView.translatesAutoresizingMaskIntoConstraints = false;
        toolBarView.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        toolBarView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        toolBarView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        if #available(iOS 11, *) {
            toolBarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        }else{
            toolBarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        }
        
        toolBarViewBackground.translatesAutoresizingMaskIntoConstraints = false;
        toolBarViewBackground.topAnchor.constraint(equalTo: toolBarView.topAnchor, constant: 0).isActive = true
        toolBarViewBackground.leftAnchor.constraint(equalTo: toolBarView.leftAnchor, constant: 0).isActive = true
        toolBarViewBackground.rightAnchor.constraint(equalTo: toolBarView.rightAnchor, constant: 0).isActive = true
        toolBarViewBackground.bottomAnchor.constraint(equalTo: toolBarView.bottomAnchor, constant: 40).isActive = true
        
        toolBarDoneButton.translatesAutoresizingMaskIntoConstraints = false;
        toolBarDoneButton.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor, constant: 0).isActive = true
        toolBarDoneButton.rightAnchor.constraint(equalTo: toolBarView.rightAnchor, constant: -15).isActive = true
        toolBarDoneButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        toolBarDoneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        toolBarPreviewButton.translatesAutoresizingMaskIntoConstraints = false;
        toolBarPreviewButton.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor, constant: 0).isActive = true
        toolBarPreviewButton.leftAnchor.constraint(equalTo: toolBarView.leftAnchor, constant: 15).isActive = true
        toolBarPreviewButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        toolBarPreviewButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        updateToolBarDoneButton()
    }
    
    func setupAssetsViewUI() {
        assetsCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout5)
        assetsCollection.register(WTSimbaImageItemCollectionCell.self, forCellWithReuseIdentifier: cellIdentifier)
        assetsCollection.backgroundColor = UIColor.clear
        assetsCollection.delegate = self
        assetsCollection.dataSource = self
        assetsCollection.scrollsToTop = false
        
        self.view.addSubview(assetsCollection)
        
        assetsCollection.translatesAutoresizingMaskIntoConstraints = false;
        assetsCollection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        assetsCollection.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        assetsCollection.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        assetsCollection.bottomAnchor.constraint(equalTo: toolBarView.topAnchor, constant: 0).isActive = true
    }
    
    func setupAlbumListViewUI() {
        self.view.addSubview(albumListView)
        albumListView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        albumListView.addTarget(self, action: #selector(albumListViewnPressed(sender:)), for: .touchDown)
        
        albumListView.translatesAutoresizingMaskIntoConstraints = false;
        albumListView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        albumListView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        
        albumListViewTopAnchorShow = albumListView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        albumListViewBottomAnchorShow = albumListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        
        albumListViewHeightAnchorHidden = albumListView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1)
        albumListViewBottomAnchorHidden = albumListView.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        
        
        albumListView.addSubview(albumListTable)
        albumListTable.delegate = self
        albumListTable.dataSource = self
        albumListTable.backgroundColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1.00)
        albumListTable.separatorColor = UIColor(red:0.22, green:0.22, blue:0.22, alpha:1.00)
        albumListTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        albumListTable.translatesAutoresizingMaskIntoConstraints = false;
        albumListTable.topAnchor.constraint(equalTo: albumListView.topAnchor, constant: 0).isActive = true
        albumListTable.leftAnchor.constraint(equalTo: albumListView.leftAnchor, constant: 0).isActive = true
        albumListTable.rightAnchor.constraint(equalTo: albumListView.rightAnchor, constant: 0).isActive = true
        albumListTable.bottomAnchor.constraint(equalTo: albumListView.bottomAnchor, constant: -120).isActive = true
    }
    
    func showAlbumListView(_ show: Bool, animated: Bool = true) {
        if show {
            albumListViewHeightAnchorHidden.isActive = !show
            albumListViewBottomAnchorHidden.isActive = !show
            albumListViewTopAnchorShow.isActive = show
            albumListViewBottomAnchorShow.isActive = show
        }else{
            albumListViewTopAnchorShow.isActive = show
            albumListViewBottomAnchorShow.isActive = show
            albumListViewHeightAnchorHidden.isActive = !show
            albumListViewBottomAnchorHidden.isActive = !show
        }
        
        if animated {
            albumListView.isHidden = false
            var rect = albumListView.frame
            if show {
                rect.origin.y = 0
            }else{
                rect.origin.y = 0 - self.view.frame.size.height
            }
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                self.albumListView.frame = rect
                if show {
                    self.titleIcon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                }else{
                    self.titleIcon.transform = CGAffineTransform(rotationAngle: CGFloat(2 * Double.pi))
                }
            }) { (end) in
                self.albumListView.isHidden = !show
                if show == false {
                    self.titleIcon.transform = CGAffineTransform(rotationAngle: CGFloat(0))
                }
            }
        }else {
            albumListView.isHidden = !show
            if show {
                titleIcon.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }else{
                titleIcon.transform = CGAffineTransform(rotationAngle: CGFloat(0))
            }
        }
    }
    
    @objc private func loadDataFirst() {
        //检查权限
        let status = WTSimbaImageAssistant.authorizationStatusRequestIfNotDetermined { (s) in
            self.loadDataView(for: s)
        }
        loadDataView(for: status)
    }
    
    private func loadDataView(for status:PHAuthorizationStatus) {
        DispatchQueue.main.async(execute: {
            
            if status == .authorized {
                
                self.reloadAlbum()
                
                self.navigationTitleView.isHidden = false
                self.assetsCollection.isHidden = false
                self.limitView.isHidden = true
                
                self.reloadAssetsList()
                
            }else if status == .restricted || status == .denied {
                
                self.navigationTitleView.isHidden = true
                self.assetsCollection.isHidden = true
                self.limitView.isHidden = false
                
                if status == .restricted {
                    //受限制
                }else{
                    //拒绝
                }
            }
        })
    }
    
    
    private func reloadAlbum() {
        viewMode.collections.removeAll()
        viewMode.currentIndex = 0
        let collectionsRead = WTSimbaImageAssistant.collections(ignoreEmpty: configuration.ignoreEmptyAlbum, mediaType: configuration.mediaType)
        viewMode.collections.append(contentsOf: collectionsRead)
        
        albumListTable.reloadData()
    }
    
    @objc private func reloadAssetsList() {
        viewMode.currentAssets.removeAll()
        if viewMode.currentIndex < viewMode.collections.count {
            let collection = viewMode.collections[viewMode.currentIndex]
            let title = collection.localizedTitle ?? ""
            titleLabel.text = title
            
            let assets = WTSimbaImageAssistant.assets(from: collection, mediaType: configuration.mediaType)
            viewMode.currentAssets.append(contentsOf: assets)
        }
        
        assetsCollection.reloadData()
//        var offsetY = assetsCollection.contentSize.height - assetsCollection.bounds.size.height
//        if offsetY < 0 {
//            offsetY = 0
//        }
        let itemCount = viewMode.currentAssets.count
        if viewMode.currentAssets.count > 0 {
            let indexPath = IndexPath(item: (itemCount - 1), section: 0)
            assetsCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: false)
        }
    }
    
    
    @objc private func updateToolBarDoneButton() {
        if self.viewMode.selectedAssets.count > 0 {
            let title = "  \(WTSimbaImagePickerUtils.localizedString(self, key:"done"))(\(self.viewMode.selectedAssets.count))  "
            toolBarDoneButton.isEnabled = true
            toolBarDoneButton.setTitle(title, for: .normal)
            
            toolBarPreviewButton.isEnabled = true
        }else {
            toolBarDoneButton.isEnabled = false
            toolBarDoneButton.setTitle(WTSimbaImagePickerUtils.localizedString(self, key:"done"), for: .normal)
            
            toolBarPreviewButton.isEnabled = false
        }
    }
    
    @objc private func cancelButtonPressed(sender: UIButton) {
        let delegate = imagePicker?.pickerDelegate
        var cancelSelf = true
        if delegate != nil {
            if delegate!.responds(to: #selector(WTSimbaImagePickerControllerDelegate.simbaImagePickerControllerCancel(picker:))) {
                imagePicker?.pickerDelegate!.simbaImagePickerControllerCancel?(picker: imagePicker)
                cancelSelf = false
            }
        }
        if cancelSelf {
            imagePicker?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func titleButtonPressed(sender: UIButton) {
        let isHidden = albumListView.isHidden
        showAlbumListView(isHidden)
    }
    
    @objc private func albumListViewnPressed(sender: AnyObject) {
        showAlbumListView(false)
    }
    
    @objc private func limitButtonPressed(sender: AnyObject) {
        var url = URL(string: "prefs:root=Privacy&path=LOCATION")
        if #available(iOS 10, *) {
            url = URL(string: UIApplication.openSettingsURLString)
        }
        if url != nil {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }else{
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    @objc private func toolBarDoneButtonPressed(sender: AnyObject) {
        if self.viewMode.selectedAssets.count >= configuration.selectNumberMin {
            
            let delegate = imagePicker?.pickerDelegate
            var cancelSelf = true
            if delegate != nil {
                if delegate!.responds(to: #selector(WTSimbaImagePickerControllerDelegate.simbaImagePickerControllerDidFinish(picker:images:editedImages:))) {
                    imagePicker?.pickerDelegate!.simbaImagePickerControllerDidFinish?(picker: imagePicker, images: self.viewMode.selectedAssets, editedImages:self.viewMode.editedAssets)
                    cancelSelf = false
                }
            }
            if cancelSelf {
                imagePicker?.dismiss(animated: true, completion: nil)
            }
        }else{
            let message = String(format: WTSimbaImagePickerUtils.localizedString(self, key:"Select at least %ld pictures"), configuration.selectNumberMin)
            showMessage(message: message)
        }
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: WTSimbaImagePickerUtils.localizedString(self, key:"I Know") , style: UIAlertAction.Style.cancel) { (action) in
            
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}

extension WTSimbaImagePickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewMode.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UITableViewCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? WTSimbaImagePickerAlbumTableCell
        if cell == nil {
            cell = WTSimbaImagePickerAlbumTableCell(style: .default, reuseIdentifier: cellIdentifier)
        }
        
        let collection = viewMode.collections[indexPath.row]
        let assets = WTSimbaImageAssistant.assets(from: collection, mediaType: configuration.mediaType)
        
        cell!.titleLabel.text = "\(collection.localizedTitle ?? "") (\(assets.count))"
        cell!.titleLabel.textColor = UIColor.white
        
        cell!.iconView.image = UIImage(named: "Frameworks/WTSimbaImagePickerSwift.framework/WTSimbaImagePickerSwift.bundle/icon_picker_imageholder")
        let asset = assets.first
        
        
        if asset != nil {
            
            let width = CGFloat(56)
            let scale = UIScreen.main.scale
            let widthFinal = width * scale
            
            WTSimbaImageAssistant.image(asset: asset!, resultHandler: { (img) in
                if img != nil {
                    cell!.iconView.image = img
                }
            }, sizeMode: .thumbnail, thumbnailSize: CGSize(width: widthFinal, height: widthFinal))
        }
        
        cell?.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        cell?.selectedBackgroundView = UIView()
        cell?.selectedBackgroundView?.backgroundColor = UIColor(red:0.09, green:0.09, blue:0.09, alpha:1.00)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewMode.currentIndex = indexPath.row
        
        showAlbumListView(false)
        reloadAssetsList()
    }
    
    
}

extension WTSimbaImagePickerViewController:UICollectionViewDelegate, UICollectionViewDataSource, WTSimbaImageItemCollectionCellDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewMode.currentAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WTSimbaImageItemCollectionCell
        cell.delegate = self
        
        let asset = viewMode.currentAssets[indexPath.item]
        cell.loadImage(asset: asset)
        
        if self.viewMode.selectedAssets.contains(asset) {
            let index =  (self.viewMode.selectedAssets.firstIndex(of: asset) ?? 0) + 1
            cell.updateSelect(true, index: index, animated: false)
        }else{
            cell.updateSelect(false, index: 0, animated: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if configuration.previewEnable == false {
            let cell = collectionView.cellForItem(at: indexPath) as? WTSimbaImageItemCollectionCell
            collectionCellSelectButtonPressed(cell: cell, indexPath: indexPath)
        }else{
//            let asset = viewMode.currentAssets[indexPath.item]
        }
    }
    
    func collectionCellSelectButtonPressed(cell: WTSimbaImageItemCollectionCell?, indexPath: IndexPath? = nil) {
        
        var indexPathFinal: IndexPath? = nil
        if cell != nil {
            indexPathFinal = assetsCollection.indexPath(for: cell!)
        }
            
        if indexPathFinal != nil {
            let asset = viewMode.currentAssets[indexPathFinal!.item]
            
            if self.viewMode.selectedAssets.contains(asset) {
                let index =  self.viewMode.selectedAssets.firstIndex(of: asset)
                let notreload = (index == self.viewMode.selectedAssets.count - 1)
                if index != nil {
                    self.viewMode.selectedAssets.remove(at: index!)
                }
                if notreload {
                    cell?.updateSelect(false, index: 0)
                }else{
                    let indexs = assetsCollection.indexPathsForVisibleItems
                    if indexs.count > 0 {
                        assetsCollection.reloadItems(at: indexs)
                    }
                }
                updateToolBarDoneButton()
            }else{
                let count =  self.viewMode.selectedAssets.count
                if count < configuration.selectNumberMax {
                    self.viewMode.selectedAssets.append(asset)
                    let index = self.viewMode.selectedAssets.count
                    cell?.updateSelect(true, index: index)
                    updateToolBarDoneButton()
                    if count + 1 == configuration.selectNumberMax {
                        //已经到极限了
                    }
                }else{
                    let message = String(format: WTSimbaImagePickerUtils.localizedString(self, key:"Select a maximum of %ld pictures"), configuration.selectNumberMax)
                    showMessage(message: message)
                }
            }
            
        }
    }
    
}

