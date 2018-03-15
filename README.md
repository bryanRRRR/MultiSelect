# MultiSelect
ps：下载完代码，先pod install一下

最近在做项目，需要弄一个多层级多选（层级数量不定）的联动选择功能，本来想在github或者cocoachina找一下基本样例或者第三方库的，但是找到的都是限制层级的，一般为二层级、三层级，并不满足要求，于是自己抽时间写了一个，希望各位给出指点或意见。



1、实现思路
现在我实现的方式是上下两个UICollectionView。

a、 上面的UICollectionView(下面简称：organizationCollectionView)

 主要负责层级的展开、收起、选择。由于层级是不确定的，用UIScrollView的话，层级过多，也无释放，内存会可能过高，所以这里选中UICollectionView实现每个UICollectionViewCell内再嵌套一个UITableView,


b、 下面的UICollectionView(下面简称：selectCollectionView)，主要负责展现已经选中的层级，并且支持删除。



2、代码分析
a、多选简单使用

      let vc = GZTMultiSelectViewController()
      let navi = GZTNavigationViewController.init(rootViewController: vc)
      self.present(navi, animated: true) {}
      vc.selectBlock = { VC, departmentIds in
          VC.dismiss(animated: true, completion: {})
          textField.text = "  多选（\(departmentIds.count)）"
      }


b、 单选简单使用

      let vc = GZTMultiSelectViewController()
      vc.type = .radio
      let navi = GZTNavigationViewController.init(rootViewController: vc)
      self.present(navi, animated: true) {}
      vc.selectBlock = { VC, departmentIds in
          VC.dismiss(animated: true, completion: {})
          textField.text = "  单选（\(departmentIds.count)）"
      }




c、GZTModel，model的设计


import UIKit
import ObjectMapper

class GZTModel: Mappable {
    var id: String = ""
    var level: String = ""
    var name:String  = ""
    var children:Array<GZTModel>? = []
    var hasPermission:Int  = 0
    var status:Bool  = false

    var selectNum:Int = 0
    var hasSelect:Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        level <- map["level"]
        name <- map["name"]
        children <- map["children"]
    }
    
}


model设计
主要考虑是嵌套模型的model（model里面嵌套一个子model，但是两个model的数据格式是一样的，都是GZTModel）。为了解析这种类型数据，这里我引入了ObjectMapper，这个第三方库能有效帮我解析children这个数组，目前经测试，20个层次是没问题的。注意：记得导入ObjectMapper

d、organizationCollectionView和相关数据的初始化

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

organizationCollectionView主要注意边距、布局方向的设置，重点是organizationList（数组）、organizationNode（字典）
organizationList：主要用于存储后面organizationCollectionView每一个cell展开内部UITableView（后续简称tableView）的数据源
organizationNode：以当前的tableView的row作为键，存储和更新每次上述tableView中选择的model（每个cell对应的数据），用于后面寻找每一个被点击的model的父节点的model，刷新父节点名下被选中的个数。

e、selectOrganization()  主要实现的功能

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
主要是获取每次点击的model的children，即organizationCollectionView下一个cell展示的内容


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
在多选的情况下，主要是处理父节点的children中有几个别点击到的model，并记录

        if self.hasSelectOrganization != nil {
            self.hasSelectOrganization?.hasSelect = false
        }
        model.hasSelect = true
        self.hasSelectOrganization = model
单选的情况下，主要用于记录当前选中的数据model。

d、selectCollectionView和相关数据的初始化

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
    fileprivate var selectList: Array<Array<GZTModel>>? = []
 
 这里的主要需要注意selectList，这个数据是数组嵌套数组，外层主要代表被选择的个数；里面数据代表被选中的数据，从第一层数据到该数据的所有model。





