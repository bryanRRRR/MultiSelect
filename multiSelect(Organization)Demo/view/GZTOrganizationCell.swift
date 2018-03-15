//
//  GZTOrganizationCell.swift
//  WorkSpace
//
//  Created by 生生 on 2018/3/2.
//  Copyright © 2018年 生生. All rights reserved.
//

import UIKit
import SnapKit

let organizationCell = "GZTOrganizationCell"
class GZTOrganizationCell: UICollectionViewCell {
    var selectBlock: ((GZTModel)->())?

    var listArray: Array<GZTModel> = [] {
        didSet{
            self.tableView.reloadData()
        }
    }
    var isLastCell: Bool = false {
        didSet{
            self.line.isHidden = isLastCell
        }
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.scrollIndicatorInsets = tableView.contentInset
        tableView.register(GZTOrganizationItemCell.self, forCellReuseIdentifier: organizationItemCell)
        tableView.rowHeight = 40
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    fileprivate lazy var line: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.gray
        return line
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear

        self.setupTableView()
        
        self.contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.right.equalTo(0).offset(-SCREEN_1_PX)
            make.bottom.top.equalTo(0)
            make.width.equalTo(SCREEN_1_PX)
        }
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
    }

}

extension GZTOrganizationCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: organizationItemCell, for: indexPath) as! GZTOrganizationItemCell
        cell.model = self.listArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectBlock != nil {
            let model = self.listArray[indexPath.row]
            self.selectBlock!(model)
        }
    }
}


