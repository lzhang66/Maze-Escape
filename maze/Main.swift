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
    var buttonHint: MSButtonNode!
    var labelHint: SKLabelNode!
    var hints = ["1/8: You can see your current fastest escape record in the level selection menu.", "2/8: The normal teleporter sends you to one sepecific location in the maze, repersented by a circle.", "3/8: The random teleporter sends you to any random location in the maze, even on a trap!", "4/8: Teleporters are triggered only when you are close enough to it's center.", "5/8: Sometimes you don't need a key to escape.", "6/8: Collect certain number of yellow triangular pieces to summon the key somewhere.", "7/8: The label in the bottom-left shows the number of pieces you have and the number required.", "8/8: You can tap the bottom-left label to see the location of objects you need every a few seconds."]
    var index = -1 {didSet{labelHint.removeActionForKey("a")
        labelHint.text = hints[index]
        labelHint.runAction(SKAction.sequence([SKAction.fadeInWithDuration(1), SKAction.waitForDuration(15), SKAction.fadeOutWithDuration(1)]), withKey: "a")}}
    
    override func didMoveToView(view: SKView) {
        numDeath = 0
        labelHint = childNodeWithName("labelHint") as! SKLabelNode
        buttonHint = childNodeWithName("hint") as! MSButtonNode
        buttonHint.selectedHandler = {self.index = Int(CGFloat.random(min: 0, max: 7.9999999))}
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