//
//  WTSimbaImagePickerAlbumTableCell.swift
//  WTSimbaImagePickerDemo
//
//  Created by smalltalk on 24/3/2020.
//  Copyright © 2020 sfs. All rights reserved.
//

import UIKit

class WTSimbaImagePickerAlbumTableCell: UITableViewCell {

    let iconView = UIImageView()
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(iconView)
        self.contentView.addSubview(titleLabel)
        
        iconView.backgroundColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
        titleLabel.textColor = UIColor.white
        
        iconView.translatesAutoresizingMaskIntoConstraints = false;
        iconView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        iconView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        iconView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.contentView.rightAnchor, constant: -15).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
