//
//  GameOverScene.swift
//  FirstGame
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright © 2015 Xiulan Shi. All rights reserved.
//

import Foundation

import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // 1 Set the background color to white
        backgroundColor = SKColor.whiteColor()
        
        // 2 on the won parameter, set the message
        let message = won ? "You Won!" : "You Lose :["
        
        // 3 how to display a label of text to the screen with sprite kit
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // 4 this sets up and runs a sequence of two actions. I’ve included them all inline here to show you how handy that is (instead of having to make separate variables for each action). First it waits for 3 seconds, then it uses the runBlock action to run some arbitrary code.
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                
                // 5 This is how you transition to a new scene in Sprite Kit. First you can pick from a variety of different animated transitions for how you want the scenes to display – you choose a flip transition here that takes 0.5 seconds. Then you create the scene you want to display, and use the presentScene(_:transition:) method on the self.view property.
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // 6 If you override an initializer on a scene, you must implement the required init(coder:) initializer as well. However this initializer will never be called, so you just add a dummy implementation with a fatalError(_:) for now.
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
