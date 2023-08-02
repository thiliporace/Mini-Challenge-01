//
//  EndGameScene.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 01/08/23.
//

import UIKit
import SpriteKit

class EndGameScene: SKScene {
    
    var MenuButton: SKSpriteNode!
    var RestartButton: SKSpriteNode!
    
    var RestartText: SKLabelNode!
    var MenuText: SKLabelNode!
    var EndSceneTitle: SKLabelNode!
    var ScoreText: SKLabelNode!
    var score: Int = 0

    override func didMove(to view: SKView) {

        MenuButton = self.childNode(withName: "MenuButton") as? SKSpriteNode
        MenuButton.texture = SKTexture(imageNamed: "Button")
        
        RestartButton = self.childNode(withName: "RestartButton") as? SKSpriteNode
        RestartButton.texture = SKTexture(imageNamed: "Button")
        
        RestartText = self.childNode(withName: "RestartText") as? SKLabelNode
        MenuText = self.childNode(withName: "MenuText") as? SKLabelNode
        EndSceneTitle = self.childNode(withName: "EndSceneTitle") as? SKLabelNode
        
        let ScoreDefault = UserDefaults.standard
        
        score = ScoreDefault.value(forKey: "Score") as! NSInteger
        ScoreText = self.childNode(withName: "ScoreText") as? SKLabelNode
        ScoreText.text = "Your score was:  \(String(describing: score))"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first

        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)

            if nodesArray.first?.name == "MenuButton" {
                let transition = SKTransition.fade(withDuration: 3)
                let scene = SKScene(fileNamed: "MenuScene")
                let PASize = CGSize(width: 1334, height: 750)
                scene?.size = PASize
                scene?.scaleMode = .aspectFill
                self.view?.presentScene(scene!, transition: transition)
            } 
            
            else if nodesArray.first?.name == "RestartButton" {
                let transition = SKTransition.crossFade(withDuration: 0.6)
                let scene = SKScene(fileNamed: "GameScene")
                let PASize = CGSize(width: 1334, height: 750)
                scene?.size = PASize
                scene?.scaleMode = .aspectFill
                self.view?.presentScene(scene!, transition: transition)
            }
        }
    }
    
}
