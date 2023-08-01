//
//  JoystickController.swift
//  Project Cycle
//
//  Created by Thiago Liporace on 25/07/23.
//

import Foundation
import SpriteKit



class JoystickController : SKNode {

    private var outerControl:SKSpriteNode? = nil
    private var innerControl:SKSpriteNode? = nil
    private var startPoint:CGPoint = CGPoint(x: 0,y: 0)
    var isMoving:Bool = false
    private var _autoShowHide:Bool = false
    var autoShowHide:Bool {
        get { return _autoShowHide }
        set(autoShowHide) {
            _autoShowHide = autoShowHide
            if  _autoShowHide  {
                self.alpha = 0
            } else {
                self.alpha = 1
            }
        }
    }
    var moveSize:CGSize = CGSize(width: 0, height: 0)
    var startTouch:UITouch? = nil
    var movePoints:Float = 8
    var angle:Float = 0
    private var _defaultAngle:Float = 0
    var defaultAngle:Float {
        get { return _defaultAngle }
        set(defaultAngle) {
            _defaultAngle = defaultAngle
            self.angle = _defaultAngle
        }
    }
    
    init(outerControl: SKSpriteNode!, innerControl: SKSpriteNode!, startPoint: CGPoint, isMoving: Bool, _autoShowHide: Bool, moveSize: CGSize, startTouch: UITouch!, movePoints: Float, angle: Float, _defaultAngle: Float) {
        super.init()
        self.outerControl = outerControl
        self.innerControl = innerControl
        self.startPoint = startPoint
        self.isMoving = isMoving
        self._autoShowHide = _autoShowHide
        self.moveSize = moveSize
        self.startTouch = startTouch
        self.movePoints = movePoints
        self.angle = angle
        self._defaultAngle = _defaultAngle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(){
        super.init()
    }


    func setInnerControl(imageName:String!, withAlpha alpha:Float, withName nodeName:String!) {
        self.setInnerControl(imageName: imageName, withAlpha:alpha)
        innerControl!.name = nodeName
    }

    func setInnerControl(imageName:String!, withAlpha alpha:Float) {
        if  ((innerControl) != nil)  {
            innerControl!.removeFromParent()
        }

        innerControl = SKSpriteNode(imageNamed: imageName)
        innerControl!.alpha = CGFloat(alpha)
        self.addChild(innerControl!)
    }

    func setOuterControl(imageName:String!, withAlpha alpha:Float) {
        if  (outerControl != nil)  {
            outerControl!.removeFromParent()
        }
        outerControl = SKSpriteNode(imageNamed: imageName)
        outerControl!.alpha = CGFloat(alpha)
        self.addChild(outerControl!)
    }

    func startControlFromTouch(touch:UITouch!, andLocation location:CGPoint) {
        if  self.autoShowHide  {
            self.alpha = 1
            self.position = location
        }
        self.startTouch = touch
        startPoint = location
        self.isMoving = true
    }

    func moveControlToLocation(touch:UITouch!, andLocation location:CGPoint) {
        
        let outerRadius:Float = Float(outerControl!.size.width / 2)
        var movePoints:Float = self.movePoints
        
        let deltaX:Float = Float(location.x - startPoint.x)
        let deltaY:Float = Float(location.y - startPoint.y)
        
        let distance:Float = sqrtf((+(deltaY * deltaY) ))
        
        self.angle = atan2f(deltaY, deltaX) * 180 / Float(Double.pi)
        
        let isLeft:Bool = abs(self.angle) > 90
       
        let radians:Float = self.angle * Float(Double.pi) / 180

        if  distance < outerRadius  {
            innerControl!.position = touch.location(in: self)
            movePoints = distance / outerRadius * self.movePoints
        } else {
            let maxY:Float = outerRadius * sinf(radians)
            var maxX:Float = sqrtf((-(maxY * maxY) ))
            if  isLeft  {
                maxX *= -1
            }
            innerControl!.position = CGPointMake(CGFloat(maxX), CGFloat(maxY))
            movePoints = self.movePoints
        }
        let moveY:Float = movePoints * sinf(radians)
        var moveX:Float = sqrtf((movePoints * movePoints) - (moveY - moveY))
        if  isLeft  {
            moveX *= -1
        }

        self.moveSize = CGSizeMake(CGFloat(moveX),CGFloat(moveY))
    }

    func endControl() {
        self.isMoving = false
        self.reset()
    }

    func reset() {
        if  self.autoShowHide  {
            self.alpha = 0
        }
        self.moveSize = CGSizeMake(0, 0)
        self.angle = self.defaultAngle
        innerControl!.position = CGPointMake(0, 0)
    }
} //MARK: codigo para criar um joystick personalizado
