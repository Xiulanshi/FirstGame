//
//  GameScene.swift
//  FirstGame
//
//  Created by Xiulan Shi on 11/21/15.
//  Copyright (c) 2015 Xiulan Shi. All rights reserved.
//

import SpriteKit

//You may be wondering what the fancy syntax is here. Note that the category on Sprite Kit is just a single 32-bit integer, and acts as a bitmask. This is a fancy way of saying each of the 32-bits in the integer represents a single category (and hence you can have 32 categories max). Here you’re setting the first bit to indicate a monster, the next bit over to represent a projectile, and so on.
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 1 Declare a private constant for the player (i.e. the ninja, which is an example of a sprite. Creating a sprite by passing the name of the image to use.
    
    let player = SKSpriteNode(imageNamed: "player")
    // add a new property
    var monstersDestroyed = 0
    
    override func didMoveToView(view: SKView) {
        
        // 2 Setting the background color of a scene by setting the backgroundColor property.
        backgroundColor = SKColor.whiteColor()
        
        // 3 Position of the sprite is 10% vertically and centered horizontally.
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        
        // 4 To make the sprite appear on the scene, must add it as the child of the scene.
        addChild(player)
        
        // This sets up the physics world to have no gravity
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        // Set the scene as the delegate to be notified when two physics bodies colide
        physicsWorld.contactDelegate = self
        
        
        // addMonster in every second, and repeat it endlessly
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.0)
                ])
            ))
        
        // add backgroundMusic
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
    }
    
    //This code block includes some helper methods to generate a random number within a range using arc4random().
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // 1. Creates a physics body for the sprite. In this case, the body is defined as a rectangle of the same size of the sprite, because that’s a decent approximation for the monster.
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        
        // 2. Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the monster – you will through the code you’ve already written (using move actions).
        monster.physicsBody?.dynamic = true
        
        // 3. Sets the category bit mask to be the monsterCategory you defined earlier.
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        
        // 4. The contactTestBitMask indicates what categories of objects this object should notify the contact listener when they intersect. You choose projectiles here.
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        
        // 5. The collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the monster and projectile to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // Determin where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off the screen along the right edge, and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        
        // SKAction.moveTo(_:duration:): You use this action to direct the object to move off-screen to the left. Note that you can specify the duration for how long the movement should take, and here you vary the speed randomly from 2-4 seconds.
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        
        // SKAction.removeFromParent(): Sprite Kit comes with a handy action that removes a node from its parent, effectively “deleting it” from the scene. Here you use this action to remove the monster from the scene when it is no longer visible. This is important because otherwise you’d have an endless supply of monsters and would eventually consume all device resources.
        let actionMoveDone = SKAction.removeFromParent()
        
        // SKAction.sequence(_:): The sequence action allows you to chain together a sequence of actions that are performed in order, one at a time. This way, you can have the “move to” action perform first, and once it is complete perform the “remove from parent” action.
       // monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
       // This creates a new “lose action” that displays the game over scene when a monster goes off-screen.
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Add sound effect
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    // Remove the projecttile and monster from the scene when they collide
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1 This method passes you the two bodies that collide, but does not guarantee that they are passed in any particular order. So this bit of code just arranges them so they are sorted by their category bit masks so you can make some assumptions later.
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2 Finally, it checks to see if the two bodies that collide are the projectile and monster, and if so calls the method you wrote earlier.
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        
    }

    
}
