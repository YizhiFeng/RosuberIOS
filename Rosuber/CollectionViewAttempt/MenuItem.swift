//
//  MenuItem.swift
//  Rosuber
//
//  Created by FengYizhi on 2018/4/23.
//  Copyright © 2018年 FengYizhi. All rights reserved.
//

import Foundation

class MenuItem: NSObject {
    var title: String
    var image: String
    var action: (()->())
    
    init(title: String, image: String, action: @escaping ()->()) {
        self.title = title
        self.image = image
        self.action = action
    }
}
