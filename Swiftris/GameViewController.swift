//
//  GameViewController.swift
//  Swiftris
//
//  Created by Stanley Idesis on 7/14/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate,ADBannerViewDelegate {

    var play = 1
    var window:UIWindow?
    @IBOutlet weak var PauseButton: UIButton!
    var savedScore: Int = 0
    @IBOutlet var tapGes: UITapGestureRecognizer!
    @IBOutlet var PanGes: UIPanGestureRecognizer!
    @IBOutlet var SwipeGes: UISwipeGestureRecognizer!
    var UIiAd: ADBannerView = ADBannerView()
    var SH = UIScreen.mainScreen().bounds.height
    var BV: CGFloat = 0
    
    @IBOutlet weak var hightestLabel: UILabel!
    //my edit
    @IBAction func LeftButtonClick(sender: AnyObject) {
        swiftris.moveShapeLeft()
    }
    
    @IBOutlet weak var firstView: UIView!
    @IBAction func RightButtonClick(sender: AnyObject) {
        swiftris.moveShapeRight()
    }
    @IBAction func PausePlayClick(sender: AnyObject) {
         var image = UIImage(named: "play.png") as UIImage?
        if(play == 1)
        {
          PauseGame()
            
        }else
        {
           PlayGame()
        }
        
        PauseButton.setImage(image, forState: .Normal)
        //
    }
    func PauseGame()
    {
        scene.stopTicking()
        play = 0
        var image = UIImage(named: "play.png") as UIImage?
        tapGes.enabled = false
        PanGes.enabled = false
        SwipeGes.enabled = false
        PauseButton.setImage(image, forState: .Normal)
    }
    func PlayGame()
    {
        tapGes.enabled = true
        PanGes.enabled = true
        SwipeGes.enabled = true
        scene.startTicking()
        play = 1
        var image = UIImage(named: "pause.png") as UIImage?
        PauseButton.setImage(image, forState: .Normal)
    }
    @IBAction func PlayClick(sender: AnyObject) {
        tapGes.enabled = true
        PanGes.enabled = true
        SwipeGes.enabled = true
        // Configure the view.
        firstView.hidden = true
        let skView = view as SKView
        skView.multipleTouchEnabled = false
       
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
       
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") != nil)
        {
        savedScore = NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") as Int
      
        }
          hightestLabel.text = String(savedScore)
    }
    //end my edit
    var scene: GameScene!
    var swiftris:Swiftris!
    var panPointReference:CGPoint?
  
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIiAd.alpha = 0
     
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    //begin iad
    // 1
    func appdelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as AppDelegate
    }
    
    // 2
    override func viewWillAppear(animated: Bool) {
        showAdd()
    }
    func showAdd()
    {
        BV = UIiAd.bounds.height
        UIiAd = self.appdelegate().UIiAd
        UIiAd.alpha = 1
        UIiAd.frame = CGRectMake(0, SH - BV, 0, 0)
        self.view.addSubview(UIiAd)
        UIiAd.delegate = self
        println("khoi tao ")
    }
    
    // 3
    override func viewWillDisappear(animated: Bool) {
        UIiAd.delegate = nil
        UIiAd.removeFromSuperview()
    }
    
    //   bannerViewWillLoadAd
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        println("will load ")
        UIiAd.alpha = 1
    }
    
    
    // 4
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        UIiAd.frame = CGRectMake(0, SH + 50, 0, 0)
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(1)
        UIiAd.alpha = 1
        UIiAd.frame = CGRectMake(0, SH - 50, 0, 0)
        UIView.commitAnimations()
        println("da load ")
    }
    
    // 5
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0)
        UIiAd.alpha = 1
        UIView.commitAnimations()
        println("fail load ")
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        println("ad press ")
        PauseGame()
        return true
    }
    //end iad
    
    
    
    
    
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
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
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    func didTick() {
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
            }
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("gameover.mp3")
        
        //To save highest score
        var highestScore:Int = swiftris.score
        if(highestScore > savedScore)
        {
             hightestLabel.text = String(highestScore)
        NSUserDefaults.standardUserDefaults().setObject(highestScore, forKey:"HighestScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        scene.animateCollapsingLines(swiftris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("levelup.mp3")
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        scene.playSound("drop.mp3")
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                self.gameShapeDidLand(swiftris)
            }
            scene.playSound("bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(swiftris.fallingShape!) {}
    }
}
