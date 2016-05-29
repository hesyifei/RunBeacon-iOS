//
//  RaceViewController.swift
//  Run
//
//  Created by Jason Ho on 10/4/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON
import MBProgressHUD
import Locksmith

import UIKit
class PassedNumberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
}

class RaceViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var bottomToolBar: UIView!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var passedNumberCollectionView: UICollectionView!
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var endTextField: UITextField!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var shutterButton: UIButton!
    
    
    
    
    // MARK: - Basic var
    let application = UIApplication.sharedApplication()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    var captureSession: AVCaptureSession?
    
    
    
    var timer: NSTimer?
    var timerStartTime: NSTimeInterval!
    
    
    var timeLabelText = "" {
        didSet {
            timeLabel.text = timeLabelText
            if let _ = timeBarButtonItem {
                timeBarButtonItem.title = timeLabelText
            }
        }
    }
    
    
    
    // MARK: - UI Var
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var timeBarButtonItem: UIBarButtonItem!
    
    
    
    // MARK: - Data var
    var personChecks = [PersonCheck]()
    
    
    var isStartCheckpoint = false
    var isEndCheckpoint = false
    
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.personChecks.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PassedNumberCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.numberLabel.text = "\(self.personChecks[indexPath.item].personId)"
        cell.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.1) // make cell more visible in our example project
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 2
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    
    // TODO: show alert when bluetooth is disabled (like "PhoneInBeacon")
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Race View Controller 之 super.viewDidLoad() 已加載")
        
        
        
        passedNumberCollectionView.delegate = self
        passedNumberCollectionView.dataSource = self
        
        
        passedNumberCollectionView.backgroundColor = UIColor.clearColor()
        
        passedNumberCollectionView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSizeZero
        layout.footerReferenceSize = CGSizeZero
        layout.sectionInset = UIEdgeInsetsZero
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        passedNumberCollectionView?.collectionViewLayout = layout
        
        
        shutterButton.addTarget(self, action: #selector(self.shutterButtonAction), forControlEvents: .TouchUpInside)
        
        
        
        /*self.personChecks = []
        while personChecks.count < 45 {
            var randomNumber: Int
            repeat {
                randomNumber = Int(BasicFunc().random(1...89))
            } while personChecks.contains(PersonCheck(personId: randomNumber, time: NSDate().dateByAddingTimeInterval(-460)))
            personChecks.append(PersonCheck(personId: randomNumber, time: NSDate().dateByAddingTimeInterval(-460)))
        }*/
        
        
        self.personChecks = []
        
        
        
        let logoutNavButton = UIBarButtonItem(title: "Logout", style: .Done, target: self, action: #selector(self.logoutAction))
        self.navigationItem.rightBarButtonItems = [logoutNavButton]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogInfo("Race View Controller 之 super.viewWillAppear() 已加載")
        
        self.title = "Race"
        
        if let idString = defaults.stringForKey("checkpointId") {
            if let idInt = Int(idString) {
                
                let checkpointsData = CheckpointFunc().getCheckpoints()
                
                if(idInt == checkpointsData[0].id){
                    self.isStartCheckpoint = true
                    self.isEndCheckpoint = false
                }else if(idInt == checkpointsData[checkpointsData.count-1].id){
                    self.isStartCheckpoint = false
                    self.isEndCheckpoint = true
                }else if( (idInt > checkpointsData[checkpointsData.count-1].id) || (idInt < checkpointsData[0].id) ){
                    BasicFunc().showAlert(self, title: "Error", message: "Checkpoint ID (\(idInt)) is invalid!")
                    self.logoutUser()
                }else{
                    self.isStartCheckpoint = false
                    self.isEndCheckpoint = false
                }
                self.navigationItem.title = "Checkpoint \(idInt)"
            }else{
                BasicFunc().showAlert(self, title: "Error", message: "Checkpoint ID should be a number!")
                self.logoutUser()
            }
        }else{
            BasicFunc().showAlert(self, title: "Error", message: "Checkpoint ID is empty!")
            self.logoutUser()
        }
        
        
        timeLabelText = "Time: 00:00"
        
        
        bottomToolBar.backgroundColor = UIColor(red: 230.0/250.0, green: 230.0/250.0, blue: 230.0/250.0, alpha: 1.0)
        
        
        startButton.layer.cornerRadius = 50.0
        startButton.clipsToBounds = true
        startButton.setTitle("Start", forState: .Normal)
        startButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(20.0)
        startButton.setBackgroundColor(UIColorConfig.GrassGreen, forUIControlState: .Normal)
        startButton.setBackgroundColor(UIColor.lightGrayColor(), forUIControlState: .Disabled)
        startButton.addTarget(self, action: #selector(self.startButtonAction), forControlEvents: .TouchUpInside)
        
        
        if(isStartCheckpoint){
            startButton.hidden = false
            passedNumberCollectionView.hidden = true
        }else{
            startButton.hidden = true
            passedNumberCollectionView.hidden = false
            
            
            timerStartTime = NSDate().dateByAddingTimeInterval(-290).timeIntervalSinceReferenceDate
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.calcTime), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
            DDLogDebug("已開啟timer計時器")
        }
        
        
        let keyBoardToolBar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        keyBoardToolBar.barStyle = .Default
        keyBoardToolBar.translucent = false
        keyBoardToolBar.barTintColor = UIColor(colorLiteralRed: (247/255), green: (247/255), blue: (247/255), alpha: 1)     //http://stackoverflow.com/a/34290370/2603230
        
        
        
        timeBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        timeBarButtonItem.tintColor = UIColor.blackColor()
        
        let addButton = UIBarButtonItem(title: "Add", style: .Done, target: self, action: #selector(self.addPressed))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        keyBoardToolBar.setItems([timeBarButtonItem, spaceButton, addButton], animated: true)
        keyBoardToolBar.userInteractionEnabled = true
        keyBoardToolBar.sizeToFit()
        
        
        endTextField.inputAccessoryView = keyBoardToolBar
        
        endTextField.delegate = self
        endTextField.textAlignment = .Center
        endTextField.font = UIFont(name: "Futura-Medium", size: 200.0)
        endTextField.keyboardType = .NumberPad
        
        Async.main {
            self.endTextField.layer.addSublayer(self.getTextFieldBorder(self.endTextField))
            self.endTextField.layer.masksToBounds = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
        
        
        
        if(isEndCheckpoint){
            endTextField.becomeFirstResponder()
            endTextField.hidden = false
            cameraView.hidden = true
        }else{
            endTextField.hidden = true
            cameraView.hidden = false
        }
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        DDLogInfo("Race View Controller 之 super.viewDidAppear() 已加載")
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if (granted == false) {
                    DDLogWarn("用戶已拒絕取用相機")
                    self.cameraError()
                } else {
                    DDLogInfo("用戶已拒絕取用相機")
                    self.startCamera()
                }
            })
        case .Authorized:
            startCamera()
            break
        case .Denied, .Restricted:
            cameraError()
            break
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        DDLogInfo("Race View Controller 之 super.viewDidDisappear() 已加載")
        
        timer!.invalidate()
        timer = nil
        DDLogInfo("已停止timer計時器")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            DDLogInfo("設備開始轉換屏幕方向")
            self.optimizeVideoPreviewLayer()
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                DDLogInfo("設備已結束轉換屏幕方向")
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    func addPressed() {
        endTextField.text = ""
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 3
    }
    
    
    func getTextFieldBorder(textField: UITextField) -> CALayer {
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        border.borderWidth = borderWidth
        border.borderColor = UIColorConfig.GrassGreen.CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - borderWidth, width: textField.frame.size.width, height: textField.frame.size.height)
        return border
    }
    
    
    func startButtonAction() {
        startButton.enabled = false
        
        timerStartTime = NSDate().timeIntervalSinceReferenceDate
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.calcTime), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        DDLogDebug("已開啟timer計時器")
    }
    
    func calcTime() {
        let timeDifference = NSDate.timeIntervalSinceReferenceDate() - timerStartTime
        
        let minuteAndSecond = PracticeRunningViewController().secondsToFormattedTime(timeDifference)
        timeLabelText = "Time: \(minuteAndSecond)"
    }
    
    
    func addPassingData() {
        self.personChecks.append(PersonCheck(personId: 93, time: NSDate().dateByAddingTimeInterval(-610)))
        
        let lastIndexPath = NSIndexPath(forItem: self.personChecks.count-1, inSection: 0)
        
        Async.main {
            self.passedNumberCollectionView.insertItemsAtIndexPaths([lastIndexPath])
            self.passedNumberCollectionView.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: .Bottom, animated: true)
        }
    }
    
    // MARK: - Camera func
    
    func startCamera() {
        // 於此處查看註釋：http://www.appcoda.com/qr-code-reader-swift/
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input as AVCaptureInput)
            
            Async.main {
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.optimizeVideoPreviewLayer()
                
                self.cameraView.layer.insertSublayer(self.videoPreviewLayer!, atIndex: 0)
            }
            
            captureSession?.startRunning()
        } catch _ as NSError {
            cameraError()
        }
    }
    
    func cameraError() {
        DDLogError("無法開啟相機")
        
        //BasicFunc().showAlert(self, title: "Error", message: "\(error.localizedDescription)\n\n\(BasicConfig.ContactAdminMessage)")
        BasicFunc().showEnableServicesAlert(self, services: ["Camera"])
    }
    
    
    func optimizeVideoPreviewLayer() {
        videoPreviewLayer?.frame = self.cameraView.layer.bounds
        videoPreviewLayer?.connection.videoOrientation = self.videoOrientationFromCurrentOrientation()
    }
    
    func videoOrientationFromCurrentOrientation() -> AVCaptureVideoOrientation {
        switch application.statusBarOrientation {
        case .Portrait:
            return AVCaptureVideoOrientation.Portrait
        case .LandscapeLeft:
            return AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight
        case .PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown
        default:
            // 都不是的情況幾乎不可能？
            return AVCaptureVideoOrientation.Portrait
        }
    }
    
    func shutterButtonAction() {
        showFlashView()
    }
    
    func showFlashView() {
        Async.main() {
            let flashView = UIView(frame: self.cameraView.bounds)
            flashView.backgroundColor = UIColor.whiteColor()
            flashView.alpha = 1.0
            self.cameraView.insertSubview(flashView, aboveSubview: self.shutterButton)
            
            UIView.animateWithDuration(0.5, animations: {
                flashView.alpha = 0.0
                }, completion: { (finished: Bool) in
                    DDLogDebug("flashView已隱藏")
                    flashView.removeFromSuperview()
            })
        }
    }
    
    
    func logoutAction() {
        let warningAlert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .Alert)
        warningAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            self.logoutUser()
        }))
        warningAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        Async.main {
            self.presentViewController(warningAlert, animated: true, completion: nil)
        }
    }
    
    func logoutUser() {
        do {
            try Locksmith.deleteDataForUserAccount(BasicConfig.UserAccountID)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch let error as NSError {
            DDLogError("無法刪除用戶登入數據：\(error)")
            BasicFunc().showErrorAlert(self, error: error)
        }
    }
}