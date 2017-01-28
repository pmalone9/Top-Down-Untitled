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
    
    var isTouched = false
    var location = CGPoint.zero
    
    
    
    
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
        player.scale(to: CGSize(width: 40, height: 40))
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        
        player.physicsBody?.contactTestBitMask = colliderType.Environment.rawValue  // determines if contact (enemies maybe)
        player.physicsBody?.categoryBitMask = colliderType.Player.rawValue      // equals the enum value
        player.physicsBody?.collisionBitMask = colliderType.Player.rawValue
        
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        print(colliderType.Player.rawValue)
        self.addChild(player)
        
        
        // changes the opacity, maybe make them fade out when the player starts to use them
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
        btWall.scale(to: CGSize(width: self.frame.width - (ltWall.size.width + rtWall.size.width), height: self.frame.height / 20))
        btWall.position = CGPoint(x:  self.frame.midX, y: 2 * self.frame.midX)     // fix position
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
            w.physicsBody?.categoryBitMask = colliderType.Player.rawValue      // equals the enum value
            w.physicsBody?.collisionBitMask = colliderType.Player.rawValue
            
            w.physicsBody?.usesPreciseCollisionDetection = true
            
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
    
    
    
    
    
    
    func movePlayer() {
        
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        
        // determining if the turning stick is being used
        if tsActive {
            
            
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
            
            player.position = CGPoint(x: player.position.x + (msVector.dx / abs(0.5 * msVector.dx)), y: player.position.y + (msVector.dy / abs(0.5 * msVector.dy)))     //to fix the issue stated above, maybe have this line be in setupGame or something
            // adjust the movement speed as needed
            
            
        }   // ends msActive test
    }

    
    
    
    var touchArray = [UITouch]()
    var touchCount = 0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //touchArray.append(touches.first!)
        //touchCount = touches.count
        
        isTouched = true
        for t in touches {
        
        
            touchArray.append(t)
            touchCount = touches.count
            
            location = t.location(in: self)
            
            
                // I think all I have to do to fix the single touch issue is check if either touch in touchArray is in the frame
                
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
                
                
            
            
        }   // ends for loop
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            location = t.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(touchCount - touches.count < 0) {
            touchCount = 0
        } else {
            touchCount -= touches.count
        }
        if(touchCount != 0) {
            touchArray.remove(at: 0)
        }
        
        
        isTouched = false
        
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
            // I think we will have to use one of the other two (not contactBitMask) for this stuff
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
        
        if isTouched {
            movePlayer()
        }   // ends isTouched check
        
        print(touchCount)
        
    }
}
