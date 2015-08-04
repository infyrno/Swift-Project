//  FinalBossController.swift
//  CompletionIsAStretchGoel
//  Created by CISStudents
//  Copyleft 2015

import UIKit
import AVFoundation

// this controls the boss level
// the boss level is built on a tableview controller
// the tableview controller acts as a background
// this level is completed by flipping all switches in the stage
// aliens will randomly fall down the stage as the player tries to beat it


class FinalBossController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var Manish: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var aliens = [UIAlien]();
    var boss = [UIAlien]();
    
    var bulletValue : Float = 0.0;
    var bulletAngle : Float = 0.2;
    var bulletRadius : CGFloat = 14.0;
    
    var won : Bool = false;
    
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
        var alienVerticalDistance : CGFloat = 65;
        
        init (view: UIView, x: CGFloat, y: CGFloat) {
            
            self.view = view;
            self.xStart = x;
            self.yStart = y;
            self.yEnd = y + alienVerticalDistance;
            
        }
        
        func getX() -> CGFloat {
            return view.frame.origin.x;
        }
        
        func getY() -> CGFloat {
            return view.frame.origin.y;
        }
        
        func getWidth() -> CGFloat {
            return view.bounds.width;
        }
        
        func getHeight() -> CGFloat {
            return view.bounds.height;
        }
        
    }
    
    func animateDown(alien : UIAlien){
        
        UIView.animateWithDuration( 0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.AllowUserInteraction, animations:
            {
                
                alien.view.frame = CGRect(x: alien.getX(), y: alien.getY() + 1, width: alien.getWidth(), height: alien.getHeight());
                
            }, completion: { (finished: Bool) -> Void in
                
                if (alien.view.superview != nil && (alien.getY() > self.Manish.frame.minY) && self.won == false) {
                    let alertController = UIAlertController(title: "Manish Down!", message: "You failed to defeat the invading UIViews!", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "I'll definitely pass next time!", style: .Default, handler: nil))
                    self.presentViewController(alertController, animated: false, completion: nil)
                    self.view.layer.removeAllAnimations();
                    self.clearAliens();
                    self.won = true;
                    self.tabBarController?.selectedIndex = 0;
                } else {
                    self.animateDown(alien);
                }
                
        })
        
    }
    
    func viewCollision( view : UIView, point : CGPoint, radius : CGFloat ) -> Bool {
        var tl = view.frame.origin;
        var br = CGPoint( x: tl.x + view.bounds.width, y: tl.y + view.bounds.height );
        if ( point.x >= tl.x - radius && point.x <= br.x + radius && point.y >= tl.y - radius && point.y <= br.y + radius ) {
            return true;
        }
        return false;
    }
    
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
    
    func fire() {
        UIView.animateWithDuration(0.02, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.setValue(self.bulletValue, animated: true);
            }, completion: { (finished: Bool) -> Void in
                self.bulletValue += 0.05;
                if (self.bulletValue <= 1.05) {
                    
                    var bulletX : CGFloat = (CGFloat(self.bulletValue) * self.slider.bounds.size.width) * CGFloat(cos(-3.14159265 * self.bulletAngle));
                    var bulletY : CGFloat = (CGFloat(self.bulletValue) * self.slider.bounds.size.width) * CGFloat(sin(-3.14159265 * self.bulletAngle));
                    var bulletPoint : CGPoint = CGPoint(x: bulletX + self.slider.center.x, y: bulletY + self.slider.center.y);
                    
                    if (self.aliens.count != 0) {
                    
                        for index in 0...(self.aliens.count-1) {
                            
                            var collision : UIAlien = self.aliens[index];
                            
                            if ( self.viewCollision(collision.view, point: bulletPoint, radius: self.bulletRadius) ) {
                                if ((collision.view.superview) != nil) {
                                    collision.view.removeFromSuperview();
                                    self.aliens.removeAtIndex(index);
                                    self.slider.thumbTintColor = self.view.tintColor;
                                    self.unfire();
                                    self.Beep.play();
                                    return;
                                }
                            }
                            
                        }
                        
                    }
                    
                    for collision : UIAlien in self.boss {
                        
                        if ( self.viewCollision(collision.view, point: bulletPoint, radius: self.bulletRadius) ) {
                            if ((collision.view.superview) != nil) {
                                var sw : UISwitch? = collision.view as? UISwitch;
                                if (sw?.on != nil && sw?.on == true) {
                                    sw?.setOn( false, animated: true );
                                } else {
                                    sw?.setOn( true, animated: true );
                                }
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
    
    func unfire() {
        UIView.animateWithDuration(0.025, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.slider.setValue(self.bulletValue, animated: true);
            }, completion: { (finished: Bool) -> Void in
                self.bulletValue -= 0.05;
                if (self.bulletValue >= 0.0) {
                    self.unfire();
                } else {
                    self.bulletValue = 0.0;
                    self.slider.setValue(0.0, animated: false);
                    self.slider.thumbTintColor = UIColor.whiteColor();
                }
        });
    }
    
    func winCondition(){
        var killed : Int = 0
        for count : UIAlien in self.boss {
            var sw : UISwitch? = count.view as? UISwitch;
            if (sw?.on != nil && sw?.on == false) {
                killed++;
            }
        }
        if (killed >= self.boss.count) {
            self.won = true;
            self.view.layer.removeAllAnimations();
            var tabBar : UITabBar = self.tabBarController!.tabBar;
            var tabBarItem : UITabBarItem = tabBar.items?[4] as UITabBarItem;
            tabBarItem.enabled = true;
            self.tabBarController?.selectedIndex = 4;
        }
    }
    
    @IBAction func fireSlider(sender: UIButton) {
        if (bulletValue == 0.0) {
            bulletValue = 0.025;
            fire();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        Beep = self.setupAudioPlayerWithFile("BEEP", type: "wav")
        self.Beep.play()
        
        self.slider.layer.anchorPoint = CGPointMake(0.0, 0.5);
        self.slider.setThumbImage( self.slider.currentThumbImage, forState: UIControlState.Normal);
        self.slider.thumbTintColor = UIColor.whiteColor();
        
        sliderRotate();
    }
    
    func clearAliens() {
        for collision : UIAlien in self.aliens {
            collision.view.removeFromSuperview();
        }
        aliens.removeAll(keepCapacity: false);
        
        for collision : UIAlien in self.boss {
            collision.view.removeFromSuperview();
        }
        boss.removeAll(keepCapacity: false);
        
    }
    
    func spawnLoop() {
        UIView.animateWithDuration( 0.5, delay: 4.5, options: .CurveLinear | .AllowUserInteraction, animations: {
            self.Manish.frame.origin.x += 0.5;
            }, completion: { (finished: Bool) -> Void in

                if (self.aliens.count < 4) {
                    let type = CGFloat( arc4random_uniform(30) );
                
                    if (type > 15) {
                        self.addButtonToView( CGFloat( 30 + arc4random_uniform(300) ), y: 90, w: 75, h: 75/2 );
                    } else {
                        self.addStepperToView( CGFloat( 30 + arc4random_uniform(300) ), y: 90, w: 100, h: 75/2 );
                    }
                    self.view.layer.removeAllAnimations();
                }
                self.spawnLoop();
        });
    }
    
    override func viewDidAppear(animated : Bool) {
        
        clearAliens();
        self.view.layer.removeAllAnimations();
        self.won = false;
        
        var xStart : CGFloat = 30;
        var yStart : CGFloat = 70;

        let switchSeparation : CGFloat = 70;
        let switchWidth : CGFloat = 75;
        let switchHeight : CGFloat = 75/2;
        
        let numberOfSwitches : Int = 5;
        
        var counter : Int = 0
        
        for loopNum in 1...numberOfSwitches
        {
            addSwitchToView(xStart, y: yStart, w: switchWidth, h: switchHeight);
            xStart += switchSeparation;
        }
        
        spawnLoop();
    }
    
    func addButtonToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        
        let b = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        b.frame = CGRectMake(x, y, w, h)
        b.setTitle(" Button", forState: .Normal)
        b.addTarget(self, action: "ButtonAction:", forControlEvents: .TouchUpInside)
        
        let alien = UIAlien(view: b, x: x, y: y)
        self.view.addSubview(alien.view)
        self.aliens.append(alien)
        
        animateDown(alien)
    }
    
    func addStepperToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat){
        
        let s = UIStepper()
        s.frame = CGRectMake(x, y, w, h)
        s.addTarget(self, action: "StepAction:", forControlEvents: .ValueChanged)
        
        let alien = UIAlien(view: s, x: x, y: y)
        self.view.addSubview(alien.view)
        self.aliens.append(alien)
        
        animateDown(alien)
        
    }
    
    func addSwitchToView(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat) {
        
        let s = UISwitch()
        s.frame = CGRectMake(x, y, w, h)
        s.setOn(true, animated: false);
        s.addTarget(self, action: "SwitchAction:", forControlEvents: .TouchUpInside)
        
        let alien = UIAlien(view: s, x: x, y: y)
        self.view.addSubview(alien.view)
        self.boss.append(alien)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func ButtonAction(sender: UIButton) {
        Beep.play()
    }
    
    func StepAction(sender: UIStepper) {
        Beep.play()
    }
    
    func SwitchAction(Sender: UISwitch) {
        self.winCondition();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell();
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
}
