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
import UserNotifications
import CoreData

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var character = SKSpriteNode(imageNamed: "character")
    var characterTexture = SKTexture(imageNamed: "character")
    
    var basicEnemy : SKSpriteNode! { get{ return SKSpriteNode(imageNamed: "BasicEnemy") } }
    
    var rangedEnemy : SKSpriteNode! { get{ return SKSpriteNode(imageNamed: "RangedEnemy") } }
    
    var basicEnemyTexture: SKTexture = SKTexture(imageNamed: "BasicEnemy")
    var rangedEnemyTexture: SKTexture = SKTexture(imageNamed: "RangedEnemy")
    
    var virtualController: GCVirtualController?
    
    var playerPosX: CGFloat = 0
    var playerPosY: CGFloat = 0
    
    var enemyPosX: CGFloat = 0
    var enemyPosY: CGFloat = 0
    
    var moveSpeed: CGFloat = 3.55
    
    var score: Int = 0
    var highscore: Int = 0
    
    var isPlayerAlive = true
    
    let positions = Array(stride(from: -320, through: 320, by: 80))

    var joystick = JoystickController()

    enum bitMasks: UInt32{
        case character = 1
        case bush = 2
        case basicenemy = 3
        case bullet = 4
        case rangedenemy = 5
    }
    
    var renderTime: TimeInterval = 0
    var changeTime: TimeInterval = 1
    var seconds:Int = 0
    var minutes:Int = 0
    
    var timerLabel:SKLabelNode = SKLabelNode(fontNamed: "04b")
    var scoreLabel:SKLabelNode = SKLabelNode(fontNamed: "04b")
    var levelLabel:SKLabelNode = SKLabelNode(fontNamed: "04b")
    
    var upgradedToLevel2 = false
    var upgradedToLevel3 = false
    var upgradedToLevel4 = false
    var upgradedToLevel5 = false
    var level:Int = 1
   
//    @StateObject var coreDataController = CoreDataController()
//    @ObservedObject var scoreController: ScoreController
//    @ObservedObject var highscoreController: HighscoreController
    
    
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
        
        playerPosX = character.position.x
        playerPosY = character.position.y
        
        calculateTime(currentTime: currentTime)
        
        if (seconds > 10 && seconds <= 20) && !upgradedToLevel2 {
            upgradedToLevel2 = true
            self.removeAction(forKey: "basicspawn")
            self.removeAction(forKey: "rangedspawn")
            bulletSpawner(duration: 0.40)
            basicEnemySpawner(duration: 0.66)
            rangedEnemySpawner(duration: 1.2)
            level += 1
        }
        
        if(seconds > 20 && seconds <= 35) && !upgradedToLevel3 {
            upgradedToLevel3 = true
            bulletSpawner(duration: 0.3)
            basicEnemySpawner(duration: 0.45)
            rangedEnemySpawner(duration: 1.0)
            level += 1
        }
        
        if (seconds > 35 && seconds <= 60) && !upgradedToLevel4 {
            upgradedToLevel4 = true
            bulletSpawner(duration: 0.24)
            basicEnemySpawner(duration: 0.33)
            rangedEnemySpawner(duration: 0.8)
            level += 1
        }
        if (minutes >= 1) && !upgradedToLevel5 {
            upgradedToLevel5 = true
            bulletSpawner(duration: 0.22)
            basicEnemySpawner(duration: 0.22)
            rangedEnemySpawner(duration: 0.55)
            level += 1
        }
        
        levelLabel.text = "Level \(level)"
        
        if level == 5 {
            levelLabel.fontColor = UIColor.red
        }
        else {
            levelLabel.fontColor = UIColor.white
        }
        
        
        
    } // MARK: funcao de update para a cena
    
    override func didMove(to view: SKView){
        
        let backgroundSound = SKAudioNode(fileNamed: "MusicaJogo")
        self.addChild(backgroundSound)
        
        let highscoreDefault = UserDefaults.standard
         
        if (highscoreDefault.value(forKey: "Highscore") != nil){
            highscore = highscoreDefault.value(forKey: "Highscore") as! NSInteger
        }
        else {
            highscore = 0
        }
        
//        coreDataController.container.viewContext
        
        bulletSpawner(duration: 0.5)
        basicEnemySpawner(duration: 0.9)
        rangedEnemySpawner(duration: 1.3)
        
        physicsWorld.contactDelegate = self
        
        timerLabel.text = "00:00"
        self.addChild(timerLabel)
        
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        levelLabel.text = "Level \(level)"
        self.addChild(levelLabel)
        
        spawnCharacter()
        
        connectVirtualController()
        
    } // MARK: funcao para colocar as funcoes na cena View
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody: SKPhysicsBody = contact.bodyA
        let secondBody: SKPhysicsBody = contact.bodyB
        
        if ((firstBody.categoryBitMask == bitMasks.basicenemy.rawValue) && (secondBody.categoryBitMask == bitMasks.bullet.rawValue) || (firstBody.categoryBitMask == bitMasks.bullet.rawValue) && (secondBody.categoryBitMask == bitMasks.basicenemy.rawValue)) ||
            ((firstBody.categoryBitMask == bitMasks.rangedenemy.rawValue) && (secondBody.categoryBitMask == bitMasks.bullet.rawValue)) || ((firstBody.categoryBitMask == bitMasks.bullet.rawValue) && (secondBody.categoryBitMask == bitMasks.rangedenemy.rawValue)){
            
            if let contactA = firstBody.node as? SKSpriteNode, let contactB = secondBody.node as? SKSpriteNode {
                
                collisionWithBullet(enemy: contactA, bullet: contactB)
            }
        }
        
        else if ((firstBody.categoryBitMask == bitMasks.basicenemy.rawValue) && (secondBody.categoryBitMask == bitMasks.character.rawValue) || (firstBody.categoryBitMask == bitMasks.character.rawValue) && (secondBody.categoryBitMask == bitMasks.basicenemy.rawValue)) ||
            ((firstBody.categoryBitMask == bitMasks.rangedenemy.rawValue) && (secondBody.categoryBitMask == bitMasks.character.rawValue)) || ((firstBody.categoryBitMask == bitMasks.character.rawValue) && (secondBody.categoryBitMask == bitMasks.rangedenemy.rawValue)){
            if let contactA = firstBody.node as? SKSpriteNode, let contactB = secondBody.node as? SKSpriteNode {
                
                collisionWithPlayer(enemy: contactA, player: contactB)
            }
        }
    }
    
    func collisionWithBullet(enemy: SKSpriteNode, bullet: SKSpriteNode) {
        enemy.removeFromParent()
        bullet.removeFromParent()
        
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    func collisionWithPlayer(enemy: SKSpriteNode, player: SKSpriteNode){
        
        let ScoreDefault = UserDefaults.standard
        ScoreDefault.setValue(score, forKey: "Score")
        ScoreDefault.synchronize()
        
//        scoreController.createInitialScore()
        
        if score > highscore{
            let highscoreDefault = UserDefaults.standard
            highscoreDefault.setValue(score, forKey: "Highscore")
        }
        
//        if score > highscore {
//            highscoreController.createInitialHighscore()
//            highscoreController.createHighscore(highscore: Int32(score))
//        }
        
        enemy.removeFromParent()
        player.removeFromParent()
        
        self.view?.presentScene(SKScene(fileNamed: "EndGameScene"))
        
    }
    
    func spawnCharacter(){
        
//        character = childNode(withName: "character") as! SKSpriteNode
        
        character.physicsBody = SKPhysicsBody(texture: characterTexture, size: character.size)
        
        character.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) + 200)
        
        character.physicsBody?.categoryBitMask = bitMasks.character.rawValue
        
        character.physicsBody?.collisionBitMask = bitMasks.bush.rawValue
        
        character.physicsBody?.contactTestBitMask = bitMasks.basicenemy.rawValue
        
        character.physicsBody!.affectedByGravity = false
        
        character.physicsBody?.allowsRotation = false
        
        self.addChild(character)
        
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
        
        let action = SKAction.move(to: CGPoint(x: enemyPosX, y: enemyPosY), duration: 2.5)
        let actionDone = SKAction.removeFromParent()
        Bullet.run(SKAction.sequence([action, actionDone]))
        
        Bullet.physicsBody = SKPhysicsBody(texture: BulletTexture, size: Bullet.size)
        Bullet.physicsBody?.categoryBitMask = bitMasks.bullet.rawValue
        Bullet.physicsBody?.contactTestBitMask = bitMasks.basicenemy.rawValue
        Bullet.physicsBody?.affectedByGravity = false
        Bullet.physicsBody?.allowsRotation = true
        Bullet.physicsBody?.isDynamic = false
        
        self.addChild(Bullet)
    }
    
    func SpawnBasicEnemies(){
        
        let basicEnemy: SKSpriteNode = basicEnemy
        let basicEnemyTexture: SKTexture = basicEnemyTexture
        
        let minValueY = -260
        let maxValueY = 260
        
        let minValueX = -800
        let maxValueX = 800
        
        let spawnPointX = UInt32(maxValueX - minValueX)
        let spawnPointY = UInt32(maxValueY - minValueY)
        
        enemyPosX = CGFloat(arc4random_uniform(spawnPointX))
        enemyPosY = CGFloat(arc4random_uniform(spawnPointY))
        
        basicEnemy.position = CGPoint (x: enemyPosX, y: enemyPosY)
        
        basicEnemy.physicsBody = SKPhysicsBody(texture: basicEnemyTexture, size: basicEnemy.size)
        basicEnemy.physicsBody?.categoryBitMask = bitMasks.basicenemy.rawValue
        basicEnemy.physicsBody?.collisionBitMask = bitMasks.rangedenemy.rawValue
        basicEnemy.physicsBody?.contactTestBitMask = bitMasks.bullet.rawValue
        basicEnemy.physicsBody?.affectedByGravity = false
        basicEnemy.physicsBody?.isDynamic = true
        basicEnemy.physicsBody?.allowsRotation = false
        
        self.addChild(basicEnemy)
        
        let action = SKAction.move(to: CGPoint(x: playerPosX, y: playerPosY), duration: 2.8)
        let actionDone = SKAction.removeFromParent()
        
        basicEnemy.run(SKAction.sequence([action,actionDone]))
    }
    
    func SpawnRangedEnemies(){
        
        let rangedEnemy: SKSpriteNode = rangedEnemy
        let rangedEnemyTexture: SKTexture = rangedEnemyTexture
        
        let minValueY = -260
        let maxValueY = 260
        
        let minValueX = -800
        let maxValueX = 800
        
        let spawnPointX = UInt32(maxValueX - minValueX)
        let spawnPointY = UInt32(maxValueY - minValueY)
        
        enemyPosX = CGFloat(arc4random_uniform(spawnPointX))
        enemyPosY = CGFloat(arc4random_uniform(spawnPointY))
        
        rangedEnemy.position = CGPoint (x: enemyPosX, y: enemyPosY)
        
        rangedEnemy.physicsBody = SKPhysicsBody(texture: rangedEnemyTexture, size: rangedEnemy.size)
        rangedEnemy.physicsBody?.categoryBitMask = bitMasks.rangedenemy.rawValue
        rangedEnemy.physicsBody?.collisionBitMask = bitMasks.rangedenemy.rawValue
        rangedEnemy.physicsBody?.contactTestBitMask = bitMasks.bullet.rawValue
        rangedEnemy.physicsBody?.affectedByGravity = false
        rangedEnemy.physicsBody?.isDynamic = true
        rangedEnemy.physicsBody?.allowsRotation = false
        
        self.addChild(rangedEnemy)
        
        let action = SKAction.move(to: CGPoint(x: playerPosX - 50, y: playerPosY - 50), duration: 5.6)
        let actionDone = SKAction.removeFromParent()
        
        rangedEnemy.run(SKAction.sequence([action,actionDone]))
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        timerLabel.position.x = 480
        timerLabel.position.y = 270
        
        levelLabel.position.x = -460
        levelLabel.position.y = 270
        
        scoreLabel.position.x = 480
        scoreLabel.position.y = -270
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
    
    func basicEnemySpawner(duration: Double) {
        
        let wait = SKAction.wait(forDuration: duration)
        let action = SKAction.run {
            self.SpawnBasicEnemies()
        }
        let repeater = SKAction.repeatForever(SKAction.sequence([wait, action]))
        
        run(repeater, withKey: "basicspawn")
    }
    
    func rangedEnemySpawner(duration: Double) {
        
        let wait = SKAction.wait(forDuration: duration)
        let action = SKAction.run {
            self.SpawnRangedEnemies()
        }
        let repeater = SKAction.repeatForever(SKAction.sequence([wait, action]))
        
        run(repeater, withKey: "rangedspawn")
    }
    
    func bulletSpawner(duration: Double) {
        
        let wait = SKAction.wait(forDuration: duration)
        let action = SKAction.run {
            self.SpawnBullets()
        }
        let repeater = SKAction.repeatForever(SKAction.sequence([wait, action]))
        
        run(repeater, withKey: "bulletspawn")
    }
    
    
}
