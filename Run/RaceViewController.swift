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

class RaceViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var passedNumberCollectionView: UICollectionView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var shutterButton: UIButton!
    
    
    // MARK: - Basic var
    let application = UIApplication.sharedApplication()
    
    var captureSession: AVCaptureSession?
    
    
    // MARK: - UI Var
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    
    // MARK: - Data var
    var personChecks = [PersonCheck]()
    
    
    
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
        
        
        self.title = "Race"
        
        
        
        
        
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
        
        
        
        self.personChecks = [
            PersonCheck(personId: 3, time: NSDate().dateByAddingTimeInterval(-460)),
            PersonCheck(personId: 6, time: NSDate().dateByAddingTimeInterval(-520)),
            PersonCheck(personId: 14, time: NSDate().dateByAddingTimeInterval(-580)),
            PersonCheck(personId: 23, time: NSDate().dateByAddingTimeInterval(-600)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
            PersonCheck(personId: 60, time: NSDate().dateByAddingTimeInterval(-610)),
        ]
        
        
        
        let logoutNavButton = UIBarButtonItem(title: "Logout", style: .Done, target: self, action: #selector(self.logoutAction))
        self.navigationItem.rightBarButtonItems = [logoutNavButton]
        
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
            do {
                try Locksmith.deleteDataForUserAccount(BasicConfig.UserAccountID)
                
                self.dismissViewControllerAnimated(true, completion: nil)
            } catch let error as NSError {
                DDLogError("無法刪除用戶登入數據：\(error)")
                BasicFunc().showErrorAlert(self, error: error)
            }
        }))
        warningAlert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        
        Async.main {
            self.presentViewController(warningAlert, animated: true, completion: nil)
        }
    }
}