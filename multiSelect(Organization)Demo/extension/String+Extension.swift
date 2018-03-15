//
//  String+Extension.swift
//  Vankeyi-Swift
//
//  Created by 生生 on 2017/7/31.
//  Copyright © 2017年 生生. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func getTexWidth(font:UIFont,height:CGFloat) -> CGFloat {
        let normalText: NSString = self as NSString
        let size = CGSize.init(width: 1000, height: height)
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: (dic as! [NSAttributedStringKey : Any]), context:nil).size
        return stringSize.width
    }
}
