//
//  GameViewController.swift
//  blockDropping
//
//  Created by xuelinf on 15/12/14.
//  Copyright (c) 2015年 xuelinf. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate{

    var scene: GameScene!
    var swiftris:Swiftris!
    
    var panPointReference:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()

        
        skView.presentScene(scene)
//        scene.addPreviewShapeToScene(swiftris.nextShape!) {
//            self.swiftris.nextShape?.moveTo(StartingColumn, row: StartingRow)
//            self.scene.movePreviewShape(self.swiftris.nextShape!) {
//                let nextShapes = self.swiftris.newShape()
//                self.scene.startTicking()
//                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
//            }
//        }
        
    }

    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer{
                return true
            }
        }else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
        swiftris.letShapeFall()
//        swiftris.fallingShape?.lowerShapeByOneRow()
//        scene.redrawShape(swiftris.fallingShape!, completion: {})
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!){}
        self.scene.movePreviewShape(fallingShape){
            self.view.userInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!){
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        nextShape()
    }
    
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!){}
    }
}
