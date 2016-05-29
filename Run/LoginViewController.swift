//
//  LoginViewController.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import DeviceKit
import KLCPopup
import Locksmith

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var appIconImageView: UIImageView!
    
    @IBOutlet var loginView: UIView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var copyrightLabel: UILabel!
    
    @IBOutlet var loginViewTopLayoutConstraint: NSLayoutConstraint?
    
    
    // MARK: - Basic var
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    var locationManager: CLLocationManager!
    
    
    
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Login View Controller 之 super.viewDidLoad() 已加載")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //loginView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        //loginView.layer.cornerRadius = 4.0
        loginView.backgroundColor = UIColor.clearColor()
        
        
        loginButton.layer.cornerRadius = 25.0
        loginButton.clipsToBounds = true
        loginButton.backgroundColor = UIColorConfig.GrassGreen
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0)
        loginButton.addTarget(self, action: #selector(self.loginButtonAction), forControlEvents: .TouchUpInside)
        
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        
        copyrightLabel.text = "2016 © He Yifei"
        copyrightLabel.textColor = UIColor.lightGrayColor()
        copyrightLabel.font = UIFont(name: copyrightLabel.font.fontName, size: 13.0)
        
        
        appIconImageView.layer.cornerRadius = 7.0
        appIconImageView.clipsToBounds = true
        
        
        /*
        /*** 僅供測試、實際將使用下方viewWillAppear的函數 ***/
        DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
        self.performSegueWithIdentifier("showDataLoadingView", sender: self)
        */
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DDLogInfo("Login View Controller 之 super.viewDidLayoutSubviews() 已加載")
        
        usernameTextField.layer.addSublayer(getTextFieldBorder(usernameTextField))
        usernameTextField.layer.masksToBounds = true
        
        passwordTextField.layer.addSublayer(getTextFieldBorder(passwordTextField))
        passwordTextField.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Login View Controller 之 super.viewWillAppear() 已加載")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        
        let device = Device()
        DDLogInfo("已獲取用戶目前使用的設備：\(device)")
        // 已於info.plist中「Required device capabilities」加入「bluetooth-le」
        
        
        if(CheckpointFunc().getCheckpoints().count > 0){
            DDLogInfo("目前已有Checkpoints相關數據儲存於本地")
        }else{
            DDLogInfo("目前沒有Checkpoints相關數據儲存於本地、即將顯示下載View")
            Async.main {
                self.performSegueWithIdentifier("showDataLoadingView", sender: self)
            }
        }
        
        
        // 注意：用戶即使刪除並重新安裝應用，UserAccount的Data依然會存在
        if let accountData = Locksmith.loadDataForUserAccount(BasicConfig.UserAccountID) {
            if let username = accountData["username"] {
                if let password = accountData["password"] {
                    DDLogInfo("目前用戶已登入賬戶（\(accountData)）、即將進入主界面")
                    
                    self.usernameTextField.text = "\(username)"
                    self.passwordTextField.text = "\(password)"
                    
                    Async.main {
                        let screenSize: CGRect = UIScreen.mainScreen().bounds
                        
                        let welcomeLabel = UILabel(frame: CGRectMake(0, 0, screenSize.width*0.8, 80.0))
                        welcomeLabel.text = "Welcome back, \(username)!"
                        welcomeLabel.textAlignment = .Center
                        welcomeLabel.backgroundColor = UIColor.whiteColor()
                        welcomeLabel.layer.cornerRadius = 5.0
                        welcomeLabel.clipsToBounds = true
                        
                        let popupController = KLCPopup(contentView: welcomeLabel)
                        popupController.shouldDismissOnContentTouch = true
                        popupController.shouldDismissOnBackgroundTouch = true
                        popupController.maskType = .Dimmed
                        popupController.showType = .GrowIn
                        popupController.dismissType = .GrowOut
                        
                        popupController.willStartDismissingCompletion = {
                            self.showNextView()
                        }
                        
                        let layout = KLCPopupLayoutMake(.Center, .Center)
                        popupController.showWithLayout(layout, duration: 2.0)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        DDLogInfo("Login View Controller 之 super.viewDidDisappear() 已加載")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - General func
    func getTextFieldBorder(textField: UITextField) -> CALayer {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderWidth = borderWidth
        border.borderColor = UIColorConfig.GrassGreen.CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - borderWidth, width: textField.frame.size.width, height: textField.frame.size.height)
        return border
    }
    
    func keyboardNotification(notification: NSNotification) {
        let screenHeight = UIScreen.mainScreen().bounds.height
        DDLogVerbose("已獲取屏幕高度：\(screenHeight)")
        if(screenHeight <= 560.0){          // 如果屏幕比iPhone 5的屏幕還小的話
            // http://stackoverflow.com/a/27135992/2603230
            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
                let duration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
                let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
                let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
                if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                    self.loginViewTopLayoutConstraint?.constant = 0.0
                } else {
                    self.loginViewTopLayoutConstraint?.constant = -60.0 ?? 0.0
                }
                UIView.animateWithDuration(duration, delay: NSTimeInterval(0), options: animationCurve, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
        }
    }
    
    
    // MARK: - TextField func
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(textField == usernameTextField){ // Switch focus to other text field
            passwordTextField.becomeFirstResponder()
        }else if(textField == passwordTextField){
            loginButton.sendActionsForControlEvents(.TouchUpInside)
        }
        
        return true
    }
    
    
    // MARK: - Action func
    func loginButtonAction() {
        if((usernameTextField.text!.isEmpty)||(passwordTextField.text!.isEmpty)){
            BasicFunc().showAlert(self, title: "Notice", message: "Please enter username and password.")
        }else{
            let dataToBeStored = ["username": usernameTextField.text!, "password": passwordTextField.text!]
            
            do {
                try Locksmith.saveData(dataToBeStored, forUserAccount: BasicConfig.UserAccountID)
                DDLogDebug("已儲存用戶名及密碼：\(dataToBeStored)")
                
                showNextView()
            } catch let error as NSError {
                DDLogError("無法儲存用戶名及密碼（\(dataToBeStored)）：\(error)")
                BasicFunc().showErrorAlert(self, error: error)
            }
        }
    }
    
    func showNextView() {
        /*Async.main {
            //self.performSegueWithIdentifier("showPracticeView", sender: self)
            self.performSegueWithIdentifier("showRaceView", sender: self)
        }*/
        
        let noticeAlert = UIAlertController(title: "Please choose the mode you want to enter", message: "You have permission for both Practice Mode and Race Mode.", preferredStyle: .Alert)
        noticeAlert.addAction(UIAlertAction(title: "Practice", style: .Default, handler: { action in
            Async.main {
                self.performSegueWithIdentifier("showPracticeView", sender: self)
            }
        }))
        noticeAlert.addAction(UIAlertAction(title: "Race", style: .Default, handler: { action in
            
            let actionSheetController: UIAlertController = UIAlertController(title: "Checkpoint ID", message: "Please enter your Checkpoint ID.", preferredStyle: .Alert)
            
            let nextAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                self.defaults.setObject(actionSheetController.textFields?[0].text, forKey: "checkpointId")
                Async.main {
                    self.performSegueWithIdentifier("showRaceView", sender: self)
                }
            }
            actionSheetController.addAction(nextAction)
            actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
                textField.keyboardType = UIKeyboardType.NumberPad
                print("USER CHECKPOINT: \(textField.text)")
            }
            
            Async.main {
                self.presentViewController(actionSheetController, animated: true, completion: nil)
            }
            
        }))
        
        Async.main {
            self.presentViewController(noticeAlert, animated: true, completion: nil)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}