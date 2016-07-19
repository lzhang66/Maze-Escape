//
//  GameScene.swift
//  maze
//
//  Created by Li Zhang on 7/5/16.
//  Copyright (c) 2016 Li Zhang. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit
var currentLevel = 1
var label: SKLabelNode!
var tutorial: [String] = ["Swipe!", "Find the exit.", "Grab the key!", "Here is an hard one.", "Teleport!", "WHAT?!", "Not this way...", "Try this.", "Test your luck!", "Where is the key?", "Oops! Someone turned of the light...", "Nightmare Mode"]
var index = -1 {didSet {label.runAction(SKAction.fadeInWithDuration(3)); label.text = tutorial[index]; label.runAction(SKAction.sequence([SKAction.waitForDuration(6), SKAction.fadeOutWithDuration(3)]))}}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKNode!
    var cameraTarget: SKNode!
    var swipeRight: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeDown: UISwipeGestureRecognizer!
    var swipeUp: UISwipeGestureRecognizer!
    var levelNode: SKNode!
    var goal: SKNode!
    var key: SKNode!
    var door: SKNode!
    var sight: SKReferenceNode!
    var restartButton: MSButtonNode!
    var startNode: SKNode!
    var teleporters: [SKNode:CGPoint] = [:]
    
    var impulse: CGFloat = 100.0
    var resourcePath: String?
    var sightNum = 0 {didSet{sight.xScale *= 1.5; sight.yScale *= 1.5}}
    var numPieces = 0
    var requiredPieces = 0
    var playerSize = 139.0
    var w: CGFloat = 0
    var h: CGFloat = 0
    var location: CGPoint?
    
    override func didMoveToView(view: SKView) {
        player = childNodeWithName("player")
        sight = camera!.childNodeWithName("a") as! SKReferenceNode
        sight.hidden = true
        levelNode = childNodeWithName("level")
        restartButton = player.childNodeWithName("restartButton") as! MSButtonNode
        restartButton.selectedHandler = {self.reload()}
        restartButton.hidden = true
        label = camera?.childNodeWithName("label") as! SKLabelNode
        // Load level
        loadCurrentLevel()
        if requiredPieces > 0 {levelNode.childNodeWithName("//KEY")!.hidden = true}
        cameraTarget = player
        // Set the swipe gesture
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view?.addGestureRecognizer(swipeRight)
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeft)
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swiped))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUp)
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swiped))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDown)
        

        physicsWorld.contactDelegate = self
   //     self.view?.showsPhysics = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if currentLevel == 1 && index == 0 {index += 1}
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Camera follows player
        if let cameraTarget = cameraTarget {camera?.position = cameraTarget.position}
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        if contact.bodyA.node == nil || contact.bodyB.node == nil {
            return}
        // 24: trap
        if contact.bodyA.categoryBitMask == 24 || contact.bodyB.categoryBitMask == 24 {gameOver()}
        else if contact.bodyA.node == goal || contact.bodyB.node == goal {currentLevel += 1; reload()}
        // 4: key
        else if (contact.bodyA.categoryBitMask == 4 || contact.bodyB.categoryBitMask == 4) && levelNode.childNodeWithName("//KEY")?.hidden != true
        {if contact.bodyA.categoryBitMask == 4 {contact.bodyA.node!.removeFromParent()}
        else {contact.bodyB.node!.removeFromParent()}; door.removeFromParent()}
        // 16: torch
        else if contact.bodyA.categoryBitMask == 16 || contact.bodyB.categoryBitMask == 16 {
            sightNum += 1;
            if contact.bodyA.categoryBitMask == 16 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()} }
        // 32: piece
        else if contact.bodyA.categoryBitMask == 32 || contact.bodyB.categoryBitMask == 32 {
            numPieces += 1
            if contact.bodyA.categoryBitMask == 32 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()}
            if numPieces == requiredPieces {levelNode.childNodeWithName("//KEY")!.hidden = false}
        }
        // Body A is teleporter
        else if contact.bodyA.categoryBitMask == 18 {
            if teleporters[contact.bodyA.node!.parent!.parent!] == nil {
                w = (levelNode.childNodeWithName("//size")!.position.x)
                h = (levelNode.childNodeWithName("//size")!.position.y)
                location = CGPoint(x: CGFloat.random(min:-w, max: w), y: CGFloat.random(min:-h, max: h))
            }
            player.physicsBody = nil
            if let location = location {player.position = levelNode.convertPoint(location, toNode: self)}
            else {player.position = levelNode.convertPoint(teleporters[contact.bodyA.node!.parent!.parent!]!, toNode: self)}
            player.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(50))
            player.physicsBody!.dynamic = true
            player.physicsBody!.affectedByGravity = false
            player.physicsBody!.mass = 0.8
            player.physicsBody?.categoryBitMask = 1
            player.physicsBody!.collisionBitMask = 3
            player.physicsBody!.contactTestBitMask = 4294967295
        }
        else if contact.bodyB.categoryBitMask == 18 {
            player.physicsBody = nil
            if let location = location {player.position = levelNode.convertPoint(location, toNode: self)}
            else {player.position = levelNode.convertPoint(teleporters[contact.bodyB.node!.parent!.parent!]!, toNode: self)}
            player.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(50))
            player.physicsBody!.dynamic = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody!.mass = 0.8
            player.physicsBody?.categoryBitMask = 1
            player.physicsBody?.collisionBitMask = 3
            player.physicsBody!.contactTestBitMask = 4294967295}
        else if (contact.bodyA.node?.name == "Oops" || contact.bodyB.node?.name == "Oops") && index == 4 {
            index += 1}
        else if (contact.bodyA.node?.name == "Oops" || contact.bodyB.node?.name == "Oops") && index == 5 {
            index += 1}
    }
    // Actions to be done when swiped
    func gameOver(){
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.dynamic = false
        player.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1.0, duration: 0.50))
        restartButton.hidden = false}
    
    func swiped(sender: UISwipeGestureRecognizer) {
        switch sender {
        case swipeRight:
            player.physicsBody?.applyImpulse(CGVectorMake(impulse, 0))
        case swipeLeft:
            player.physicsBody?.applyImpulse(CGVectorMake(-impulse, 0))
        case swipeUp:
            player.physicsBody?.applyImpulse(CGVectorMake(0, impulse))
        case swipeDown:
            player.physicsBody?.applyImpulse(CGVectorMake(0, -impulse))
        default: break} }
    
    func loadCurrentLevel(){
        levelNode.removeAllChildren()
        teleporters.removeAll()
        switch currentLevel {
        case 1:
            resourcePath = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")
            index = 0
        case 2:
            resourcePath = NSBundle.mainBundle().pathForResource("level2", ofType: "sks")
            index = 2
        case 3:
            resourcePath = NSBundle.mainBundle().pathForResource("level3", ofType: "sks")
            index = 3
        case 4:
            resourcePath = NSBundle.mainBundle().pathForResource("level4", ofType: "sks")
            index = 4
        case 5:
            resourcePath = NSBundle.mainBundle().pathForResource("level5", ofType: "sks")
            index = 7
        case 6:
            resourcePath = NSBundle.mainBundle().pathForResource("level6", ofType: "sks")
            index = 8
        case 7:
            resourcePath = NSBundle.mainBundle().pathForResource("level7", ofType: "sks")
            index = 9
            requiredPieces = 3
        case 8:
            resourcePath = NSBundle.mainBundle().pathForResource("level8", ofType: "sks")
            requiredPieces = 3
        case 9:
            resourcePath = NSBundle.mainBundle().pathForResource("level9", ofType: "sks")
            index = 10
            sight.xScale *= 1.3; sight.yScale *= 1.3
            sight.hidden = false
        case 10:
            resourcePath = NSBundle.mainBundle().pathForResource("level10", ofType: "sks")
            index = 11
            requiredPieces = 4
            sight.hidden = false
        default:
            resourcePath = NSBundle.mainBundle().pathForResource("congrats", ofType: "sks")
            levelNode.zPosition = 1; currentLevel = 1
            gameOver()}
        if let resourcePath = resourcePath{
            levelNode.addChild(SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath)))
            // Connections
            if currentLevel <= 10 {
                goal = levelNode.childNodeWithName("//goal")
                key = levelNode.childNodeWithName("//key")
                door = levelNode.childNodeWithName("//door")}
            // Teleporters
            switch currentLevel{
            case 4:
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//l1")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//l2")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//start")!.position
                
            case 5:
                teleporters[levelNode.childNodeWithName("//t1s")!] = levelNode.childNodeWithName("//start")!.position
                teleporters[levelNode.childNodeWithName("//t2s")!] = levelNode.childNodeWithName("//start")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//l3")!.position
                teleporters[levelNode.childNodeWithName("//t4")!] = levelNode.childNodeWithName("//l4")!.position
                teleporters[levelNode.childNodeWithName("//t5g")!] = levelNode.childNodeWithName("//g")!.position
                teleporters[levelNode.childNodeWithName("//t6k")!] = levelNode.childNodeWithName("//k")!.position
            case 6:
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
            case 7:
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
            case 8:
                teleporters[levelNode.childNodeWithName("//r1")!] = nil
                teleporters[levelNode.childNodeWithName("//r2")!] = nil
                teleporters[levelNode.childNodeWithName("//r3")!] = nil
                teleporters[levelNode.childNodeWithName("//r4")!] = nil
                teleporters[levelNode.childNodeWithName("//r4")!] = nil
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//loc")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//loc")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//loc")!.position
            case 9:
                teleporters[levelNode.childNodeWithName("//r1")!] = nil
                teleporters[levelNode.childNodeWithName("//r2")!] = nil
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//l1")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//l2")!.position
            case 10:
                teleporters[levelNode.childNodeWithName("//toPiece")!] = levelNode.childNodeWithName("//loc1")!.position
                teleporters[levelNode.childNodeWithName("//toKey")!] = levelNode.childNodeWithName("//loc2")!.position
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
                
            default: break
            }
        }
        // Set the starting position
        startNode = levelNode.childNodeWithName("//start")
        if let startNode = startNode {
            player.position = levelNode.convertPoint(startNode.position, toNode: self)}
    }
    
    func reload(){
        let skView = self.view as SKView!
        let scene = GameScene(fileNamed:"GameScene") as GameScene!
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)}
}