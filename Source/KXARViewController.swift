//
//  KXARViewController.swift
//  KXAugmentedReality
//
//  Created by khan on 14/03/17.
//  Copyright © 2017 Appyte. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreLocation


public enum TargetTypeOption: String {
    case Default
    case Custom
}

@IBDesignable open class KXARViewController: UIViewController {
    
    
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var leftIndicator: UILabel!
    @IBOutlet weak var rightIndicator: UILabel!
    
    
    
    //options to private 
    
    private var options: [TargetTypeOption]?
    //Option to show default Cube or Custom 3D model
    @IBInspectable open var targetType: TargetTypeOption = TargetTypeOption(rawValue: "Default")!
    
    open  var cameraSession: AVCaptureSession?
    open  var cameraLayer: AVCaptureVideoPreviewLayer?
    open var target: ARItem!
    
    open var locationManager = CLLocationManager()
    open var heading: Double = 0
    open var userLocation = CLLocation()
  
    open  let scene = SCNScene()
    open let cameraNode = SCNNode()
    open let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    
    
    public init(options: [TargetTypeOption]) {
        super.init(nibName: nil, bundle: nil)
        self.options = options
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
     
        
        loadCamera()
        self.cameraSession?.startRunning()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingHeading()
        
        sceneView.scene = scene
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scene.rootNode.addChildNode(cameraNode)
        
        setupTarget()
       
        super.viewDidLoad()
    }
    
    func setupTarget() {
        
//        targetNode.name = "cube"
//        self.target.itemNode = targetNode
       
        let scene = SCNScene(named: "art.scnassets/\(target.itemDescription!).dae")
     
        let run = scene?.rootNode.childNode(withName: target.itemDescription!, recursively: true)
//        let fur = scene?.rootNode.childNode(withName: "Wolf_obj_fur", recursively: true)
//        let body = scene?.rootNode.childNode(withName: "Wolf_obj_body", recursively: true)
        //.childNode(withName: "Wolf_obj_body", recursively: true)
            
       
        if target.itemDescription == "dragon" {
            run?.position = SCNVector3(x: 0, y: -15, z: -20)
        } else {
            run?.position = SCNVector3(x: 0, y: 0, z: 0)
        }
        
   
        let node = SCNNode()
        node.addChildNode(run!)
    
        node.name = "enemy"
        self.target.itemNode = node
    }
    
    
    func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) {
       
        var error: NSError?
        var captureSession: AVCaptureSession?
        
        
        let backVideoDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        
       
        if backVideoDevice != nil {
            var videoInput: AVCaptureDeviceInput!
            do {
                videoInput = try AVCaptureDeviceInput(device: backVideoDevice)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
            }
            
         
            if error == nil {
                captureSession = AVCaptureSession()
                
              
                if captureSession!.canAddInput(videoInput) {
                    captureSession!.addInput(videoInput)
                } else {
                    error = NSError(domain: "", code: 0, userInfo: ["description": "Error adding video input."])
                }
            } else {
                error = NSError(domain: "", code: 1, userInfo: ["description": "Error creating capture device input."])
            }
        } else {
            error = NSError(domain: "", code: 2, userInfo: ["description": "Back video device not found."])
        }
        
        
        return (session: captureSession, error: error)
    }
    
    func loadCamera() {
 
        let captureSessionResult = createCaptureSession()
        
     
        guard captureSessionResult.error == nil, let session = captureSessionResult.session else {
            print("Error creating capture session.")
            return
        }
        
      
        self.cameraSession = session
        
     
        if let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession) {
            cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraLayer.frame = self.view.bounds
          
            self.view.layer.insertSublayer(cameraLayer, at: 0)
            self.cameraLayer = cameraLayer
        }
    }
    
    func repositionTarget() {
      
        let heading = getHeadingForDirectionFromCoordinate(from: userLocation, to: target.location!)
        
       
        let delta = heading - self.heading
        
        if delta < -15.0 {
            leftIndicator.isHidden = false
            rightIndicator.isHidden = true
        } else if delta > 15 {
            leftIndicator.isHidden = true
            rightIndicator.isHidden = false
        } else {
            leftIndicator.isHidden = true
            rightIndicator.isHidden = true
        }
        
        
        let distance = userLocation.distance(from: target.location!)
        
       
        if let node = target.itemNode {
            
            
            if node.parent == nil {
                node.position = SCNVector3(x: Float(delta), y: 0, z: Float(-distance))
                scene.rootNode.addChildNode(node)
            } else {
               
                node.removeAllActions()
                node.runAction(SCNAction.move(to: SCNVector3(x: Float(delta), y: 0, z: Float(-distance)), duration: 0.2))
            }
        }
    }
    
    func radiansToDegrees(_ radians: Double) -> Double {
        return (radians) * (180.0 / M_PI)
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return (degrees) * (M_PI / 180.0)
    }
    
    func getHeadingForDirectionFromCoordinate(from: CLLocation, to: CLLocation) -> Double {
        
        let fLat = degreesToRadians(from.coordinate.latitude)
        let fLng = degreesToRadians(from.coordinate.longitude)
        let tLat = degreesToRadians(to.coordinate.latitude)
        let tLng = degreesToRadians(to.coordinate.longitude)
        
       
        let degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))
        
       
        if degree >= 0 {
            return degree
        } else {
            return degree + 360
        }
    }
}

extension KXARViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        self.heading = fmod(newHeading.trueHeading, 360.0)
        repositionTarget()
    }
}
