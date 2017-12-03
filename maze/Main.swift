//
//  main.swift
//  maze
//
//  Created by Li Zhang on 7/20/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit

let learner = GKAchievement(identifier: "1")
let die1 = GKAchievement(identifier: "2")
let die10 = GKAchievement(identifier: "4")
let level4 = GKAchievement(identifier: "5")
let level5 = GKAchievement(identifier: "3")
let die30 = GKAchievement(identifier: "6")
let level10 = GKAchievement(identifier: "7")
let killer = GKAchievement(identifier: "8")

class Main: SKScene {
    var play: MSButtonNode!
    var select: MSButtonNode!
    var buttonHint: MSButtonNode!
    var info: MSButtonNode!
    var labelHint: SKLabelNode!
    var hints = ["You can see your current fastest escape record in the level selection menu.", "The normal teleporter sends you to one sepecific location in the maze, repersented by a circle.", "The random teleporter sends you to any random location in the maze, even on a trap!", "Teleporters are triggered only when you are close enough to it's center.", "Sometimes you don't need a key to escape.", "Collect certain number of yellow triangular pieces to summon the key somewhere.", "The label in the bottom-left shows the number of pieces you have and the number required.", "You can tap the bottom-left label to see the location of objects you need every a few seconds."]
    var index = -1 {didSet{labelHint.removeActionForKey("a")
        labelHint.text = hints[index]
        labelHint.runAction(SKAction.sequence([SKAction.fadeInWithDuration(1), SKAction.waitForDuration(15), SKAction.fadeOutWithDuration(1)]), withKey: "a")}}
    
    override func didMoveToView(view: SKView) {
        info = childNodeWithName("info") as! MSButtonNode
        info.selectedHandler = {
            let skView = self.view as SKView!
            let scene = InfoPage(fileNamed:"InfoPage") as InfoPage!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
        }
        learner.showsCompletionBanner = true
        die1.showsCompletionBanner = true
        die10.showsCompletionBanner = true
        die30.showsCompletionBanner = true
        level4.showsCompletionBanner = true
        level5.showsCompletionBanner = true
        level10.showsCompletionBanner = true
        killer.showsCompletionBanner = true
        if data.arrayForKey("records")?[0] == nil {
            data.setValue(["","","","","","","","","",""], forKey: "records")}
        if data.arrayForKey("NMrecords")?[0] == nil {
            data.setValue(["","","","","","","","","",""], forKey: "NMrecords")}
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
        self.view!.showsPhysics = false
        self.view!.showsFPS = false
        self.view!.showsNodeCount = false
        self.view!.showsFields = false
        }
}