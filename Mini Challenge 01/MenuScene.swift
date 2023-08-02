//
//  MenuScene.swift
//  Mini Challenge 01
//
//  Created by Thiago Liporace on 02/08/23.
//

import UIKit
import SpriteKit
import UserNotifications

class MenuScene: SKScene {
    
    var PlayButton: SKSpriteNode!
    var PlayText: SKLabelNode!

    override func didMove(to view: SKView) {
        
        requestPermission()
        
        sendNotification()

        PlayButton = self.childNode(withName: "PlayButton") as? SKSpriteNode
        PlayText = self.childNode(withName: "PlayText") as? SKLabelNode

        PlayButton.texture = SKTexture(imageNamed: "Button")
        
        PlayText.position = CGPoint(x: -0.5, y: -192.5)
        PlayText.zPosition = 10

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "PlayButton" {
                let scene = SKScene(fileNamed: "GameScene")
                let PASize = CGSize(width: 1334, height: 750)
                scene?.size = PASize
                scene?.scaleMode = .aspectFill
                let transition = SKTransition.crossFade(withDuration: 0.6)
                self.view?.presentScene(scene!, transition: transition)
            }
        }
    }
    
    func requestPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { sucess, error in
                if sucess {
                  print("All set")
                }else if let error = error{
                  print(error.localizedDescription)
                }
        }
    }
    
    func sendNotification(){
        let content = UNMutableNotificationContent()
        content.title = "It's time to Feed'Em Up!"
        content.subtitle = "Let's Play!"
        content.sound = UNNotificationSound.default
        
        var date = DateComponents()
        date.hour = 17
        date.minute = 05
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

