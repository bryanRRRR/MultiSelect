//
//  GZTBaseConst.swift
//  WorkSpace
//
//  Created by 生生 on 2017/8/10.
//  Copyright © 2017年 生生. All rights reserved.
//

import UIKit

// MARK: 屏幕尺寸相关
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN = UIScreen.main.bounds
let IS_IPHONE_X = UIDevice.isX()
let SCALE_HEIGHT = IS_IPHONE_X ? SCALE_WIDTH : SCREEN_HEIGHT / 667.0
let SCALE_WIDTH = SCREEN_WIDTH / 375.0
let SCREEN_1_PX = 1.0 / UIScreen.main.scale
//适配X
let TABBAR_HEIGHT: CGFloat = UIDevice.isX() ? 83 : 49
let BOTTOM_SAFE_HEIGHT: CGFloat = UIDevice.isX() ? 34 : 0
extension UIDevice {
    static func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 && UIScreen.main.bounds.width == 375  {
            return true
        }
        
        return false
    }
}


