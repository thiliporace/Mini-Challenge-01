//
//  GameScene.swift
//  Project Cycle
//
//  Created by Thiago Liporace on 24/07/23.
//

import SpriteKit
import GameplayKit
import GameController
import SwiftUI

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var character = SKSpriteNode()
//    var basicEnemy = SKSpriteNode(imageNamed: "BasicEnemy")
//    var rangedEnemy = SKSpriteNode(imageNamed: "RangedEnemy")
    var characterTexture = SKTexture(imageNamed: "character")
    
    var enemies: [SKSpriteNode] = [SKSpriteNode(imageNamed: "BasicEnemy"),SKSpriteNode(imageNamed: "RangedEnemy")]
    
    var enemyTextures: [SKTexture] = [SKTexture(imageNamed: "BasicEnemy"), SKTexture(imageNamed: "RangedEnemy")]
    
    var virtualController: GCVirtualController?
    
    var playerPosX: CGFloat = 0
    var playerPosY: CGFloat = 0
    
    var enemyPosX: CGFloat = 0
    var enemyPosY: CGFloat = 0
    
    var moveSpeed: CGFloat = 3.5
    
    var score: Int = 0
    
    var isPlayerAlive = true
    
    let positions = Array(stride(from: -320, through: 320, by: 80))

    var joystick = JoystickController()

    enum bitMasks: UInt32{
        case character = 1
        case bush = 2
        case enemy = 3
        case bullet = 4
    }
    
    var renderTime: TimeInterval = 0
    var changeTime: TimeInterval = 1
    var seconds:Int = 0
    var minutes:Int = 0
    
    var timerLabel:SKLabelNode = SKLabelNode() //MARK: Depois colocar fontNamed:
    var scoreLabel:SKLabelNode = SKLabelNode()
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if joystick.isMoving{
            
            let adjustedSpritePosition = CGPointMake(joystick.moveSize.width, joystick.moveSize.height);
            
            playerPosX = adjustedSpritePosition.x
            
            playerPosY = adjustedSpritePosition.y
            
            if playerPosX >= 0.5{
                character.position.x += moveSpeed
            }
            else if playerPosX <= -0.5{
                character.position.x -= moveSpeed
            }
            if playerPosY >= 0.5{
                character.position.y += moveSpeed
            }
            else if playerPosY <= -0.5{
                character.position.y -= moveSpeed
            }
        }
        
        calculateTime(currentTime: currentTime)
        
        if seconds % 5 == 0{
            SpawnEnemies()
        }
        
        if seconds % 2 == 0{
            SpawnBullets()
        }
        
    } // MARK: funcao de update para a cena
    
    override func didMove(to view: SKView){
        
        physicsWorld.contactDelegate = self
        
        timerLabel.text = "00:00"
        self.addChild(timerLabel)
        
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        spawnCharacter()
        
        connectVirtualController()
        
    } // MARK: funcao para colocar as funcoes na cena View
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == bitMasks.enemy.rawValue) && (secondBody.categoryBitMask == bitMasks.bullet.rawValue) || (firstBody.categoryBitMask == bitMasks.bullet.rawValue) && (secondBody.categoryBitMask == bitMasks.enemy.rawValue)) {
            
            collisionWithBullet(enemy: firstBody.node as! SKSpriteNode, bullet: secondBody.node as! SKSpriteNode) //MARK: crashando.
        }
//        else if ((firstBody.categoryBitMask == bitMasks.enemy.rawValue) && (secondBody.categoryBitMask == bitMasks.character.rawValue) || (firstBody.categoryBitMask == bitMasks.character.rawValue) && (secondBody.categoryBitMask == bitMasks.enemy.rawValue)) {
//
//            collisionWithPlayer(enemy: firstBody.node as! SKSpriteNode, player: secondBody.node as! SKSpriteNode)
//        }
    }
    
    func collisionWithBullet(enemy: SKSpriteNode, bullet: SKSpriteNode) {
        enemy.removeFromParent()
        bullet.removeFromParent()
        
        score += 1
        print("\(score)")
        scoreLabel.text = "\(score)"
    }
    
    func collisionWithPlayer(enemy: SKSpriteNode, player: SKSpriteNode){
        enemy.removeFromParent()
        player.removeFromParent()
    }
    
    func spawnCharacter(){
        
        character = childNode(withName: "character") as! SKSpriteNode
        
        character.physicsBody = SKPhysicsBody(texture: characterTexture, size: character.size)
        
        character.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 200)
        
        character.physicsBody?.categoryBitMask = bitMasks.character.rawValue
        
        character.physicsBody?.collisionBitMask = bitMasks.bush.rawValue
        
        character.physicsBody?.contactTestBitMask = bitMasks.enemy.rawValue
        
        character.physicsBody!.affectedByGravity = false
        
        character.physicsBody?.allowsRotation = false
        
    } // MARK: funcao para spawnar o personagem, cria um nodo, adiciona fisica, cria ele em uma posicao, declara qual seu bitmask(usado para colisoes), desliga sua gravidade
    
    func connectVirtualController() {
        
        joystick.setInnerControl(imageName: "JoystickSubstrate", withAlpha: 0.5)
        joystick.setOuterControl(imageName: "Joystick", withAlpha: 0.25)
        joystick.autoShowHide = true
        self.addChild(joystick)
    } // MARK: funcao para criar o joystick virtual
    
    override func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?){
        for touch in touches {
            let location = touch.location(in: self)
            joystick.startControlFromTouch(touch: touch, andLocation: location)
        }
        
    } //MARK: funcao para detectar aonde o usuario esta clicando, para colocar o joystick no lugar
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            joystick.moveControlToLocation(touch: touch, andLocation: touch.location(in: self))
        }
    } //MARK: funcao para fazer o joystick seguir o dedo da pessoa caso ela segure na tela
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for _ in touches {
            joystick.endControl()
        }
    } // MARK: funcao para fazer o joystick parar de funcionar quando nao detectar nenhum toque na tela
    
    func SpawnBullets(){
        
        let Bullet = SKSpriteNode(imageNamed: "Food")
        let BulletTexture = SKTexture(imageNamed: "Food")
        
        Bullet.zPosition = -5
        Bullet.position = CGPointMake(playerPosX, playerPosY)
        
        let action = SKAction.move(to: CGPoint(x: enemyPosX, y: enemyPosY), duration: 4)
        let actionDone = SKAction.removeFromParent()
        Bullet.run(SKAction.sequence([action, actionDone]))
        
        Bullet.physicsBody = SKPhysicsBody(texture: BulletTexture, size: Bullet.size)
        Bullet.physicsBody?.categoryBitMask = bitMasks.bullet.rawValue
        Bullet.physicsBody?.contactTestBitMask = bitMasks.enemy.rawValue
        Bullet.physicsBody?.affectedByGravity = false
        Bullet.physicsBody?.allowsRotation = true
        Bullet.physicsBody?.isDynamic = false
        
        self.addChild(Bullet)
    }
    
    func SpawnEnemies(){
        
        let enemy = enemies.randomElement()
        let enemyTexture = enemyTextures.randomElement()
        
        let minValueY = -260
        let maxValueY = 260
        
        let minValueX = -800
        let maxValueX = 800
        
        let spawnPointX = UInt32(maxValueX - minValueX)
        let spawnPointY = UInt32(maxValueY - minValueY)
        
        enemyPosX = CGFloat(arc4random_uniform(spawnPointX))
        enemyPosY = CGFloat(arc4random_uniform(spawnPointY))
        
        enemy!.position = CGPoint (x: enemyPosX, y: enemyPosY)
        
        enemy?.physicsBody = SKPhysicsBody(texture: enemyTexture!, size: enemy!.size)
        enemy?.physicsBody?.categoryBitMask = bitMasks.enemy.rawValue
        enemy?.physicsBody?.contactTestBitMask = bitMasks.bullet.rawValue
        enemy?.physicsBody?.affectedByGravity = false
        enemy?.physicsBody?.isDynamic = true
        enemy?.physicsBody?.allowsRotation = false
        

        self.addChild(enemy?.copy() as! SKNode)
        
        let action = SKAction.move(to: CGPoint(x: playerPosX, y: playerPosY), duration: 2)
        let actionDone = SKAction.removeFromParent()
        
        enemy!.run(SKAction.sequence([action,actionDone]))
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        timerLabel.position.x = 460
        timerLabel.position.y = 270
        
        scoreLabel.position.x = -460
        scoreLabel.position.y = 270
    }
    
    func calculateTime(currentTime: TimeInterval){
        if currentTime > renderTime{
            if renderTime > 0{
                seconds += 1
                if seconds == 60{
                    seconds = 0
                    minutes += 1
                }
                let secondsText = (seconds < 10) ? "0\(seconds)" : "\(seconds)"
                let minutesText = (minutes < 10) ? "0\(minutes)" : "\(minutes)"
                timerLabel.text = "\(minutesText) : \(secondsText)"
            }
            renderTime = currentTime + changeTime
        }
    }
    
    
}
