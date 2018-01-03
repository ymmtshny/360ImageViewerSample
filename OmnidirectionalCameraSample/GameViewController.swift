//
//  GameViewController.swift
//  OmnidirectionalCameraSample
//
//  Created by Shinya Yamamoto on 2018/01/02.
//  Copyright © 2018年 shinyayamamoto. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

class GameViewController: UIViewController {

    let motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        guard let scnView = self.view as? SCNView else { return }
        scnView.scene = scene
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLight.LightType.ambient
        ambientLightNode.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLightNode)
        
        let sphereGeometry = SCNSphere(radius: 100)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIImage(named: "test_01")
//        material.diffuse.wrapS = .repeat
//        material.diffuse.wrapT = .repeat
//        material.diffuse.contentsTransform = SCNMatrix4MakeScale(2.0, 1.0, 1.0)
        sphereGeometry.firstMaterial = material
        let boxNode = SCNNode(geometry: sphereGeometry)
        scene.rootNode.addChildNode(boxNode)
        
        guard let queue = OperationQueue.current else { return }
        motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
            guard let motion = motion else { return }
            cameraNode.orientation = self.orientationFromCMQuaternion(q: motion.attitude.quaternion)
        }
        
    }
    
    private func orientationFromCMQuaternion(q: CMQuaternion) -> SCNVector4 {
        let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
        let gq2 = GLKQuaternionMake(Float(q.x), Float(q.y), Float(q.z), Float(q.w))
        let qp  = GLKQuaternionMultiply(gq1, gq2)
        let rq  = CMQuaternion(x: Double(qp.x), y: Double(qp.y), z: Double(qp.z), w: Double(qp.w))
        return SCNVector4Make(Float(rq.x), Float(rq.y), Float(rq.z), Float(rq.w))
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
