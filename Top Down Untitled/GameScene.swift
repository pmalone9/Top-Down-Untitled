//
//  GameScene.swift
//  Top Down Untitled
//
//  Created by Patrick Maloney on 1/14/17.
//  Copyright © 2017 3Assassins Studios. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // player
    let player = SKSpriteNode(imageNamed: "playerImage.png")
    
    
    // joystick that changes the players rotation
    let turnStick = SKSpriteNode(imageNamed: "dot.png")     // joystick
    let tsBase = SKSpriteNode(imageNamed: "dot.png")        // j2
    var tsActive = false                                    // stickActive
    
    
    // joystick that moves the player
    let moveStick = SKSpriteNode(imageNamed: "dot.png")
    let msBase = SKSpriteNode(imageNamed: "dot.png")
    var msActive = false
    
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        self.anchorPoint = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        
        // rotation stick
        self.addChild(tsBase)
        tsBase.position = CGPoint(x: self.frame.midX + (self.frame.width / 3), y: self.frame.midY)
        // should probably make these a percentage of the screen size
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
        self.addChild(player)
        player.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        player.scale(to: CGSize(width: 75, height: 75))
        
        // changes the opacity
        turnStick.alpha = 0.4
        tsBase.alpha = 0.4
        moveStick.alpha = 0.4
        msBase.alpha = 0.4
        
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
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            
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
                player.zRotation = tsAngle
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
                player.position = CGPoint(x: player.position.x + (msVector.dx / 10), y: player.position.y + (msVector.dy / 10))
            }   // ends tsActive test
            
        }   // ends for loop
    }
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            // turning
            if tsActive {
                let move = SKAction.move(to: tsBase.position, duration: 0.1)
                move.timingMode = .easeOut
                turnStick.run(move)
            }
            
            // moving
            if msActive {
                let move = SKAction.move(to: msBase.position, duration: 0.1)
                move.timingMode = .easeOut
                moveStick.run(move)
            }

    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
