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
    
    override func didMove(to view: SKView) {
        
        MenuButton = self.childNode(withName: "MenuButton") as? SKSpriteNode
        
        MenuButton.texture = SKTexture(imageNamed: "Button")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "MenuButton" {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            } //MARK: trocar a view para o Menu quando tiver a tela concluida.
        }
    }
    
}
