//
//  GZTMultiSelectViewController.swift
//  WorkSpace
//
//  Created by 生生 on 2018/3/2.
//  Copyright © 2018年 生生. All rights reserved.
//

import UIKit
import ObjectMapper

enum GZTMultiSelectType {
    case multiselect
    case radio
}

class GZTMultiSelectViewController: UIViewController {
    // 传入界面功能：1，multiselect：多选。2，selectCity：单选
    var type :GZTMultiSelectType = .multiselect
    
    var selectBlock: ((_ vc: UIViewController, _ departmentIds:Array<GZTModel>)->())?
    
    fileprivate var organizationCollectionViewHeight:CGFloat = SCREEN_HEIGHT - 137 * SCALE_HEIGHT - 64 - BOTTOM_SAFE_HEIGHT
    fileprivate var organizationViewControllerWidth = SCREEN_WIDTH / 3.0
    fileprivate var hasSelectOrganization:GZTModel?
    fileprivate var rawData: Array<GZTModel> = []
    
    // selectCollectionView: 展示目录结构
    fileprivate lazy var organizationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        let collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(GZTOrganizationCell.self, forCellWithReuseIdentifier: organizationCell)
        collectionView.bounces = true
        return collectionView
    }()
    // 目录层次
    fileprivate var organizationList: Array<Array<GZTModel>>? = []
    // 进行的节点保存
    fileprivate var organizationNode: [Int: GZTModel] = [:]

    // selectCollectionView: 呈现已经选择的数据
    fileprivate lazy var selectCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5 * SCALE_WIDTH
        layout.minimumLineSpacing = 5  * SCALE_WIDTH
        layout.sectionInset = UIEdgeInsetsMake(6 * SCALE_HEIGHT, 12 * SCALE_WIDTH, 6 * SCALE_HEIGHT, 12 * SCALE_WIDTH)
        let collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(GZTSelectCollectionCell.self, forCellWithReuseIdentifier: selectCollectionCell)
        return collectionView
    }()
    // multiselect状态下，已经选择的model数据链
    fileprivate var selectList: Array<Array<GZTModel>>? = []

    fileprivate lazy var  clearButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init()
        btn.setTitle("重置", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18 * SCALE_WIDTH)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 45 * SCALE_HEIGHT / 2.0
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = SCREEN_1_PX
        let action = #selector(clearButtonPressed(_:))
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }()

    fileprivate lazy var  confirmButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init()
        btn.setTitle("确定", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18 * SCALE_WIDTH)
        btn.setTitleColor(UIColor.gray, for: .normal)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 45 * SCALE_HEIGHT / 2.0
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.layer.borderWidth = SCREEN_1_PX
        let action = #selector(confirmButtonPressed(_:))
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.edgesForExtendedLayout = UIRectEdge()
        self.automaticallyAdjustsScrollViewInsets = false
        self.leftButton()
        self.setupUI()
        self.getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("GZTSelectOrganizationViewController 释放")
    }
    // MARK: private
    
    fileprivate func getData() {
        let jsonPath = Bundle.main.path(forResource: "testData", ofType: "txt")
        let data = NSDictionary.init(contentsOfFile: jsonPath!)
        let deptList = data?["deptList"] as? Array<Dictionary<String, Any>>
        self.rawData = Mapper<GZTModel>().mapArray(JSONArray: deptList!)
        self.initData()
        self.organizationCollectionViewReloadData()
        self.selectCollectionViewReloadData()
    }
    
    // 初始化： organizationList
    fileprivate func initData() {
        self.organizationList?.removeAll()
        if self.rawData.count == 1 {
            let model = self.rawData.last
            self.hasSelectOrganization = model
            self.organizationNode[0] = model
            self.addObjc(0, model!)
            self.organizationList?.append(self.rawData)
            self.organizationList?.append((model?.children)!)
        } else {
            self.organizationList?.append(self.rawData)
        }
    }

    fileprivate func selectOrganization(_ indexPath: IndexPath, _ model: GZTModel) {
        
        //刷新当前级别和下一级
        if (self.organizationList?.count)! - 1 <= indexPath.row {
            if model.children?.count != 0 {
                self.organizationList?.append(model.children!)
            }
        } else {
            let range = NSRange.init(location: indexPath.row + 1, length: (self.organizationList?.count)! - 1 - indexPath.row)
            self.organizationList?.removeSubrange(Range.init(range)!)
            if model.children?.count != 0 {
                self.organizationList?.append(model.children!)
            }
        }
        
        if self.type == .multiselect {
            // 处理父级状态
            if indexPath.row > 0 && (self.organizationList?.count)! > 1{
                let superModel = self.organizationNode[indexPath.row - 1]
                superModel?.selectNum = 0
                superModel?.hasSelect = true
                //刷新上级
                for childrenModel in (superModel?.children)! {
                    if childrenModel.hasSelect || childrenModel.selectNum > 0 {
                        superModel?.selectNum = (superModel?.selectNum)! + 1
                    }
                }
            }
        } else {
            if self.hasSelectOrganization != nil {
                self.hasSelectOrganization?.hasSelect = false
            }
            model.hasSelect = true
            self.hasSelectOrganization = model
        }
        self.organizationCollectionViewReloadData()
    }
    
    // 添加并去重
    fileprivate func addObjc(_ row: Int, _ model: GZTModel) {
        if self.type == .radio {
            return
        }

        if model.hasSelect || model.selectNum > 0 {
            return
        }
        model.hasSelect = true
        
        if row == 0 {
            if self.selectList?.count == 0 {
                let array = [model]
                self.selectList?.append(array)
                self.selectCollectionViewReloadData()
            }
        } else {
            let superModel = self.organizationNode[row - 1]
            
            //已存在的数据链
            for (index, var array) in (self.selectList?.enumerated())! {
                let lastModel = array.last
                if lastModel?.id == superModel?.id {
                    array.append(model)
                    self.selectList![index] = array
                    self.selectCollectionViewReloadData()
                    return
                }
            }
            
            //新增数据链
            var newArray: Array<GZTModel> = []
            for array in self.selectList! {
                newArray.removeAll()
                for tempModel in array {
                    newArray.append(tempModel)
                    if superModel?.id == tempModel.id {
                        break
                    }
                }
            }
            
            newArray.append(model)
            self.selectList?.append(newArray)
            self.selectCollectionViewReloadData()
        }

    }

    fileprivate func clearSelectList(_ row:Int) {
        
        let array = self.selectList![row]
        for (index, model) in array.reversed().enumerated() {
            model.hasSelect = false
            if index == 0 {
                model.selectNum = 0
            } else {
                model.selectNum = 0
                for tempModel in model.children! {
                    if tempModel.hasSelect || tempModel.selectNum != 0 {
                        model.selectNum = model.selectNum + 1
                    }
                }
            }
        }
        self.selectList?.remove(at: row)
        
        //目录结构发生变化: 为了减少组织架构层级
        let newArray = self.organizationList?.reversed().filter({ (array) -> Bool in
            var num = 0
            for tempModel in array {
                if tempModel.hasSelect || tempModel.selectNum != 0 {
                    num = num + 1
                }
            }
            if num == 0 {
                return false
            } else {
                return true
            }
        })
        
        if newArray?.count == 0 {
            self.initData()
        } else {
            self.organizationList = newArray?.reversed()
        }
    }
    
    // MARK: reloadData

    fileprivate func selectCollectionViewReloadData() {
        self.selectCollectionView.reloadData()
        if (self.selectList?.count)! == 0 {
            return
        }
        let scrollIndex = IndexPath.init(row: (self.selectList?.count)! - 1, section: 0)
        self.selectCollectionView.scrollToItem(at: scrollIndex, at: .right, animated: true)
    }
    
    fileprivate func organizationCollectionViewReloadData() {
        if self.organizationList?.count == 1 {
            self.organizationViewControllerWidth = SCREEN_WIDTH
        } else if organizationList?.count == 2 {
            self.organizationViewControllerWidth = SCREEN_WIDTH / 2.0
        } else {
            self.organizationViewControllerWidth = SCREEN_WIDTH / 3.0
        }
        
        self.organizationCollectionView.reloadData()
        if (self.organizationList?.count)! == 0 {
            return
        }
        
        let scrollIndex = IndexPath.init(row: (self.organizationList?.count)! - 1, section: 0)
        self.organizationCollectionView.scrollToItem(at: scrollIndex, at: .right, animated: true)
    }

    // MARK: response
    
    @objc fileprivate func clearButtonPressed(_ button : UIButton) {
        if (self.selectList?.count)! > 0 {
            let count:Int = self.selectList!.count - 1
            for _ in 0...count {
                // 每次都删除最后一项
                self.clearSelectList(self.selectList!.count - 1)
            }
            self.organizationCollectionViewReloadData()
            self.selectCollectionViewReloadData()
        }
    }
    
    @objc fileprivate func confirmButtonPressed(_ button : UIButton) {
        if self.type == .multiselect {
            var departments: Array<GZTModel> = []
            for array in (self.selectList)! {
                let lastModel = array.last
                departments.append(lastModel!)
            }
            
            if self.selectBlock != nil {
                self.selectBlock!(self, departments)
            }
            
        } else if self.type == .radio {
            if self.selectBlock != nil {
                self.selectBlock!(self, [self.hasSelectOrganization!])
            }
        }
    }

    @objc fileprivate func leftButtonPressed(_ button : UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    // MARK:UI
    
    fileprivate func leftButton() {
        let btn = UIButton.init()
        btn.setImage(UIImage(named: "nav_btn_back"), for: UIControlState())
        let action = #selector(leftButtonPressed(_:))
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.frame.size = CGSize.init(width: btn.frame.size.width + 20 * SCALE_WIDTH, height: 44)
        let barItem = UIBarButtonItem(customView: btn)
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target:nil, action: nil)
        navigationItem.leftBarButtonItems = [spaceItem,barItem]
    }
    
    fileprivate func setupUI() {
        switch self.type {
            case .multiselect:
                self.navigationItem.title = "多选"
                self.organizationCollectionViewHeight = SCREEN_HEIGHT - 137 * SCALE_HEIGHT - 64 - BOTTOM_SAFE_HEIGHT
                break
            case .radio:
                self.navigationItem.title = "单选"
                self.organizationCollectionViewHeight = SCREEN_HEIGHT - 93 * SCALE_HEIGHT - 64 - BOTTOM_SAFE_HEIGHT
                break
        }
        self.setupVectoringCollectionView()
        self.setupSelectCollectionView()
        self.setupButton()
    }

    fileprivate func setupVectoringCollectionView() {
        organizationCollectionView.delegate = self
        organizationCollectionView.dataSource = self
        view.addSubview(organizationCollectionView)
        organizationCollectionView.snp.makeConstraints {  (make) in
            make.top.left.right.equalTo(0)
            make.height.equalTo(organizationCollectionViewHeight)
        }
        
        let line = UIView.init()
        line.backgroundColor = UIColor.gray
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(SCREEN_1_PX)
            make.bottom.equalTo(organizationCollectionView.snp.bottom)
        }
    }
    
    fileprivate func setupSelectCollectionView() {
        if self.type == .radio {
            return
        }
        
        selectCollectionView.delegate = self
        selectCollectionView.dataSource = self
        view.addSubview(selectCollectionView)
        selectCollectionView.snp.makeConstraints {  [weak self]  (make) in
            make.top.equalTo((self?.organizationCollectionView.snp.bottom)!)
            make.left.right.equalTo(0)
            make.height.equalTo(44 * SCALE_HEIGHT)
        }
        
        let line0 = UIView.init()
        line0.backgroundColor = UIColor.gray
        view.addSubview(line0)
        line0.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(SCREEN_1_PX)
            make.bottom.equalTo(selectCollectionView.snp.bottom).offset(-SCREEN_1_PX)
        }
    }
    
    fileprivate func setupButton() {
        switch self.type {
        case .multiselect:
            view.addSubview(clearButton)
            clearButton.snp.makeConstraints { (make) in
                make.left.equalTo(18 * SCALE_WIDTH)
                make.width.equalTo(155 * SCALE_WIDTH)
                make.height.equalTo(45 * SCALE_HEIGHT)
                make.bottom.equalTo(-30 * SCALE_HEIGHT)
            }
            
            view.addSubview(confirmButton)
            confirmButton.snp.makeConstraints { (make) in
                make.right.equalTo(-18 * SCALE_WIDTH)
                make.width.equalTo(155 * SCALE_WIDTH)
                make.height.equalTo(45 * SCALE_HEIGHT)
                make.bottom.equalTo(-30 * SCALE_HEIGHT)
            }
            break
        case .radio:
            view.addSubview(confirmButton)
            confirmButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view.snp.centerX)
                make.width.equalTo(300 * SCALE_WIDTH)
                make.height.equalTo(45 * SCALE_HEIGHT)
                make.bottom.equalTo(-30 * SCALE_HEIGHT)
            }
            break
        }
    }
}

extension GZTMultiSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.organizationCollectionView == collectionView {
            return self.organizationList!.count
        } else {
            return self.selectList!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.organizationCollectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: organizationCell, for: indexPath) as! GZTOrganizationCell
            
            cell.isLastCell = (self.organizationList?.count == indexPath.row + 1) && (indexPath.row > 1) ? true : false
            cell.listArray = self.organizationList![indexPath.row]
            
            cell.selectBlock = { [weak self] model in
                self?.organizationNode[indexPath.row] = model
                self?.addObjc(indexPath.row, model)
                self?.selectOrganization(indexPath, model)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectCollectionCell, for: indexPath) as! GZTSelectCollectionCell
            let array = self.selectList![indexPath.row]
            cell.model = array.last
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.organizationCollectionView == collectionView {
            return CGSize.init(width: organizationViewControllerWidth, height: organizationCollectionViewHeight)
        } else {
            let array = self.selectList![indexPath.row]
            let model = array.last
            let width = model?.name.getTexWidth(font: UIFont.systemFont(ofSize: 14 * SCALE_HEIGHT), height: 15 * SCALE_HEIGHT)
            return CGSize.init(width: width! + 50 * SCALE_WIDTH, height: 32 * SCALE_HEIGHT)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectCollectionView == collectionView {
            // 删除节点
            self.clearSelectList(indexPath.row)
            self.organizationCollectionViewReloadData()
            self.selectCollectionViewReloadData()
        }
    }
}
