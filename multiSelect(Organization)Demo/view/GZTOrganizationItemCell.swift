//
//  GZTOrganizationItemCell.swift
//  WorkSpace
//
//  Created by 生生 on 2018/3/2.
//  Copyright © 2018年 生生. All rights reserved.
//

import UIKit

let organizationItemCell = "GZTOrganizationItemCell"
class GZTOrganizationItemCell: UITableViewCell {
    
    var model: GZTModel? {
        didSet{
            titleLab.text = model?.name
            if model?.selectNum != 0 {
                self.selectNumLab.isHidden = false
                self.selectImageView.isHidden = true
                titleLab.textColor = UIColor.blue
                self.selectNumLab.text = String.init(format: "%d", (model?.selectNum)!)
            } else if (model?.hasSelect)! {
                self.selectNumLab.isHidden = true
                self.selectImageView.isHidden = false
                titleLab.textColor = UIColor.blue
                self.selectNumLab.text = ""
            } else {
                self.selectNumLab.isHidden = true
                self.selectImageView.isHidden = true
                titleLab.textColor = UIColor.gray
                self.selectNumLab.text = ""
            }
        }
    }
    
    var titleLab:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14 * SCALE_HEIGHT)
        label.textColor = UIColor.gray
        label.text = "波顿共和国"
        label.textAlignment = .left
        return label
    }()
    
    var selectNumLab:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10 * SCALE_HEIGHT)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.blue
        label.text = " "
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15 * SCALE_WIDTH / 2.0
        return label
    }()
    
    var selectImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "account_check")
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    lazy var line: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.gray
        return line
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(8 * SCALE_WIDTH)
            make.top.bottom.equalTo(0)
            make.right.equalTo(-25 * SCALE_WIDTH)
        }
        
        self.addSubview(selectNumLab)
        selectNumLab.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLab.snp.right).offset(1 * SCALE_WIDTH)
            make.centerY.equalTo(self.titleLab.snp.centerY)
            make.width.height.equalTo(15 * SCALE_WIDTH)
        }
        
        self.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLab.snp.right).offset(1 * SCALE_WIDTH)
            make.centerY.equalTo(self.titleLab.snp.centerY)
            make.width.equalTo(10 * SCALE_WIDTH)
            make.height.equalTo(7 * SCALE_WIDTH)
        }

        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(0)
            make.height.equalTo(SCREEN_1_PX)
        }
    }
    
}
