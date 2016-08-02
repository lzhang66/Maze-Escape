//
//  monster.swift
//  maze
//
//  Created by Li Zhang on 8/1/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit

class Monster: SKSpriteNode {
    var sp: CGFloat = 3
    var directionX: CGFloat = 0
    var directionY: CGFloat = 0
    func move(game: SKNode) {
        self.removeAllActions()
        let ran = CGFloat.random(min: 0, max: 1)
        let path = CGPathCreateMutable()
        let location = self.convertPoint(CGPoint(x: 0, y: 0), toNode: game)
        CGPathMoveToPoint(path, nil, location.x, location.y)
        if ran <= 0.25 {directionX = 1; directionY = 0}
        else if ran <= 0.5 {directionX = -1; directionY = 0}
        else if ran <= 0.75 {directionX = 0; directionY = 1}
        else {directionX = 0; directionY = -1}
        CGPathAddLineToPoint(path, nil, directionX, directionY)
        self.runAction(SKAction.followPath(path, speed: sp))
    }
    func turn(level: SKNode){
        self.removeAllActions()
        let path = CGPathCreateMutable()
        let location = self.convertPoint(CGPoint(x: 0, y: 0), toNode: level)
        CGPathMoveToPoint(path, nil, location.x, location.y)
        directionX = -directionX; directionY = -directionY
        CGPathAddLineToPoint(path, nil, directionX, directionY)
        self.runAction(SKAction.followPath(path, speed: sp))
    }
    func search(player: SKNode, game: SKScene) {
        let playerLocation = player.convertPoint(CGPoint(x: 0, y: 0), toNode: game)
        let location = self.convertPoint(CGPoint(x: 0, y: 0), toNode: game)
        var toPlayer = playerLocation  - location
        toPlayer.normalize()

        let obj = game.physicsWorld.bodyAlongRayStart(location + toPlayer * 20, end: playerLocation)
        if obj != nil && obj!.node == player {
            self.position += toPlayer * sp
        }
        //else {self.removeAllActions(); move(game)}
    }
}