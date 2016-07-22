//
//  select.swift
//  maze
//
//  Created by Li Zhang on 7/20/16.
//  Copyright © 2016 Li Zhang. All rights reserved.
//

import Foundation
import SpriteKit
var re: MSButtonNode!
var label1, label2, label3, label4, label5, label6, label7, label8, label9, label10: SKLabelNode!
var labels: [SKLabelNode?] = [nil]
var lock1, lock2, lock3, lock4, lock5, lock6, lock7, lock8, lock9, lock10: SKNode!
var locks: [SKNode?]!

class Select: SKScene {
    var lv1, lv2, lv3, lv4, lv5, lv6, lv7, lv8, lv9, lv10: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        re = self.childNodeWithName("re") as! MSButtonNode
        re.selectedHandler = {
            let skView = self.view as SKView!
            let scene = Main(fileNamed:"Main") as Main!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)}
        lv1 = self.childNodeWithName("tolv1") as! MSButtonNode
        lv1.selectedHandler = {currentLevel = 1; self.loadGame()}
        
        lv2 = self.childNodeWithName("tolv2") as! MSButtonNode
        lv2.selectedHandler = {currentLevel = 2; self.loadGame()}
        
        lv3 = self.childNodeWithName("tolv3") as! MSButtonNode
        lv3.selectedHandler = {currentLevel = 3; self.loadGame()}
        
        lv4 = self.childNodeWithName("tolv4") as! MSButtonNode
        lv4.selectedHandler = {currentLevel = 4; self.loadGame()}
        
        lv5 = self.childNodeWithName("tolv5") as! MSButtonNode
        lv5.selectedHandler = {currentLevel = 5; self.loadGame()}
        
        lv6 = self.childNodeWithName("tolv6") as! MSButtonNode
        lv6.selectedHandler = {currentLevel = 6; self.loadGame()}
        
        lv7 = self.childNodeWithName("tolv7") as! MSButtonNode
        lv7.selectedHandler = {currentLevel = 7; self.loadGame()}
        
        lv8 = self.childNodeWithName("tolv8") as! MSButtonNode
        lv8.selectedHandler = {currentLevel = 8; self.loadGame()}
        
        lv9 = self.childNodeWithName("tolv9") as! MSButtonNode
        lv9.selectedHandler = {currentLevel = 9; self.loadGame()}
        
        lv10 = self.childNodeWithName("tolv10") as! MSButtonNode
        lv10.selectedHandler = {currentLevel = 10; self.loadGame()}
        
        label1 = self.childNodeWithName("label1") as! SKLabelNode
        label2 = self.childNodeWithName("label2") as! SKLabelNode
        label3 = self.childNodeWithName("label3") as! SKLabelNode
        label4 = self.childNodeWithName("label4") as! SKLabelNode
        label5 = self.childNodeWithName("label5") as! SKLabelNode
        label6 = self.childNodeWithName("label6") as! SKLabelNode
        label7 = self.childNodeWithName("label7") as! SKLabelNode
        label8 = self.childNodeWithName("label8") as! SKLabelNode
        label9 = self.childNodeWithName("label9") as! SKLabelNode
        label10 = self.childNodeWithName("label10") as! SKLabelNode
        labels = [label1, label2, label3, label4, label5, label6, label7, label8, label9, label10]
        for i in 0..<labels.count {
            if data.stringArrayForKey("records")?[i] != nil {
                labels[i]!.text = data.stringArrayForKey("records")![i]}
        }
        
        lock2 = self.childNodeWithName("lock2")
        lock3 = self.childNodeWithName("lock3")
        lock4 = self.childNodeWithName("lock4")
        lock5 = self.childNodeWithName("lock5")
        lock6 = self.childNodeWithName("lock6")
        lock7 = self.childNodeWithName("lock7")
        lock8 = self.childNodeWithName("lock8")
        lock9 = self.childNodeWithName("lock9")
        lock10 = self.childNodeWithName("lock10")
        locks = [nil, lock2, lock3, lock4, lock5, lock6, lock7, lock8, lock9, lock10]
        if data.integerForKey("highestLevel") > 0 {
        for n in 1...data.integerForKey("highestLevel") {
            if locks[n - 1] != nil {locks[n - 1]!.removeFromParent(); locks[n - 1] = nil}}}
    
    }
    
    func loadGame() {
        let skView = self.view as SKView!
        let scene = GameScene(fileNamed:"GameScene") as GameScene!
        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
}