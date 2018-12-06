//
//  LightButton.swift
//  ARMultiuser
//
//  Created by Evan Delvaux on 12/6/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import SceneKit

@IBDesignable
class LightButton: SCNNode {
    var color_i: Int
    override init(color color_i: Int) {
        self.color_i = color_i
    }
}
