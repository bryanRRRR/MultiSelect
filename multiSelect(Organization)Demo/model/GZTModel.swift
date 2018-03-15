//
//  GZTModel.swift
//  WorkSpace
//
//  Created by 生生 on 2018/3/5.
//  Copyright © 2018年 生生. All rights reserved.
//

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
