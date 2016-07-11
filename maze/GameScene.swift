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
    
    var impulse: CGFloat = 100.0
    var resourcePath: String?
    var sightNum = 0 {didSet{sight.xScale *= 1.4; sight.yScale *= 1.4}}
    
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
        cameraTarget = player
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Camera follows player
        if let cameraTarget = cameraTarget {camera?.position = cameraTarget.position}
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        if contact.bodyA.categoryBitMask == 24 || contact.bodyB.categoryBitMask == 24 {gameOver()}
        else if contact.bodyA.node == goal || contact.bodyB.node == goal {currentLevel += 1; reload()}
        else if contact.bodyA.node == key || contact.bodyB.node == key
            {key.removeFromParent(); door.removeFromParent()}
        else if contact.bodyA.categoryBitMask == 16 || contact.bodyB.categoryBitMask == 16 {
            sightNum += 1;
            if contact.bodyA.categoryBitMask == 16 { contact.bodyA.node!.removeFromParent() }
            if contact.bodyB.categoryBitMask == 16 { contact.bodyB.node!.removeFromParent() }
        }
        
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
        switch currentLevel {
        case 1:
            resourcePath = NSBundle.mainBundle().pathForResource("level1", ofType: "sks")
        case 2:
            resourcePath = NSBundle.mainBundle().pathForResource("level2", ofType: "sks")
        case 3:
            resourcePath = NSBundle.mainBundle().pathForResource("level3", ofType: "sks")
            player.xScale = 0.4; player.yScale = 0.4
            sight.hidden = false
        default:
            resourcePath = NSBundle.mainBundle().pathForResource("congrats", ofType: "sks")
            levelNode.zPosition = 1; currentLevel = 1
            gameOver()}
        if let resourcePath = resourcePath{
            levelNode.addChild(SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath)))
            if currentLevel <= 3 {
                goal = levelNode.childNodeWithName("//goal")
                key = levelNode.children[0].children[0].childNodeWithName("key")
                door = levelNode.childNodeWithName("//door")}}
    }
    
    func reload(){
        let skView = self.view as SKView!
        let scene = GameScene(fileNamed:"GameScene") as GameScene!
        scene.scaleMode = .AspectFit
        print(scene)
        skView.presentScene(scene)}
}