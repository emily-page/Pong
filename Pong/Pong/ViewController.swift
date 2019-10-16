//
//  ViewController.swift
//  Pong
//
//  Created by ios6 on 4/10/17.
//  Copyright © 2017 ios6. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
//import CoreAudioKit

class ViewController: UIViewController, UICollisionBehaviorDelegate
{
    @IBOutlet weak var ballView: UIView!
    @IBOutlet weak var paddleView: UIView!
    var dynamicAnimator: UIDynamicAnimator!
    var pushBehavior: UIPushBehavior!
    var collisionBehavior: UICollisionBehavior!
    var ballDynamicItem: UIDynamicItemBehavior!
    var paddleDynamicItem: UIDynamicItemBehavior!
    var brickDynamicItem: UIDynamicItemBehavior!
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height
    var brickArray = [UIView]()
    var allViewsArray = [UIView]()
    var countBrick = 0
//    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
//        startAlert()
         dynamicAnimator = UIDynamicAnimator(referenceView: view)
//        ballMove()
//        paddleMove()
//        pushAction()
//        collisionAction()
//        setUpViews()
        ballView.backgroundColor = .clear
        paddleView.backgroundColor = .clear
    }
    
    @IBAction func startButton(_ sender: UIButton)
    {
        setUpViews()
        ballMove()
        paddleMove()
        brickMove()
        collisionAction()
        pushAction()
        sender.isHidden = true
    }
    
    func ballMove()
    {
        allViewsArray.append(ballView)
        ballDynamicItem = UIDynamicItemBehavior(items: [ballView])
        ballDynamicItem.friction = 0.0
        ballDynamicItem.resistance = 0.0
        ballDynamicItem.elasticity = 1.0
        ballDynamicItem.density = 2.0
        ballDynamicItem.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicItem)
        dynamicAnimator.updateItem(usingCurrentState: ballView)
        let size: CGFloat = 50.0
        ballView.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        ballView.layer.cornerRadius = size / 2
        ballView.layer.borderWidth = 1
        ballView.backgroundColor = UIColor(patternImage: UIImage(named: "ball")!)
    }
    
    func paddleMove()
    {
        allViewsArray.append(paddleView)
        paddleDynamicItem = UIDynamicItemBehavior(items: [paddleView])
        paddleDynamicItem.friction = 3.0
        paddleDynamicItem.resistance = 3.0
        paddleDynamicItem.elasticity = 0.0
        paddleDynamicItem.density = 6000.0
        paddleDynamicItem.allowsRotation = false
        dynamicAnimator.addBehavior(paddleDynamicItem)
        dynamicAnimator.updateItem(usingCurrentState: paddleView)
    }
    func pushAction()
    {
        pushBehavior = UIPushBehavior(items:[ballView], mode: .instantaneous)
        pushBehavior.active = true
        pushBehavior.magnitude = 1
        pushBehavior.pushDirection = CGVector(dx: 2, dy: 2)
        dynamicAnimator.addBehavior(pushBehavior)
    }
    func collisionAction()
    {
        collisionBehavior = UICollisionBehavior(items: allViewsArray)
        collisionBehavior.collisionMode = .everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
    }
    
    func brickMove()
    {
        brickDynamicItem = UIDynamicItemBehavior(items: brickArray)
        brickDynamicItem.density = 9000000
        brickDynamicItem.resistance = 5000
        brickDynamicItem.friction = 79000
        brickDynamicItem.elasticity = 1
        brickDynamicItem.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicItem)
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint)
    {
        //ball hits brick, brick disappears
        for i in brickArray
        {
            if item1.isEqual(ballView) && item2.isEqual(i)
            {
                i.removeFromSuperview()
                collisionBehavior.removeItem(i)
                countBrick -= 1
            }
            
            if countBrick == 0
            {
                winAlert()
                ballDynamicItem.isAnchored = true
                paddleView.backgroundColor = .clear
                let speech = AVSpeechSynthesizer()
                let utter = AVSpeechUtterance(string: "Winner Winner Chicken Dinner")
                speech.speak(utter)
            }
        }
        audioSound()
        print("paddle hit ball")
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint)
    {
        UIView.animate(withDuration: 0.5)
        {
            self.paddleView.backgroundColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
        }
        //game over, ball passed paddle
        if item.center.y > paddleView.center.y
        {
            ballDynamicItem.isAnchored = true
            let speech = AVSpeechSynthesizer()
            let utter = AVSpeechUtterance(string: "Loser Loser Loser")
            speech.speak(utter)
            lostAlert()
        }
        print("ball hit wall")
    }
   
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer)
    {
        paddleView.center = CGPoint(x: sender.location(in: view).x, y: paddleView.center.y)
        dynamicAnimator.updateItem(usingCurrentState: paddleView)
    }
    
    func audioSound()
    {
    let filename = "mySoundFile"
    let ext = "wav"
    if let soundUrl = Bundle.main.url(forResource: filename, withExtension: ext)
        {
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil,
            { (soundId, clientData) -> Void in AudioServicesDisposeSystemSoundID(soundId)}, nil)
        AudioServicesPlaySystemSound(soundId)
        }
//        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "mySoundFile", ofType: "wav")!)
//        audioPlayer = try! AVAudioPlayer(contentsOf: alertSound as URL, fileTypeHint: nil)
//        audioPlayer.prepareToPlay()
//        audioPlayer.play()
    }
    
    func setUpViews()
    {
//        let cyanSquare = UIView(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
//        cyanSquare.backgroundColor = UIColor.cyan
//        view.addSubview(cyanSquare)
//        collisionBehavior.addItem(cyanSquare)
//        if (ballView != nil)
//        {
//            cyanSquare.backgroundColor = UIColor.clear
//            collisionBehavior.removeItem(cyanSquare)
//        }
        var xPosition = 11
        var yPosition = 20
        let brickWidth = Int((screenWidth - 50)/5)
        let brickHeight = 20
        
        for i in 0...2
        {
            for i in 0...4
            {
            let brick = UIView(frame: CGRect(x: xPosition, y: yPosition, width: brickWidth, height: brickHeight))
            brick.backgroundColor = UIColor.blue
            view.addSubview(brick)
            xPosition += brickWidth + 10
            countBrick += 1
            brickArray.append(brick)
            allViewsArray.append(brick)
            print(brickArray.count)
            }
        xPosition = 11
        yPosition += brickHeight + 10
        }
    }
    
    func winAlert()
    {
        let alert = UIAlertController(title: "You won!", message: "Winner", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "woohoo!", style: .default, handler: { (alert) in
            self.paddleView.backgroundColor = .clear
            self.allViewsArray.removeAll()
            self.ballDynamicItem.isAnchored = false
            self.ballView.center = CGPoint(x: 157, y: 212)
            self.setUpViews()
            self.ballMove()
            self.paddleMove()
            self.brickMove()
            self.pushAction()
            self.collisionAction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func lostAlert()
    {
        let alert = UIAlertController(title: "You lost", message: "Want to play again?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (alert) in
            self.allViewsArray.removeAll()
            self.ballDynamicItem.isAnchored = false
            self.ballView.center = CGPoint(x: 157, y: 212)
            self.setUpViews()
            self.ballMove()
            self.paddleMove()
            self.brickMove()
            self.pushAction()
            self.collisionAction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
