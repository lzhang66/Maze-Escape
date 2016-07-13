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
var currentLevel = 3

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
    var sightNum = 0 {didSet{sight.xScale *= 1.4; sight.yScale *= 1.4}}
    var numPieces = 0
    var requiredPieces = 1
    
    override func didMoveToView(view: SKView) {
        player = childNodeWithName("player")
        sight = camera!.childNodeWithName("a") as! SKReferenceNode
        sight.hidden = true
        levelNode = childNodeWithName("level")
        restartButton = player.childNodeWithName("restartButton") as! MSButtonNode
        restartButton.selectedHandler = {self.reload()}
        restartButton.hidden = true
        // Load level
        loadCurrentLevel()
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
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Camera follows player
        if let cameraTarget = cameraTarget {camera?.position = cameraTarget.position}
        print(player.position)
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        if contact.bodyA.node == nil || contact.bodyB.node == nil {
            return
        }
        // 24: trap
        if contact.bodyA.categoryBitMask == 24 || contact.bodyB.categoryBitMask == 24 {gameOver()}
        else if contact.bodyA.node == goal || contact.bodyB.node == goal {currentLevel += 1; reload()}
        else if contact.bodyA.categoryBitMask == 6 || contact.bodyB.categoryBitMask == 6
        {if contact.bodyA.categoryBitMask == 6 {contact.bodyA.node!.removeFromParent()}
        else {contact.bodyB.node!.removeFromParent()}; door.removeFromParent()}
        // 16: torch
        else if contact.bodyA.categoryBitMask == 16 || contact.bodyB.categoryBitMask == 16 {
            sightNum += 1;
            if contact.bodyA.categoryBitMask == 16 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()} }
        // 32: piece
        else if contact.bodyA.categoryBitMask == 32 || contact.bodyB.categoryBitMask == 32 {
            numPieces += 1;
            if contact.bodyA.categoryBitMask == 32 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()}
            if numPieces == requiredPieces {}
        }
        else if contact.bodyA.categoryBitMask == 18 {
            player.position = levelNode.convertPoint(teleporters[contact.bodyA.node!]!, toNode: self)
        }
        else if contact.bodyB.categoryBitMask == 18 {
            player.position = levelNode.convertPoint(teleporters[contact.bodyB.node!]!, toNode: self)}
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
        teleporters = [:]
        switch currentLevel {
        case 1:
            resourcePath = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")
        case 2:
            resourcePath = NSBundle.mainBundle().pathForResource("level2", ofType: "sks")
        case 3:
            resourcePath = NSBundle.mainBundle().pathForResource("level3", ofType: "sks")
            player.xScale = 0.4; player.yScale = 0.4; requiredPieces = 3
            sight.hidden = false
        default:
            resourcePath = NSBundle.mainBundle().pathForResource("congrats", ofType: "sks")
            levelNode.zPosition = 1; currentLevel = 1
            gameOver()}
        if let resourcePath = resourcePath{
            levelNode.addChild(SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath)))
            if currentLevel <= 3 {
                goal = levelNode.childNodeWithName("//goal")
                key = levelNode.childNodeWithName("//key")
                door = levelNode.childNodeWithName("//door")}
            if currentLevel == 3 {
                let location = levelNode.childNodeWithName("//loc")!.position
                print(levelNode.convertPoint(location, toNode: self))
                teleporters[levelNode.childNodeWithName("//toPiece")!.childNodeWithName("//teleporter")!] = location
                print(levelNode.convertPoint(teleporters[levelNode.childNodeWithName("//toPiece")!.childNodeWithName("//teleporter")!]!, toNode: self))
            
            
                
                
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