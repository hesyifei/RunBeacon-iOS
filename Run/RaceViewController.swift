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

class RaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - IBOutlet var
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cameraView: UIView!
    
    
    // MARK: - Basic var
    let application = UIApplication.sharedApplication()
    
    var captureSession: AVCaptureSession?
    
    
    // MARK: - UI Var
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let blurView = UIVisualEffectView()
    
    
    // MARK: - Data var
    var passData = [String]()
    
    var isCameraViewBlur: Bool = false {
        willSet(newValue) {
            DDLogVerbose("isCameraViewBlur 新值為 \(newValue)")
            
            self.blurView.userInteractionEnabled = false
            UIView.animateWithDuration(0.5, animations: {
                switch newValue {
                case true:
                    self.blurView.effect = UIBlurEffect(style: .Light)
                    break
                case false:
                    self.blurView.effect = nil
                    break
                }
                }, completion: {
                    (value: Bool) in
                    self.blurView.userInteractionEnabled = true
            })
        }
    }
    
    
    // MARK: - Override func
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("Race View Controller 之 super.viewDidLoad() 已加載")
        
        
        self.title = "Race"
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        passData = ["haha", "wata"]
        
        
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
        
        
        Async.main{
            self.isCameraViewBlur = true
            }.main(after: 0.5) {
                self.isCameraViewBlur = false
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
                
                self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
                self.cameraView.addSubview(self.blurView)
            }
            
            captureSession?.startRunning()
        } catch _ as NSError {
            cameraError()
        }
    }
    
    func cameraError() {
        DDLogError("無法開啟相機")
        
        //BasicFunc().showAlert(self, title: "Error", message: "\(error.localizedDescription)\n\n\(BasicConfig.ContactAdminMessage)")
        //BasicFunc().showEnableServicesAlert(self, services: ["Camera"])
    }
    
    
    func optimizeVideoPreviewLayer() {
        videoPreviewLayer?.frame = self.cameraView.layer.bounds
        videoPreviewLayer?.connection.videoOrientation = self.videoOrientationFromCurrentOrientation()
        
        self.blurView.frame = self.cameraView.layer.bounds
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
    
    
    
    // MARK: - Tableview func
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PassCell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.text = "YAYA\(passData[indexPath.row])"
        cell.detailTextLabel!.text = "WOHO"
        
        return cell
    }
}