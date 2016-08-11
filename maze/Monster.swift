//
//  monster.swift
//  maze
//
//  Created by Li Zhang on 8/1/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Monster: SKSpriteNode {
    var sp: CGFloat = 3
    var directionX: CGFloat = 0
    var directionY: CGFloat = 0
    var searched = false
    var target: CGPoint!
    var location: CGPoint!
    var toPlayer: CGVector!
    var m = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("music4",ofType:"wav")!)
    var music: AVPlayer?

    func search(player: SKNode, game: SKScene) {
        if searched == false {
            target = player.convertPoint(CGPoint(x: 0, y: 0), toNode: game)
            location = self.convertPoint(CGPoint(x: 0, y: 0), toNode: game)
            toPlayer = CGVector(point: target  - location)
            toPlayer.normalize()
            }
        let obj = game.physicsWorld.bodyAlongRayStart(location + toPlayer * 10, end: target)
        if obj?.node?.physicsBody != nil && obj?.node?.physicsBody?.categoryBitMask == 2 {
            if music != nil {
                music!.volume -= 0.008
                if music!.volume <= 0 {music!.pause(); music = nil}
            }
            return
        }
        else if obj != nil && obj!.node == player {
            self.position += toPlayer * sp
            if music == nil && sound.hidden == false {
                music = AVPlayer(URL: m)
                music!.play()
            }
            music?.volume = 1
        }
        else if obj != nil{
            location = (obj?.node!.convertPoint(CGPoint(x: 0, y: 0), toNode: game))!; searched = true; search(player, game: game)
        }
        else {
            self.position += toPlayer * sp
            if music == nil && sound.hidden == false {
                music = AVPlayer(URL: m)
                music!.volume = 1
                music!.play()
            }
        }
    }
    
    func die(game: SKScene){
        /* Particle effect */
        if music != nil {music?.pause(); music = nil}
        let particles = SKEmitterNode(fileNamed: "monsterDie")!
        print(particles)
        particles.position = self.convertPoint(CGPointMake(0, 0), toNode: game)
        particles.numParticlesToEmit = 25
        game.addChild(particles)
        self.removeFromParent()
        tutorialLabel.runAction(SKAction.fadeInWithDuration(3)); tutorialLabel.text = "Monster eliminated"; tutorialLabel.runAction(SKAction.sequence([SKAction.waitForDuration(6), SKAction.fadeOutWithDuration(3)]))
    }
}