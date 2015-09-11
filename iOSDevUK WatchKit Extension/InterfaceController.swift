//
//  InterfaceController.swift
//  iOSDevUK
//
//  Created by chris on 10/09/2015.
//  Copyright © 2015 CMG Research Ltd. All rights reserved.
//

import WatchKit
import Foundation



func loadSound(name: String) -> WKAudioFilePlayer {
    let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "caf")!
    let fileUrl = NSURL.fileURLWithPath(filePath)
    let asset = WKAudioFileAsset(URL: fileUrl)
    let playerItem = WKAudioFilePlayerItem(asset: asset)
    return WKAudioFilePlayer(playerItem: playerItem)
}

class InterfaceController: WKInterfaceController {
    @IBOutlet var controller: WKInterfacePicker!
    @IBOutlet var gameGroup: WKInterfaceGroup!
    @IBOutlet var ballAreaGroup: WKInterfaceGroup!
    @IBOutlet var leftBatAreaGroup: WKInterfaceGroup!
    @IBOutlet var rightBatAreaGroup: WKInterfaceGroup!
    @IBOutlet var leftBatArea: WKInterfaceGroup!
    @IBOutlet var rightBatArea: WKInterfaceGroup!
    @IBOutlet var leftBatYPosGroup: WKInterfaceGroup!
    @IBOutlet var rightBatYPosGroup: WKInterfaceGroup!
    
    @IBOutlet var ballYposGroup: WKInterfaceGroup!
    @IBOutlet var ballXposGroup: WKInterfaceGroup!
    
    let batWidth : CGFloat = 5
    let batHeight : CGFloat = 50
    
    let ballRadius : CGFloat = 5
    
    let screenWidth = WKInterfaceDevice.currentDevice().screenBounds.width
    let screenHeight = WKInterfaceDevice.currentDevice().screenBounds.height;
    
    var gameWidth : CGFloat = 0
    var gameHeight : CGFloat = 0
    
    var userYpos = WKInterfaceDevice.currentDevice().screenBounds.height/2
    var computerYpos = WKInterfaceDevice.currentDevice().screenBounds.height/2
    
    var ballX = WKInterfaceDevice.currentDevice().screenBounds.width/2
    var ballY = WKInterfaceDevice.currentDevice().screenBounds.height/2
    
    var computerSpeed : CGFloat = 0.05
    var computerDy : CGFloat = 0.0
    
    var speed : CGFloat = 2000
    var ballDx : CGFloat = (rand()%2==0) ? -1 : 1
    var ballDy : CGFloat = CGFloat((rand()%100) - 50)/50.0
    
    var lastTime: NSTimeInterval = 0
    
    var userScore : Int = 0
    var computerScore : Int = 0
    
//    var failedPlayer: WKAudioFilePlayer = loadSound("failed")
//    var bouncePlayer: WKAudioFilePlayer = loadSound("bounce")
    
    @IBAction func controllerAction(value: Int) {
        userYpos = screenHeight * CGFloat(20 - value) / 20.0;
        if(userYpos - batHeight/2 < 0) {
            userYpos = batHeight/2;
        }
        if(userYpos + batHeight/2 > gameHeight) {
            userYpos = gameHeight - batHeight/2;
        }
        leftBatYPosGroup.setHeight(userYpos - batHeight/2);
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        var items = [WKPickerItem]()
        for(var i=0; i < 20; i++) {
            items.append(WKPickerItem());
        }
        controller!.setItems(items)
        controller!.setSelectedItemIndex(10);
        controller!.focus()
        
        gameWidth = screenWidth - 10;
        gameHeight = screenHeight - 15;
        gameGroup.setWidth(gameWidth);
        gameGroup.setHeight(gameHeight);
        
        leftBatAreaGroup.setWidth(batWidth);
        rightBatAreaGroup.setWidth(batWidth);
        ballAreaGroup.setWidth(gameWidth - 2 * batWidth);
        leftBatArea.setHeight(batHeight);
        rightBatArea.setHeight(batHeight);
        leftBatYPosGroup.setHeight(gameHeight/2 - batHeight/2);
        rightBatYPosGroup.setHeight(gameHeight/2 - batHeight/2);
        
        NSTimer.scheduledTimerWithTimeInterval(1.0 / 30.0, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func update() {
        let currentTime = NSDate().timeIntervalSince1970
        if(lastTime == 0) {
            lastTime = currentTime
        }
        let delta : CGFloat = CGFloat(currentTime - lastTime);
        simulate(delta);
        
        rightBatYPosGroup.setHeight(computerYpos - batHeight/2);
        ballXposGroup.setWidth(max(0, ballX - ballRadius));
        ballYposGroup.setHeight(max(0, ballY - ballRadius));
        lastTime = currentTime
    }
    
    func simulate(delta : CGFloat) {
        ballX += speed * delta * ballDx / 30.0;
        ballY += speed * delta * ballDy / 30.0;
        if(ballDx < 0 && (ballX < ballRadius && ballY > userYpos - batHeight / 2 && ballY < userYpos + batHeight / 2)) {
            let cludge : CGFloat = ballY - userYpos
            ballDy += 0.5 * cludge / batHeight
            ballDx = -ballDx;
            if(ballDy > 1.0) {
                ballDy = 1.0;
            }
            if(ballDy < 1.0) {
                ballDy = -1.0
            }
            WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)
//            bouncePlayer.play()
        } else if(ballDx > 0 && (ballX > gameWidth - 2*ballRadius && ballY > computerYpos - batHeight / 2 && ballY < computerYpos + batHeight / 2)) {
            let cludge : CGFloat = ballY - userYpos
            ballDy += 0.5 * cludge / batHeight
            if(ballDy > 1.0) {
                ballDy = 1.0;
            }
            if(ballDy < 1.0) {
                ballDy = -1.0
            }
            ballDx = -ballDx
//            bouncePlayer.play()
        } else  if(ballX > screenWidth + ballRadius) {
            userScore = userScore + 1
            
            
            ballDx = (rand()%2==0) ? -1 : 1
            ballDy = CGFloat((rand()%100) - 50)/100.0
            ballX = screenWidth/2
            ballY = screenHeight/2
            WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Failure)
//            failedPlayer.play()
        } else if(ballX  < ballRadius) {
            computerScore = computerScore + 1
            
            ballDx = (rand()%2==0) ? -1 : 1
            ballDy = CGFloat((rand()%100) - 50)/50.0
            ballX = screenWidth/2
            ballY = screenHeight/2
//            failedPlayer.play()
        }
        
        
        if(ballY < ballRadius || ballY > gameHeight - ballRadius) {
            ballDy = -ballDy
        }
        
        if(ballY < computerYpos || ballY > computerYpos) {
            computerDy = 0.01*(ballY - computerYpos)
        }
        if(computerDy > computerSpeed) {
            computerDy = computerSpeed
        }
        if(computerDy < -computerSpeed) {
            computerDy = -computerSpeed
        }
        computerYpos += speed * delta * computerDy
        
        if(computerYpos - batHeight/2 < 0) {
            computerYpos = batHeight/2
        }
        if(computerYpos > gameHeight - batHeight/2) {
            computerYpos = gameHeight - batHeight/2
        }
    }
}
