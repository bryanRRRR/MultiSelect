//
//  ViewController.swift
//  multiSelect(Organization)Demo
//
//  Created by 生生 on 2018/3/9.
//  Copyright © 2018年 生生. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var radioTextFile: UITextField =  {
        let textFile = UITextField.init()
        textFile.placeholder = "  请选择的组织(单选)"
        textFile.font = UIFont.systemFont(ofSize: 14)
        textFile.backgroundColor = UIColor.white
        textFile.delegate = self
        textFile.layer.masksToBounds = true
        textFile.layer.cornerRadius = 10
        textFile.layer.borderColor = UIColor.lightGray.cgColor
        textFile.layer.borderWidth = 2 / UIScreen.main.scale
        return textFile
    }()
    
    lazy var multiselectTextFile: UITextField =  {
        let textFile = UITextField.init()
        textFile.placeholder = "  请选择的组织(多选)"
        textFile.font = UIFont.systemFont(ofSize: 14)
        textFile.backgroundColor = UIColor.white
        textFile.delegate = self
        textFile.layer.masksToBounds = true
        textFile.layer.cornerRadius = 10
        textFile.layer.borderColor = UIColor.lightGray.cgColor
        textFile.layer.borderWidth = 2 / UIScreen.main.scale
        return textFile
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(radioTextFile)
        radioTextFile.snp.makeConstraints { [weak self] (make) in
            make.top.equalTo(200)
            make.centerX.equalTo((self?.view.snp.centerX)!)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
        
        self.view.addSubview(multiselectTextFile)
        multiselectTextFile.snp.makeConstraints { [weak self]  (make) in
            make.top.equalTo(260)
            make.centerX.equalTo((self?.radioTextFile.snp.centerX)!)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if self.multiselectTextFile == textField {
            // 多选
            let vc = GZTMultiSelectViewController()
            let navi = GZTNavigationViewController.init(rootViewController: vc)
            self.present(navi, animated: true) {}
            vc.selectBlock = { VC, departmentIds in
                VC.dismiss(animated: true, completion: {})
                textField.text = "  多选（\(departmentIds.count)）"
            }
        } else {
            // 单选
            let vc = GZTMultiSelectViewController()
            vc.type = .radio
            let navi = GZTNavigationViewController.init(rootViewController: vc)
            self.present(navi, animated: true) {}
            vc.selectBlock = { VC, departmentIds in
                VC.dismiss(animated: true, completion: {})
                textField.text = "  单选（\(departmentIds.count)）"
            }
        }
        
    }
}


