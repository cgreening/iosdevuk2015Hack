//
//  InterfaceController.swift
//  iOSDevUK
//
//  Created by chris on 10/09/2015.
//  Copyright © 2015 CMG Research Ltd. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var picker: WKInterfacePicker!
    
    let batWidth : CGFloat = 5
    let batHeight : CGFloat = 40
    
    let ballRadius : CGFloat = 5
    
    let screenWidth = WKInterfaceDevice.currentDevice().screenBounds.width
    let screenHeight = WKInterfaceDevice.currentDevice().screenBounds.height - 20
    
    var userYpos = WKInterfaceDevice.currentDevice().screenBounds.height/2
    var userDy : CGFloat = 0
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
    
    @IBAction func upButton() {
        if(userYpos > batHeight/2) {
            userYpos-=5
        }
        userDy = 0
    }
    
    @IBAction func downButton() {
        if(userYpos < screenHeight - batHeight/2) {
            userYpos+=5
        }
        userDy = 0
    }
    
    @IBAction func pickerAction(value: Int) {
        if(value == 0) {
            userDy = 100
        } else if(value == 2) {
            userDy = -100
        } else {
            userDy = 0
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        picker!.setItems([WKPickerItem(), WKPickerItem(), WKPickerItem()])
        picker!.setSelectedItemIndex(1);
        picker!.focus()
        NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func update() {
        let currentTime = NSDate().timeIntervalSince1970
        if(lastTime == 0) {
            lastTime = currentTime
        }
        let delta : CGFloat = CGFloat(currentTime - lastTime);
        simulate(delta);
        draw();
        lastTime = currentTime
    }
    
    func simulate(delta : CGFloat) {
        ballX += speed * delta * ballDx/30.0;
        ballY += speed * delta * ballDy/30.0;
        if(ballDx < 0 && (ballX < 2*ballRadius && ballY > userYpos - batHeight / 2 && ballY < userYpos + batHeight / 2)) {
            let cludge : CGFloat = ballY - userYpos
            ballDy += 0.5 * cludge / batHeight
            ballDx = -ballDx;
            if(ballDy > 1.0) {
                ballDy = 1.0;
            }
            if(ballDy < 1.0) {
                ballDy = -1.0
            }
        } else if(ballDx > 0 && (ballX > screenWidth - 2*ballRadius && ballY > computerYpos - batHeight / 2 && ballY < computerYpos + batHeight / 2)) {
            let cludge : CGFloat = ballY - userYpos
            ballDy += 0.5 * cludge / batHeight
            if(ballDy > 1.0) {
                ballDy = 1.0;
            }
            if(ballDy < 1.0) {
                ballDy = -1.0
            }
            ballDx = -ballDx
        } else  if(ballX > screenWidth - ballRadius) {
            userScore = userScore + 1
            ballDx = (rand()%2==0) ? -1 : 1
            ballDy = CGFloat((rand()%100) - 50)/100.0
            ballX = screenWidth/2
            ballY = screenHeight/2
        } else if(ballX < ballRadius) {
            computerScore = computerScore + 1
            ballDx = (rand()%2==0) ? -1 : 1
            ballDy = CGFloat((rand()%100) - 50)/50.0
            ballX = screenWidth/2
            ballY = screenHeight/2
        }
        
        
        if(ballY < ballRadius*2 || ballY > screenHeight + ballRadius*2) {
            ballDy = -ballDy
        }
        
        if(ballY < computerYpos || ballY > computerYpos) {
            computerDy = (ballY - computerYpos)
        }
        if(computerDy > computerSpeed) {
            computerDy = computerSpeed
        }
        if(computerDy < -computerSpeed) {
            computerDy = -computerSpeed
        }
        computerYpos += speed * delta * computerDy
        
        userYpos += delta * userDy
        if(userYpos < 0) {
            userYpos = 0
        }
        if(userYpos > screenHeight) {
            userYpos = screenHeight
        }
    }
    
    func draw() {
        UIGraphicsBeginImageContext(CGSize(width: screenWidth,height: screenHeight));
        let context : CGContext = UIGraphicsGetCurrentContext()!;
        CGContextTranslateCTM(context, 0, -20);
        // draw the user bat
        CGContextSetFillColorWithColor(context, UIColor.greenColor().CGColor)
        CGContextFillRect(context, CGRect(x: 0, y: userYpos - batHeight/2, width: batWidth, height: batHeight));
        // draw the computer bat
        CGContextSetFillColorWithColor(context, UIColor.redColor().CGColor)
        CGContextFillRect(context, CGRect(x: screenWidth - batWidth, y: computerYpos - batHeight/2, width: batWidth, height: batHeight));
        // draw the ball
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillEllipseInRect(context, CGRect(x: ballX - ballRadius, y: ballY - ballRadius, width: ballRadius*2, height: ballRadius*2))
        let uiImage = UIGraphicsGetImageFromCurrentImageContext();
        mainGroup.setBackgroundImage(uiImage);
        UIGraphicsEndImageContext()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
