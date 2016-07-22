//
//  main.swift
//  maze
//
//  Created by Li Zhang on 7/20/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit

class Main: SKScene {
    var play: MSButtonNode!
    var select: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        play = self.childNodeWithName("play") as! MSButtonNode
        play.selectedHandler = {
            let skView = self.view as SKView!
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)}
        select = self.childNodeWithName("select") as! MSButtonNode
        select.selectedHandler = {
            let skView = self.view as SKView!
            let scene = Select(fileNamed:"Select") as Select!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)}
        
        }
}