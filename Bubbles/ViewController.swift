//
//  ViewController.swift
//  Bubbles
//
//  Created by alex oh on 11/9/15.
//  Copyright © 2015 Alex Oh. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVAudioPlayerDelegate {
    
    var session = AVCaptureSession()
    
    var players: [AVAudioPlayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        let captureInput = try? AVCaptureDeviceInput(device: captureDevice!)
        
        if session.canAddInput(captureInput) {
            
            session.addInput(captureInput)
            
        }
        
        let captureOutput = AVCaptureAudioDataOutput()
        
        if session.canAddOutput(captureOutput) {
            
            session.addOutput(captureOutput)
            
        }
        
        captureOutput.setSampleBufferDelegate(self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        
//      captureOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        
        session.startRunning()
        
    }
    
    // The SampleBufferDelegate calls this function whenver captureOutput changes, through the delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        guard let channel = connection.audioChannels.first where channel.averagePowerLevel > -5 else { return print("Not Blowing") }
        
        print("Blowing")
        
        let bubbleSize = CGFloat(arc4random_uniform(15) * 5) + 30
        
        // randomize width & heigth
        let bubble = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: bubbleSize, height: bubbleSize)))
        
        // change based on width / height
        bubble.layer.cornerRadius = bubbleSize / 2

        let colors = [UIColor.blueColor(), UIColor.cyanColor(), UIColor.purpleColor()]
        
        let randomColorIndex = Int(arc4random_uniform(3))
        
        // randomize color between blue and purple
        bubble.layer.borderColor = colors[randomColorIndex].CGColor
        bubble.layer.borderWidth = 1
        bubble.center = CGPoint(x: view.frame.midX, y: view.frame.maxY)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.view.addSubview(bubble)
            
            // change based on the APL
            let randomDuration = Double(abs(channel.averagePowerLevel))
            
            let randomX = CGFloat(arc4random_uniform(UInt32(self.view.frame.maxX)))
            let randomY = CGFloat(arc4random_uniform(UInt32(self.view.frame.maxY)))

            
            UIView.animateWithDuration(randomDuration, delay: 0, options: .CurveEaseOut,
                animations: { () -> Void in
                    
                    
                    // randomize the bubble.center x & y
                    bubble.center.x = randomX
                    bubble.center.y = randomY
                    
                }) { (finished) -> Void in
                    
                    bubble.removeFromSuperview()
                    
                    let popFile = NSDataAsset(name: "Pop")
                    
                    let player = try? AVAudioPlayer(data: popFile!.data)
                    
                    self.players.append(player!)
                    
                    player?.delegate = self
                    player?.play()
                    
                    
            }
            
        }
        
    }

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        
        guard let index = players.indexOf(player) else {return}
        players.removeAtIndex(index)
        
    }
    
}

