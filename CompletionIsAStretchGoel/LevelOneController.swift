//  LevelOneController.swift
//  CompletionIsAStretchGoel
//  Created by CISStudents
//  Copyleft 2015

import UIKit
import AVFoundation

// this controls the first level.
// all movement is started when the tab is opened which loads all aliens
// all buttons are loaded programatically rather than through storyboard

class LevelOneController: UIViewController {
   
    @IBOutlet weak var Manish: UIButton!
    @IBOutlet weak var slider: UISlider!
    var aliens = [UIAlien]()
    
    var bulletValue : Float = 0.0;
    var bulletAngle : Float = 0.2;
    var bulletRadius : CGFloat = 14.0;
    
    var clickCount : Int = 0;
    
    var flag : Bool = true
    var Beep = AVAudioPlayer()
    
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer  {
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        
        var audioPlayer:AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        return audioPlayer!
    }
   
    class UIAlien {

        var view : UIView;
        
        var xStart : CGFloat = 0;
        var yStart : CGFloat = 0;
        var yEnd : CGFloat = 0;
        
        var alienHorizontalDistance : CGFloat = 150;
        var alienVerticalDistance : CGFloat = 45;
        
        init (view: UIView, x: CGFloat, y: CGFloat) {
            
            self.view = view;
            self.xStart = x;
            self.yStart = y;
            self.yEnd = y + alienVerticalDistance;
            
        }
        
        // this returns the x location
        func getX() -> CGFloat {
            return view.frame.origin.x;
        }
        
        // this returns the y location
        func getY() -> CGFloat {
            return view.frame.origin.y;
        }
        
        // this returns the width
        func getWidth() -> CGFloat {
            return view.bounds.width;
        }
        
        // this returns the height
        func getHeight() -> CGFloat {
            return view.bounds.height;
        }

    }
    
    // this function controls the movement to the right
    // completion test cases determine  when to stop moving right as the alien moves incrementally in small amounts
    func animateRight (alien : UIAlien) {
        
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.AllowUserInteraction, animations:
        {
            alien.view.frame = CGRect(x: alien.getX() + 1, y: alien.getY(), width: alien.getWidth(), height : alien.getHeight());
            
        }, completion: { (finished: Bool) -> Void in
            // this loop checks to see if the x location has reached the horizontal distance to be moved
            // if it has not reached the proper amount then it will move down.  otherwise it will continue to move right.
                if (alien.getX() >= (alien.xStart + alien.alienHorizontalDistance)) {
                    self.animateDown(alien);
                } else {
                    self.animateRight(alien);
                }
        })
        
    }

    // this function controls the movement down
    // completion test cases determine when to stop moving down and switch to left or right
    // test for game over to trigger the loss screen
    func animateDown(alien : UIAlien){
        
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.AllowUserInteraction, animations:
        {
                
            alien.view.frame = CGRect(x: alien.getX(), y: alien.getY() + 1, width: alien.getWidth(), height: alien.getHeight());
            
        }, completion: { (finished: Bool) -> Void in
            // when completed will test to see where the y position is
            if (alien.getY() >= alien.yEnd) {
                    
                alien.yEnd += alien.alienVerticalDistance;
                
                // checks for the x location to see if you are on the left or right side of the screen.  this is to determine if you want to move left or right next
                if (alien.getX() >= alien.xStart + alien.alienHorizontalDistance) {
                    self.animateLeft(alien);
                } else {
                    self.animateRight(alien);
                }
            // this is the test for gameover
            // compares the current down movement to the location of the bottom bar, if passed the bar will trigger gameover
            } else if (alien.view.superview != nil && (alien.getY() > self.Manish.frame.minY)) {
                let alertController = UIAlertController(title: "Manish Down!", message: "You failed to defeat the invading UIViews!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "I'll definitely pass next time!", style: .Default, handler: nil))
                self.view.layer.removeAllAnimations();
                self.presentViewController(alertController, animated: false, completion: nil)
                self.clearAliens();
                self.tabBarController?.selectedIndex = 0;
            } else {
                self.animateDown(alien);
            }

        })
        
    }
    
    // moves alien down
    // similar to animateRight
    // future build could combine the two functions with check statments similar to down function
    func animateLeft(alien : UIAlien){
        
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.AllowUserInteraction, animations:
        {
            alien.view.frame = CGRect(x: alien.getX() - 1, y: alien.getY(), width: alien.getWidth(), height : alien.getHeight());
        }, completion: { (finished: Bool) -> Void in
            
            if (alien.getX() <= (alien.xStart)) {
                self.animateDown(alien);
            } else {
                self.animateLeft(alien);
            }
        })
    }

    // checks for the collision
    // checks if the circle collides with the box created from the corner locations
    func viewCollision( view : UIView, point : CGPoint, radius : CGFloat ) -> Bool {
        var tl = view.frame.origin;
        var br = CGPoint( x: tl.x + view.bounds.width, y: tl.y + view.bounds.height );
        if ( point.x >= tl.x - radius && point.x <= br.x + radius && point.y >= tl.y - radius && point.y <= br.y + radius ) {
            return true;
        }
        return false;
    }
    
    // this function controls the rotation of the slider that causes it to sweep right
    func sliderRotate() {
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.transform = CGAffineTransformMakeRotation( CGFloat(-3.14159265 * self.bulletAngle) );
            }, completion: { (finished: Bool) -> Void in
                self.bulletAngle += 0.005;
                if (self.bulletAngle <= 0.8) {
                    self.sliderRotate();
                } else {
                    self.bulletAngle = 0.8;
                    self.slider.transform = CGAffineTransformMakeRotation( -3.14159265 * 0.8 );
                    self.sliderUnrotate();
                }
        });
    }
    
    // this function controls the rotation of the slider that causes it to sweep left
    func sliderUnrotate() {
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.transform = CGAffineTransformMakeRotation( CGFloat(-3.14159265 * self.bulletAngle) );
            }, completion: { (finished: Bool) -> Void in
                self.bulletAngle -= 0.005;
                if (self.bulletAngle >= 0.2) {
                    self.sliderUnrotate();
                } else {
                    self.bulletAngle = 0.2;
                    self.slider.transform = CGAffineTransformMakeRotation( -3.14159265 * 0.2 );
                    self.sliderRotate();
                }
        });
    }
    
    // fires the circle of the slider
    // this only controls the circle moving forward
    // when something is "hit" or the slider reaches the end it calls the reverse function "unfire"
    func fire() {
        UIView.animateWithDuration(0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.setValue(self.bulletValue, animated: true);
            }, completion: { (finished: Bool) -> Void in
                self.bulletValue += 0.025;
                if (self.bulletValue <= 1.05) {
                    
                    var bulletX : CGFloat = (CGFloat(self.bulletValue) * self.slider.bounds.size.width) * CGFloat(cos(-3.14159265 * self.bulletAngle));
                    var bulletY : CGFloat = (CGFloat(self.bulletValue) * self.slider.bounds.size.width) * CGFloat(sin(-3.14159265 * self.bulletAngle));
                    var bulletPoint : CGPoint = CGPoint(x: bulletX + self.slider.center.x, y: bulletY + self.slider.center.y);
                    
                    for collision : UIAlien in self.aliens {
                        
                        if ( self.viewCollision(collision.view, point: bulletPoint, radius: self.bulletRadius) ) {
                            if ((collision.view.superview) != nil) {
                                collision.view.removeFromSuperview();
                                self.slider.thumbTintColor = self.view.tintColor;
                                self.unfire();
                                self.Beep.play();
                                self.winCondition();
                                return;
                            }
                        }
                        
                    }
                    if (bulletPoint.x >= self.view.bounds.width - self.bulletRadius || bulletPoint.x <= self.bulletRadius) {
                        self.slider.thumbTintColor = self.view.tintColor;
                        self.unfire();
                        self.Beep.play();
                        return;
                    }
                    
                    self.fire();
                } else {
                    self.bulletValue = 1.0;
                    self.slider.setValue(1.0, animated: false);
                    self.slider.thumbTintColor = self.view.tintColor;
                    self.unfire();
                    self.Beep.play();
                }
        });
    }
    // this function returns the circle into
    func unfire() {
        UIView.animateWithDuration(0.025, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.setValue(self.bulletValue, animated: true);
            }, completion: { (finished: Bool) -> Void in
                self.bulletValue -= 0.025;
                if (self.bulletValue >= 0.0) {
                    self.unfire();
                } else {
                    self.bulletValue = 0.0;
                    self.slider.setValue(0.0, animated: false);
                    self.slider.thumbTintColor = UIColor.whiteColor();
                }
        });
    }
    
    // this allows you to move on to the next "stage"
    func winCondition(){
        var killed : Int = 0
        for count : UIAlien in self.aliens{
            if(count.view.superview == nil)
            {
                killed++
            }
        }
        if (killed >= self.aliens.count){
            let alertController = UIAlertController(title: "Level One Passed!", message: "You've defeated the evil UIViews and received a Make Up Slider - your slider now moves at double the speed! Select the Level Two tab to move forward.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Okay!", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: false, completion: nil)
            self.view.layer.removeAllAnimations();
            var tabBar : UITabBar = self.tabBarController!.tabBar;
            var tabBarItem : UITabBarItem = tabBar.items?[2] as UITabBarItem;
            tabBarItem.enabled = true;
            clearAliens();
        }
    }
    // will initialize fire
    @IBAction func fireSlider(sender: AnyObject) {
        if (bulletValue == 0.0) {
            bulletValue = 0.025;
            fire();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        Beep = self.setupAudioPlayerWithFile("BEEP", type: "wav")
        // this initializes the beep at startup to prevent loading lag mid game
        self.Beep.play()
        
        self.slider.layer.anchorPoint = CGPointMake(0.0, 0.5);
        self.slider.setThumbImage( self.slider.currentThumbImage, forState: UIControlState.Normal);
        self.slider.thumbTintColor = UIColor.whiteColor();
        
        sliderRotate();
    }
    
    
    // allows removal of aliens
    func clearAliens() {
        for collision : UIAlien in self.aliens {
            collision.view.removeFromSuperview();
        }
        aliens.removeAll(keepCapacity: false);
    }
    
    
    override func viewDidAppear(animated : Bool) {
        super.viewDidLoad()
        
        // Clear & Generate Aliens
        
        clearAliens();
        
        var xStart : CGFloat = 0
        var yStart : CGFloat = 30
        var lossLine : CGFloat
        let buttonSeparation : CGFloat = 75
        let switchSeparation : CGFloat = 80
        let stepSeparation : CGFloat = 120
        
        let buttonWidth : CGFloat = 75
        let switchWidth : CGFloat = 75
        let stepWidth : CGFloat = 100
        
        let height : CGFloat = 75 / 2
        
        let numberOfButtons : Int = 3
        let numberOfSwitches : Int = 3
        let numberOfSteps : Int = 2
        
        var rowsOfEnemies : Int = 3
        
        var counter : Int = 0
        
        // this loops through the rows to create the aliens of different types on the screen
        for loopNum in 1...rowsOfEnemies
        {
            if (counter % 3 == 0) {
                
                for loopNum in 1...numberOfButtons {
                    addButtonToView(xStart, y: yStart, w: buttonWidth, h: height)
                    xStart += buttonSeparation
                }
                xStart = 0
                
            } else if (counter % 3 == 1) {

                for loopNum in 1...numberOfSwitches {
                    addSwitchToView(xStart, y: yStart + 5, w: switchWidth, h: height)
                    xStart += switchSeparation
                }
                xStart = 0
                
            } else {
                
                for loopNum in 1...numberOfSteps {
                    addStepperToView(xStart, y: yStart + 10, w: stepWidth, h : height)
                    xStart += stepSeparation
                }
                xStart = 0
            }
            
            counter++
            yStart += height
            
        }

    }
    
    // this creates the "button" enemy
    func addButtonToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        
        let b = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        b.frame = CGRectMake(x, y, w, h)
        b.setTitle(" Button", forState: .Normal)
        b.addTarget(self, action: "ButtonAction:", forControlEvents: .TouchUpInside)
        
        let alien = UIAlien(view: b, x: x, y: y)
        self.view.addSubview(alien.view)
        self.aliens.append(alien)
        animateRight(alien)
        
    }
    
    // this creates the "switch" enemy
    func addSwitchToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        
        let s = UISwitch()
        s.frame = CGRectMake(x, y, w, h)
        s.addTarget(self, action: "SwitchAction:", forControlEvents: .TouchUpInside)
        
        let alien = UIAlien(view: s, x: x, y: y)
        self.view.addSubview(alien.view)
        self.aliens.append(alien)
        animateRight(alien)
        
    }
    
    // this creates the "stepper" enemy
    func addStepperToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        
        let s = UIStepper()
        s.frame = CGRectMake(x, y, w, h)
        s.addTarget(self, action: "StepAction:", forControlEvents: .ValueChanged)
        
        let alien = UIAlien(view: s, x: x, y: y)
        self.view.addSubview(alien.view)
        self.aliens.append(alien)
        animateRight(alien)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // the buttons have specific actions when clicked multiple times
    // this function controls the different messages as well as the "army" of new buttons if clicked multiple times
    func ButtonAction(sender: UIButton) {
        
            if clickCount == 0
            {
                let alertController = UIAlertController(title: "NO", message: "pls stahp!!!11!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "meh :<", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
                clickCount++
            }
            else if clickCount == 1
            {
                let alertController = UIAlertController(title: "WHY?!?", message: "Y U NO STAP", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "HA? STOP NOW?", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
                clickCount++
            }
            else if clickCount == 2
            {
                let alertController = UIAlertController(title: "RAWRRRRRRRRR", message: "BUTTON ANGRY!!!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "uhoh...", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
                clickCount++
            }
            else if clickCount == 3
            {
                let alertController = UIAlertController(title: "WE WARNED YOU", message: "THIS IS YOUR FAULT!!!", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "why stop now...", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)

                addButtonToView(0, y: 20, w: 75, h: 75 * 3/8)
                addButtonToView(75, y: 20, w: 75, h: 75 * 3/8)
                addButtonToView(75 * 2, y: 20, w: 75, h: 75 * 3/8)
                
                addButtonToView(0, y: 50, w: 75, h: 75 * 3/8)
                addButtonToView(75, y: 50, w: 75, h: 75 * 3/8)
                addButtonToView(75 * 2, y: 50, w: 75, h: 75 * 3/8)
                
                addButtonToView(0, y: 80, w: 75, h: 75 * 3/8)
                addButtonToView(75, y: 80, w: 75, h: 75 * 3/8)
                addButtonToView(75 * 2, y: 80, w: 75, h: 75 * 3/8)
                
                clickCount++
            }
            else if clickCount >= 4
            {
                let alertController = UIAlertController(title: "NO MERCY", message: "THE ARMY IS HERE", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "...", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: false, completion: nil)
                clickCount++
            }
            
        }
    
    // controls the stepper functionality.  creates a beep sound
    func StepAction(sender: UIStepper) {
        Beep.play()
    }
    
    // controls the switch functinality.  activates "night mode" making the background black
    func SwitchAction(Sender: UISwitch) {
        if (self.flag == true){
            self.flag = false
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            self.flag = true
            self.view.backgroundColor = UIColor.whiteColor()
        }
    }

}

