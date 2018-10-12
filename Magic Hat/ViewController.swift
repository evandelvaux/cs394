//
//  ViewController.swift
//  Magic Hat
//
//  Created by Evan Delvaux on 9/27/18.
//  Copyright © 2018 Evan Delvaux. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/hat2.scn")!
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
    }
    
    @IBAction func throwBall(_ sender: Any) {
        let ballShape = SCNSphere(radius: 0.03)
        let ballNode = SCNNode(geometry: ballShape)
        
        let camera = sceneView.session.currentFrame?.camera
        let cameraTransform = camera?.transform
        
        ballNode.simdTransform = cameraTransform!
        
        ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        //print(String(describing: ballNode.position))
        sceneView.scene.rootNode.addChildNode(ballNode)
        
        guard let frame = sceneView.session.currentFrame else { return }
        let camMatrix = SCNMatrix4(frame.camera.transform)
        let direction = SCNVector3Make(-camMatrix.m31 * 1.50, -camMatrix.m32 * 2.0, -camMatrix.m33 * 1.50)
        ballNode.physicsBody?.applyForce(direction, asImpulse: true)
    }
    
    @IBAction func magic(_ sender: Any) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    private var planeNode: SCNNode?
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if (anchor is ARPlaneAnchor) {
            guard let url = Bundle.main.url(forResource: "art.scnassets/hat2", withExtension: "scn") else {
                NSLog("Could not find scene")
                return nil
            }
            guard let node = SCNReferenceNode(url: url) else { return nil }
            node.load()
            planeNode = SCNNode()
            planeNode?.addChildNode(node)
            return planeNode
        }
        return nil
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
