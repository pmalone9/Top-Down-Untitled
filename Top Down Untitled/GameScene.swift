//
//  GameScene.swift
//  Top Down Untitled
//
//  Created by Patrick Maloney on 1/14/17.
//  Copyright © 2017 3Assassins Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameOver = false

    // this will change based on where the player moves to, different rooms will have slightly different layouts
    var roomType = "basic"
    
    
    // player
    let player = SKSpriteNode(imageNamed: "playerImage.png")
    
    
    // joystick that changes the players rotation
    let turnStick = SKSpriteNode(imageNamed: "dot.png")
    let tsBase = SKSpriteNode(imageNamed: "dot.png")
    var tsActive = false
    
    
    // joystick that moves the player
    let moveStick = SKSpriteNode(imageNamed: "dot.png")
    let msBase = SKSpriteNode(imageNamed: "dot.png")
    var msActive = false
    
    
    // setting up collisions
    enum colliderType: UInt32 {
        case Player = 1
        case Environment = 2
        //case Enemy = 4        // don't need this yet
    }
    
    
    
    
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    
    
    
    
    func setupGame() {
        
        // this will set up the rooms
        roomSetup(roomType: roomType)
        
        
        
        // rotation stick
        self.addChild(tsBase)
        tsBase.position = CGPoint(x: self.frame.midX + (self.frame.width / 3), y: self.frame.midY)
        tsBase.scale(to: CGSize(width: 150, height: 150))
        
        self.addChild(turnStick)
        turnStick.position = CGPoint(x: self.frame.midX + (self.frame.width / 3), y: self.frame.midY)
        turnStick.scale(to: CGSize(width: 100, height: 100))
        
        
        
        // move stick
        self.addChild(msBase)
        msBase.position = CGPoint(x: self.frame.midX - (self.frame.width / 3), y: self.frame.midY)
        msBase.scale(to: CGSize(width: 150, height: 150))
        
        self.addChild(moveStick)
        moveStick.position = CGPoint(x: self.frame.midX - (self.frame.width / 3), y: self.frame.midY)
        moveStick.scale(to: CGSize(width: 100, height: 100))
        
        
        
        // player
        player.position = CGPoint(x: self.frame.midX, y: 2 * self.frame.midX)
        //player.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        player.scale(to: CGSize(width: 40, height: 40))
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        
        player.physicsBody?.contactTestBitMask = colliderType.Environment.rawValue  // determines if contact (enemies maybe)
        player.physicsBody?.categoryBitMask = colliderType.Player.rawValue
        player.physicsBody?.collisionBitMask = colliderType.Player.rawValue     // determines if player can move through
        self.addChild(player)
        
        
        // changes the opacity
        turnStick.alpha = 0.4
        tsBase.alpha = 0.4
        moveStick.alpha = 0.4
        msBase.alpha = 0.4
    }
    
    
    func roomSetup(roomType: String) {
        
        // for different room themes instead of hard coding wall we can make it a string that will correspond to the theme's pieces
        let ltWall = SKSpriteNode(imageNamed: "wall")
        ltWall.scale(to: CGSize(width: (self.frame.width / 20), height: self.frame.height))
        ltWall.position = CGPoint(x: (ltWall.size.width / 2), y: self.frame.height / 2)
        ltWall.physicsBody = SKPhysicsBody(rectangleOf: ltWall.size)
        
        let rtWall = SKSpriteNode(imageNamed: "wall")
        rtWall.scale(to: CGSize(width: self.frame.width / 20, height: self.frame.height))
        rtWall.position = CGPoint(x: self.frame.width - (rtWall.size.width / 2), y: self.frame.height / 2)
        rtWall.physicsBody = SKPhysicsBody(rectangleOf: rtWall.size)
        
        
        
        
        let btWall = SKSpriteNode(imageNamed: "wall")
        btWall.scale(to: CGSize(width: self.frame.width, height: self.frame.height / 10))
        btWall.position = CGPoint(x: self.frame.height / 2, y: self.frame.width - self.frame.width / 3)     // fix position
        btWall.physicsBody = SKPhysicsBody(rectangleOf: btWall.size)
        
        let tpWall = SKSpriteNode(imageNamed: "wall")
        tpWall.scale(to: CGSize(width: self.frame.width, height: self.frame.height / 10))
        tpWall.position = CGPoint(x: self.frame.width / 2, y: 0)            // fix position
        tpWall.physicsBody = SKPhysicsBody(rectangleOf: tpWall.size)
        
        
        
        print("midX = \(self.frame.midX)\nmidY = \(self.frame.midY)\nheight = \(self.frame.height)\nwidth = \(self.frame.width)")
        
        
        let wallArray = [ltWall, rtWall, btWall, tpWall]
        for w in wallArray {
            
            w.physicsBody!.isDynamic = false
            
            w.physicsBody?.contactTestBitMask = colliderType.Environment.rawValue
            w.physicsBody?.categoryBitMask = colliderType.Environment.rawValue
            w.physicsBody?.collisionBitMask = colliderType.Environment.rawValue
            
            self.addChild(w)
        }
        
        
        // based on the room type we might add like a block in the center or something
        switch roomType {
        case "basic":
            
            self.backgroundColor = SKColor.white
            self.anchorPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            
        default:
            break
        }
    }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            
            if(tsBase.frame.contains(location)) {
                tsActive = true
            } else {
                tsActive = false
            }
            
            if(msBase.frame.contains(location)) {
                msActive = true
            } else {
                msActive = false
            }
        }
    }
    
    
    
    
    // there is a problem with the movement, if the user holds their finger still while on the joystick the player will not move
    // same problem with the rotation, if we want the player to automatically shoot if the player's thumb is on the turnstick, it won't shoot if they hold their thumb still
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            
            // determining if the turning stick is being used
            if tsActive {
                
                player.physicsBody?.affectedByGravity = false
                player.physicsBody?.isDynamic = true
                let tsVector = CGVector(dx: location.x - tsBase.position.x, dy: location.y - tsBase.position.y)
                let tsAngle = atan2(tsVector.dy, tsVector.dx)         // will be in radians
                let tsLength:CGFloat = tsBase.frame.size.height / 2
                let tsXDist:CGFloat = sin(tsAngle - 1.57079633) * tsLength
                let tsYDist:CGFloat = cos(tsAngle - 1.57079633) * tsLength
                if(tsBase.frame.contains(location)) {
                    turnStick.position = location
                } else {
                    turnStick.position = CGPoint(x: tsBase.position.x - tsXDist, y: tsBase.position.y + tsYDist)
                }
                player.zRotation = tsAngle      //to fix the issue stated above, maybe have this line be in setupGame or something
            }   // ends tsActive test
            
            
            // determining if the moving stick is being used
            if msActive {
                
                player.physicsBody?.affectedByGravity = false
                player.physicsBody?.isDynamic = true
                let msVector = CGVector(dx: location.x - msBase.position.x, dy: location.y - msBase.position.y)
                let msAngle = atan2(msVector.dy, msVector.dx)         // will be in radians
                let msLength:CGFloat = msBase.frame.size.height / 2
                let msXDist:CGFloat = sin(msAngle - 1.57079633) * msLength
                let msYDist:CGFloat = cos(msAngle - 1.57079633) * msLength
                if(msBase.frame.contains(location)) {
                    moveStick.position = location
                } else {
                    moveStick.position = CGPoint(x: msBase.position.x - msXDist, y: tsBase.position.y + msYDist)
                }
                player.position = CGPoint(x: player.position.x + (msVector.dx / 20), y: player.position.y + (msVector.dy / 20))     //to fix the issue stated above, maybe have this line be in setupGame or something
                // adjust the movement speed as needed
                
                
            }   // ends tsActive test
            
        }   // ends for loop
    }
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            // turning
            if tsActive {
                let centerStick = SKAction.move(to: tsBase.position, duration: 0.1)
                centerStick.timingMode = .easeOut
                turnStick.run(centerStick)
            }
            
            // moving
            if msActive {
                let centerStick = SKAction.move(to: msBase.position, duration: 0.1)
                centerStick.timingMode = .easeOut
                moveStick.run(centerStick)
            }

    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if !gameOver {
            
            // this checks if the player hits the wall
            if contact.bodyA.categoryBitMask == colliderType.Environment.rawValue || contact.bodyB.categoryBitMask == colliderType.Environment.rawValue {
                print("Hit a wall")
                
            } else {
                print("contact")
                player.physicsBody?.isDynamic = true
            }
            
            
        }   // end game over check
        
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
