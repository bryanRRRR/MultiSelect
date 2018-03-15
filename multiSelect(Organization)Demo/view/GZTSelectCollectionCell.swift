//
//  GZTSelectCollectionCell.swift
//  WorkSpace
//
//  Created by 生生 on 2018/3/2.
//  Copyright © 2018年 生生. All rights reserved.
//

import UIKit

let selectCollectionCell = "GZTSelectCollectionCell"
class GZTSelectCollectionCell: UICollectionViewCell {
    var model: GZTModel? {
        didSet{
            titleLab.text = model?.name
        }
    }
    
    var titleLab:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14 * SCALE_HEIGHT)
        label.textColor = UIColor.blue
        label.text = "波顿共和国"
        label.textAlignment = .left
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    var nextImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "universal_delete")
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.borderWidth = SCREEN_1_PX
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 5 * SCALE_WIDTH
        
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(10 * SCALE_WIDTH)
            make.top.bottom.equalTo(0)
            make.right.equalTo(-30 * SCALE_WIDTH)
        }
        
        self.addSubview(nextImageView)
        nextImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLab.snp.right).offset(1 * SCALE_WIDTH)
            make.centerY.equalTo(self.titleLab.snp.centerY)
            make.width.height.equalTo(19 * SCALE_WIDTH)
        }
    }
}

