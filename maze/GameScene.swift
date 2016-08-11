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
import GameKit
import AVFoundation

//mixpanel.track("", parameters:["": ""])
var gameMode: Int = 0
var currentLevel = 1
var tutorialLabel: SKLabelNode!
var timer: Double = 0
var tutorial: [String] = ["Swipe!", "Find the exit.", "Grab the key!", "Here is a hard one.", "Teleport!", "WHAT?!", "Not this way...", "Try this.", "Test your luck!", "Where is the key?", "Oops! Someone turned of the light...", "The last level!", "Monster killed"]
var index = -1 {didSet {
    tutorialLabel.runAction(SKAction.fadeInWithDuration(3)); tutorialLabel.text = tutorial[index]; tutorialLabel.runAction(SKAction.sequence([SKAction.waitForDuration(6), SKAction.fadeOutWithDuration(3)]))}}
var numDeath = 0
var pieceLocationTimer = 0.0
var sound: SKNode!
var s = true

var data = NSUserDefaults.standardUserDefaults()

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKNode!
    weak var cameraTarget: SKNode!
    weak var levelNode: SKNode!
    var goal: SKNode!
    var key: SKNode!
    var door: SKNode!
    var Continue: SKNode!
    var startNode: SKNode!
    var sight: SKNode!
    var pass: SKNode!
    var Frame: SKNode!
    var timeLabel: SKLabelNode!
    var label: SKLabelNode!
    var hint: SKLabelNode!
    var swipeRight: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeDown: UISwipeGestureRecognizer!
    var swipeUp: UISwipeGestureRecognizer!
    var teleporters: [SKNode:CGPoint] = [:]
    var monsters: [Monster]! = []
    var buttonMain: MSButtonNode!
    var buttonPause: MSButtonNode!
    var buttonRestart: MSButtonNode!
    var buttonSkip: MSButtonNode!
    var buttonPiece: MSButtonNode!
    var buttonNext: MSButtonNode!
    var buttonSound: MSButtonNode!
    var swipeBegins: CGPoint!
    var swipeEnds: CGPoint!
    var swipeVector: CGVector!
    var music1 = AVPlayer(URL: NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("music1",ofType:"mp3")!))
    var music2 = AVPlayer(URL: NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("music2",ofType:"mp3")!))
    var music3 = AVPlayer(URL: NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("music3",ofType:"mp3")!))
    
    var impulse: CGFloat = 100.0
    var resourcePath: String?
    var numTorches = 0 {didSet{sight.xScale *= 1.5; sight.yScale *= 1.5}}
    var numPieces = 0
    var requiredPieces = 0
    var playerSize = 139.0
    var w: CGFloat = 0
    var h: CGFloat = 0
    var location: CGPoint?
    var velocity: CGVector = CGVectorMake(0, 0)
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var mass: CGFloat = 0.5
    
    var record: [String]!
    var NMrecord: [String]!
    
    override func didMoveToView(view: SKView) {
        record = data.arrayForKey("records") as! [String]
        NMrecord = data.arrayForKey("NMrecords") as! [String]
        if data.integerForKey("highestLevel") == 0 {data.setValue(1, forKey: "highestLevel")}
        if data.integerForKey("highestLevel") < 10 {data.setBool(false, forKey: "nightmare")}
        player = childNodeWithName("player")
        levelNode = childNodeWithName("level")
        
        Frame = camera!.childNodeWithName("frame")
        Frame.hidden = true
        pass = camera!.childNodeWithName("pass")
        pass.hidden = true
        Continue = camera!.childNodeWithName("continue")
        Continue.hidden = true
        sight = camera!.childNodeWithName("a")
        sight.hidden = true
        sound = camera!.childNodeWithName("sound")
        sound.hidden = s
        tutorialLabel = camera!.childNodeWithName("tutorialLabel") as! SKLabelNode
        timeLabel = camera!.childNodeWithName("timer") as! SKLabelNode
        label = camera!.childNodeWithName("label") as! SKLabelNode
        hint = pass.childNodeWithName("//h") as! SKLabelNode
        hint.text = ""
        buttonRestart = camera!.childNodeWithName("restartButton") as! MSButtonNode
        buttonRestart.selectedHandler = {self.reload()}
        buttonRestart.hidden = true
        // Return button
        buttonMain = camera!.childNodeWithName("main") as! MSButtonNode
        buttonMain.selectedHandler = {
            self.pauseMusic()
            for n in self.monsters {
                if n.music != nil {n.music?.pause(); n.music = nil}
            }
            timer = 0; numDeath = 0; pieceLocationTimer = 0
            let skView = self.view as SKView!
            let scene = Main(fileNamed:"Main") as Main!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)}
        // Pause button
        buttonPause = camera!.childNodeWithName("pause") as! MSButtonNode
        buttonPause.selectedHandler = {
            for n in self.monsters {
                n.removeAllActions()
                if n.music != nil {n.music?.pause()}
            }
            if sound.hidden == false {self.pauseMusic()}
            self.velocity = (self.player.physicsBody?.velocity)!
            self.player.physicsBody?.velocity = CGVectorMake(0, 0)
            self.player.physicsBody?.dynamic = false
            self.Continue.hidden = false}
        buttonSkip = camera!.childNodeWithName("skip") as! MSButtonNode
        buttonSkip.selectedHandler = {
            currentLevel += 1; numDeath = 0; pieceLocationTimer = 0
            if currentLevel > data.integerForKey("highestLevel"){data.setValue(currentLevel, forKey: "highestLevel")}
            self.reload()}
        buttonSkip.hidden = true
        // Key piece position button
        buttonPiece = camera!.childNodeWithName("piecePosition") as! MSButtonNode
        buttonPiece.selectedHandler = {
            if self.requiredPieces > 0 && pieceLocationTimer >= 20{
                if self.numPieces < self.requiredPieces {
                    self.cameraTarget = self.levelNode.childNodeWithName("//piece")!.parent!.parent}
                else {self.cameraTarget = self.levelNode.childNodeWithName("//KEY")}
                self.cameraTarget!.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.runBlock({self.cameraTarget = self.player})]))
                pieceLocationTimer = 0}
        }
        buttonNext = pass.childNodeWithName("//next") as! MSButtonNode
        buttonNext.selectedHandler = {
            currentLevel += 1; numDeath = 0; pieceLocationTimer = 0; self.reload()
        }
        buttonSound = camera!.childNodeWithName("buttonSound") as! MSButtonNode
        buttonSound.selectedHandler = {
            if sound.hidden == true {
                self.playMusic(); sound.hidden = false; s = false
            }
            else {
                self.pauseMusic(); sound.hidden = true; s = true
                for n in self.monsters {n.music!.pause()}
            }
        }
        // Load level
        loadCurrentLevel()
        if sound.hidden == false {playMusic()}
        if requiredPieces > 0 {
            levelNode.childNodeWithName("//KEY")!.hidden = true
            label.text = "\(numPieces) / \(requiredPieces)"}
        
        cameraTarget = player
        // Set the swipe gesture
        if data.integerForKey("highestLevel") <= 3 {
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
            self.view?.addGestureRecognizer(swipeDown)}
        
        physicsWorld.contactDelegate = self
   //     self.view?.showsPhysics = true
        self.view!.showsPhysics = false
        self.view!.showsFPS = false
        self.view!.showsNodeCount = false
        self.view!.showsFields = false
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if currentLevel == 1 && index == 0 {
            tutorialLabel.runAction(SKAction.waitForDuration(3));index += 1}
        if Continue.hidden == false {
            Continue.hidden = true
            if sound.hidden == false {playMusic()}
            for n in monsters {if n.music != nil {n.music?.play()}}
            player.physicsBody?.dynamic = true
            player.physicsBody?.velocity = velocity}
        if data.integerForKey("highestLevel") >= 4 {
            for touch in touches {
                swipeBegins = touch.locationInNode(self)}
        }
        if data.integerForKey("highestLevel") >= 9 {
            for touch in touches {
                if self.nodeAtPoint(touch.locationInNode(self)) == player {
                    player.physicsBody!.linearDamping = 3
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        player.physicsBody!.linearDamping = 0.1
        if data.integerForKey("highestLevel") >= 4 {
            for touch in touches {
                if self.nodeAtPoint(touch.locationInNode(self)) != player {
                    swipeEnds = touch.locationInNode(self)
                    swipeVector = CGVectorMake(swipeEnds.x - swipeBegins.x, swipeEnds.y - swipeBegins.y)
                    if (swipeVector.dx <= 8 && swipeVector.dx >= -8) && (swipeVector.dy <= 8 && swipeVector.dy >= -8) {return}
                    x = swipeVector.dx / sqrt(swipeVector.dx * swipeVector.dx + swipeVector.dy * swipeVector.dy)
                    y = swipeVector.dy / sqrt(swipeVector.dx * swipeVector.dx + swipeVector.dy * swipeVector.dy)
                    player.physicsBody?.applyImpulse(CGVectorMake(impulse * x, impulse * y))}
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Camera follows player
        if let cameraTarget = cameraTarget {
            if cameraTarget == player {
                camera?.runAction(SKAction.moveTo(player.position, duration: 0.1))}
            else {camera?.runAction(SKAction.sequence([SKAction.moveTo(levelNode.convertPoint(cameraTarget.position, toNode: self), duration: 1.5), SKAction.waitForDuration(2)]))}
        }
        // When game is not over or paused
        if buttonRestart.hidden == true && Continue.hidden == true {
            timer += 1/60; pieceLocationTimer += 1/60
            timeLabel.text = "\(Double(Int(timer * 100)) / 100.0)"
            for n in monsters {n.search(player, game: self); n.searched = false}
        }
        if pieceLocationTimer >= 20 && requiredPieces > 0 && Frame.hidden == true {
            
            self.Frame.runAction(SKAction.sequence([SKAction.runBlock({self.Frame.hidden = false}), SKAction.fadeInWithDuration(0.1), SKAction.resizeByWidth(600, height: 400, duration: 2), SKAction.fadeOutWithDuration(0.5), SKAction.resizeByWidth(-600, height: -400, duration: 2), SKAction.runBlock({self.Frame.hidden = true})]))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        if contact.bodyA.node == nil || contact.bodyB.node == nil {return}
        // 4: monster. If monster collide with anything other than player
        if contact.bodyA.categoryBitMask == 4 && contact.bodyB.node != player && contact.bodyB.categoryBitMask != 24{return}
        else if contact.bodyB.categoryBitMask == 4 && contact.bodyA.node != player && contact.bodyA.categoryBitMask != 24{return}
        // 4: monster
        if (contact.bodyA.node == player && contact.bodyB.categoryBitMask == 4) || (contact.bodyB.node == player && contact.bodyA.categoryBitMask == 4) {
            for n in monsters {n.physicsBody = nil}
            numDeath += 1; gameOver(); if numDeath >= 5 {buttonSkip.hidden = false}
            die1.percentComplete = 1.0
            die10.percentComplete += 1/10
            die30.percentComplete += 1/30
            GKAchievement.reportAchievements([die1, die10, die30], withCompletionHandler: nil)
        }
        // 24: trap
        if contact.bodyA.categoryBitMask == 24 || contact.bodyB.categoryBitMask == 24 {
            for n in monsters {
                if n == contact.bodyA.node || n == contact.bodyB.node {n.die(self); return}
                }
            numDeath += 1; gameOver(); if numDeath >= 5 {buttonSkip.hidden = false}
            die1.percentComplete = 100
            die10.percentComplete += 1/15 * 100
            die30.percentComplete += 1/30 * 100
        }
        // Goal
        else if contact.bodyA.node == goal || contact.bodyB.node == goal {
            
            timer = Double(Int(timer * 100)) / 100.0; pass.hidden = false; gameOver()
            if currentLevel == 1 {hint.text = "Only swipe up, down, left or right."}
            if currentLevel == 3 {hint.text = "You can now swipe at any direction!"} 
            else if currentLevel == 7 {hint.text = "Try the hint button in main manu."}
            else if currentLevel == 8 {hint.text = "Tap & hold the ball to slow down!"}
            else if currentLevel == 10 {hint.text = "Nightmare Mode enabled."; data.setBool(true, forKey: "nightmare")}
            
            if currentLevel == data.integerForKey("highestLevel") {data.setInteger(currentLevel + 1, forKey: "highestLevel")}
            
            // Achievement
            if currentLevel == 4 {level4.percentComplete = 100}
            else if currentLevel == 5 {level5.percentComplete = 100}
            else if currentLevel == 10 {level10.percentComplete = 100}
            GKAchievement.reportAchievements([level4, level5, level10], withCompletionHandler: nil)
            
            // Records for normal mode
            if gameMode == 0 {
                if record[currentLevel - 1] == "" {
                    record[currentLevel - 1] = String(timer)}
                else {
                    if timer <= Double(record[currentLevel - 1]) {record[currentLevel - 1] = String(timer)}
                }
                data.setValue(record, forKey: "records"); timer = 0; numDeath = 0}
            // Records for Nightmare mode
            else {
                if NMrecord[currentLevel - 1] == "" {
                    NMrecord[currentLevel - 1] = String(timer)}
                else {
                    if timer <= Double(NMrecord[currentLevel - 1]) {NMrecord[currentLevel - 1] = String(timer)}
                }
                data.setValue(NMrecord, forKey: "NMrecords"); timer = 0; numDeath = 0}
            }
        // 8: key
        else if (contact.bodyA.categoryBitMask == 8 || contact.bodyB.categoryBitMask == 8) && levelNode.childNodeWithName("//KEY")?.hidden != true
        {if contact.bodyA.categoryBitMask == 8 {contact.bodyA.node!.removeFromParent()}
        else {contact.bodyB.node!.removeFromParent()}; door.removeFromParent()}
        // 16: torch
        else if contact.bodyA.categoryBitMask == 16 || contact.bodyB.categoryBitMask == 16 {
            numTorches += 1;
            if contact.bodyA.categoryBitMask == 16 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()} }
        // 32: piece
        else if contact.bodyA.categoryBitMask == 32 || contact.bodyB.categoryBitMask == 32 {
            numPieces += 1; label.text = "\(numPieces) / \(requiredPieces)"
            if contact.bodyA.categoryBitMask == 32 {contact.bodyA.node!.removeFromParent()}
            else {contact.bodyB.node!.removeFromParent()}
            if numPieces == requiredPieces {levelNode.childNodeWithName("//KEY")!.hidden = false}
        }
        // Body A is teleporter
        else if contact.bodyA.categoryBitMask == 18 {
            mass = contact.bodyB.mass
            let obj = contact.bodyB.node
            // Random teleporter
            if teleporters[contact.bodyA.node!.parent!.parent!] == nil {
                location = CGPoint(x: CGFloat.random(min:-w, max: w), y: CGFloat.random(min:-h, max: h))}
            contact.bodyB.node!.physicsBody = nil
            if let location = location {obj!.position = levelNode.convertPoint(location, toNode: self)
                self.location = nil}
            else {obj!.position = levelNode.convertPoint(teleporters[contact.bodyA.node!.parent!.parent!]!, toNode: self)}
            obj!.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(50))
            obj!.physicsBody!.dynamic = true
            obj!.physicsBody!.affectedByGravity = false
            obj!.physicsBody!.mass = mass
            obj!.physicsBody!.categoryBitMask = 1
            obj!.physicsBody!.collisionBitMask = 3
            obj!.physicsBody!.contactTestBitMask = 4294967295
        }
        // Body B is teleporter
        else if contact.bodyB.categoryBitMask == 18 {
            mass = contact.bodyA.mass
            let obj = contact.bodyA.node
            if teleporters[contact.bodyB.node!.parent!.parent!] == nil {
                w = (levelNode.childNodeWithName("//size")!.position.x)
                h = (levelNode.childNodeWithName("//size")!.position.y)
                location = CGPoint(x: CGFloat.random(min:-w, max: w), y: CGFloat.random(min:-h, max: h))}
            contact.bodyA.node!.physicsBody = nil
            if location != nil {contact.bodyA.node!.position = levelNode.convertPoint(location!, toNode: self); location = nil}
            else {contact.bodyA.node!.position = levelNode.convertPoint(teleporters[contact.bodyB.node!.parent!.parent!]!, toNode: self)}
            obj!.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(50))
            obj!.physicsBody!.dynamic = true
            obj!.physicsBody!.affectedByGravity = false
            obj!.physicsBody!.mass = mass
            obj!.physicsBody!.categoryBitMask = 1
            obj!.physicsBody!.collisionBitMask = 3
            obj!.physicsBody!.contactTestBitMask = 4294967295
        }
        // For Level 4
        else if (contact.bodyA.node?.name == "Oops" || contact.bodyB.node?.name == "Oops") && index == 4 {
            index += 1}
        else if (contact.bodyA.node?.name == "Oops" || contact.bodyB.node?.name == "Oops") && index == 5 {
            index += 1}
    }
    
    func gameOver(){
        if sound.hidden == false {
            pauseMusic()
            for n in monsters {
                if n.music != nil {n.music!.pause()}
            }
        }
        player.physicsBody?.velocity = CGVectorMake(0, 0)
        player.physicsBody?.dynamic = false
        player.runAction(SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 0.50))
        buttonRestart.hidden = false}
    
    // Actions to be done when swiped
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
        monsters.removeAll()
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
            if gameMode == 0 {gameMode += 1}
            resourcePath = NSBundle.mainBundle().pathForResource("congrats", ofType: "sks")
            gameOver(); data.setInteger(10, forKey: "highestLevel")
        }
        if let resourcePath = resourcePath{
            levelNode.addChild(SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath)))
            if levelNode.childNodeWithName("//size") != nil
                {w = (levelNode.childNodeWithName("//size")!.position.x)
                h = (levelNode.childNodeWithName("//size")!.position.y)}
            // Connections
            if currentLevel <= 10 {
                goal = levelNode.childNodeWithName("//goal")
                key = levelNode.childNodeWithName("//key")
                door = levelNode.childNodeWithName("//door")}
            // Teleporters
            switch currentLevel{
            case 1:
                if gameMode == 1 {
                    newMonster()
                    monsters.last!.position = CGPointMake(CGFloat.random(min:-w, max: w), CGFloat.random(min:-h, max: h))}
            case 2:
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M")!.position}
            case 3:
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M")!.position
                }
            case 4:
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//l1")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//l2")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//start")!.position
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M1")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M2")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M3")!.position
                }
            case 5:
                teleporters[levelNode.childNodeWithName("//t1s")!] = levelNode.childNodeWithName("//start")!.position
                teleporters[levelNode.childNodeWithName("//t2s")!] = levelNode.childNodeWithName("//start")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//l3")!.position
                teleporters[levelNode.childNodeWithName("//t4")!] = levelNode.childNodeWithName("//l4")!.position
                teleporters[levelNode.childNodeWithName("//t5g")!] = levelNode.childNodeWithName("//g")!.position
                teleporters[levelNode.childNodeWithName("//t6k")!] = levelNode.childNodeWithName("//k")!.position
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M1")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M2")!.position
                }
            case 6:
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M")!.position
                }
            case 7:
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M")!.position
                }
            case 8:
                teleporters[levelNode.childNodeWithName("//r1")!] = nil
                teleporters[levelNode.childNodeWithName("//r2")!] = nil
                teleporters[levelNode.childNodeWithName("//r3")!] = nil
                teleporters[levelNode.childNodeWithName("//r4")!] = nil
                teleporters[levelNode.childNodeWithName("//r4")!] = nil
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//loc")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//loc")!.position
                teleporters[levelNode.childNodeWithName("//t3")!] = levelNode.childNodeWithName("//loc")!.position
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M1")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M2")!.position
                }
            case 9:
                teleporters[levelNode.childNodeWithName("//r1")!] = nil
                teleporters[levelNode.childNodeWithName("//r2")!] = nil
                teleporters[levelNode.childNodeWithName("//t1")!] = levelNode.childNodeWithName("//l1")!.position
                teleporters[levelNode.childNodeWithName("//t2")!] = levelNode.childNodeWithName("//l2")!.position
                if gameMode == 1 {
                    newMonster()
                    monsters.last!.position = CGPointMake(CGFloat.random(min:-w, max: w), CGFloat.random(min:-h, max: h))}
            case 10:
                teleporters[levelNode.childNodeWithName("//toPiece")!] = levelNode.childNodeWithName("//loc1")!.position
                teleporters[levelNode.childNodeWithName("//toKey")!] = levelNode.childNodeWithName("//loc2")!.position
                teleporters[levelNode.childNodeWithName("//ran")!] = nil
                if gameMode == 1 {
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M1")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M2")!.position
                    newMonster(); monsters.last!.position = levelNode.childNodeWithName("//M3")!.position
                }
            default: currentLevel = 10}
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
    
    func newMonster() {
        let monster = Monster(imageNamed: "m")
        monster.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(monster.size.width * 0.5))
        monster.physicsBody!.dynamic = true
        monster.physicsBody!.affectedByGravity = false
        monster.physicsBody!.mass = 0.5
        monster.physicsBody!.categoryBitMask = 4
        monster.physicsBody!.collisionBitMask = 3
        monster.physicsBody!.contactTestBitMask = 4294967295
        monster.physicsBody!.fieldBitMask = 4294967295
        monster.anchorPoint = CGPointMake(0.5, 0.5)
        monster.zPosition = 1
        levelNode.addChild(monster)
        monsters.append(monster)
    }
    func playMusic() {
        if gameMode == 0 {
            if currentLevel <= 2 || currentLevel == 4 || currentLevel == 6 || currentLevel == 7 {
                music1.play()
            }
            else if currentLevel == 3 || currentLevel == 5 || currentLevel == 8 {
                music2.play()
            }
            else if currentLevel == 9 || currentLevel == 10 {
                music3.play()
            }
        }
    }
    func pauseMusic() {
        if gameMode == 0 {
            if currentLevel <= 2 || currentLevel == 4 || currentLevel == 6 || currentLevel == 7 {
                music1.pause()
            }
            else if currentLevel == 3 || currentLevel == 5 || currentLevel == 8 {
                music2.pause()
            }
            else if currentLevel == 9 || currentLevel == 10 {
                music3.pause()
            }
        }
    }
}