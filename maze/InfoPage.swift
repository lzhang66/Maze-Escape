//
//  InfoPage.swift
//  Amazed
//
//  Created by Li Zhang on 8/11/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit

class InfoPage: SKScene {
    var buttonMain: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        buttonMain = childNodeWithName("buttonMian") as! MSButtonNode
        buttonMain.selectedHandler = {
            let skView = self.view as SKView!
            let scene = Main(fileNamed:"Main") as Main!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
        }
    }
}