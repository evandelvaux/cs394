/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit
import SceneKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sendMapButton: UIButton!
    @IBOutlet weak var mappingStatusLabel: UILabel!
    
    func win() {
        print("!! You win!")
    }
    
    struct trafficLight {
        var top: SCNNode? = nil
        var middle: SCNNode? = nil
        var bottom: SCNNode? = nil
        
        var colors: [Int?] = [nil,nil,nil] // color of top, middle, bottom respectively
            /* 0 - red
             * 1 - yellow
             * 2 - green
             */
        
        let win_pattern: [Int] = [0,1,2] // colors needed to win
        
        let num_to_color: [UIColor] = [UIColor.red, UIColor.yellow, UIColor.green]
        
        mutating func set(top_col: Int, mid_col: Int, bot_col: Int) {
            colors = [top_col,mid_col,bot_col]
            
            self.top!.geometry?.firstMaterial?.diffuse.contents = num_to_color[top_col]
            self.middle!.geometry?.firstMaterial?.diffuse.contents = num_to_color[mid_col]
            self.bottom!.geometry?.firstMaterial?.diffuse.contents = num_to_color[bot_col]
        }
        
        // This function causes a light to cycle to the next color in a sequence
        mutating func change(whichLight: String) {
            var selected: SCNNode? = nil
            var index: Int? = nil // Index within 'colors' array
            //var from_color_i: Int? = nil // The number code for the current color
            switch whichLight {
            case "Top":
                selected = self.top
                //from_color_i = colors[0]
                index = 0
            case "Middle":
                selected = self.middle
                //from_color_i = colors!.mid
                index = 1
            case "Bottom":
                selected = self.bottom
                //from_color_i = colors!.bot
                index = 2
            default:
                print("Other object: ", whichLight)
                return // Does nothing
            }
            
            var to_color: UIColor? = nil // Color we're changing to
            switch colors[index!] {//from_color_i {
            case 0:
                to_color = UIColor.yellow
                colors[index!] = 1
            case 1:
                to_color = UIColor.green
                colors[index!] = 2
            case 2:
                to_color = UIColor.red
                colors[index!] = 0
            default:
                to_color = UIColor.white // Should never be used
            }
            selected!.geometry?.firstMaterial?.diffuse.contents = to_color
            
        } // end func change
        
        func check_win() -> Bool {
            if (colors == [nil,nil,nil]) {
                return false
            }
            else if (colors == self.win_pattern) {
                return true
            }
            return false
        }
    }
    var light = trafficLight()
    
    // MARK: - View Life Cycle
    
    var multipeerSession: MultipeerSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        multipeerSession = MultipeerSession(receivedDataHandler: receivedData)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """) // For details, see https://developer.apple.com/documentation/arkit
        }
        
        // Start the view's AR session.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's AR session.
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix("puzzle") {
            node.addChildNode(loadPuzzle())
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            sendMapButton.isEnabled = false
        case .extending:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        case .mapped:
            sendMapButton.isEnabled = !multipeerSession.connectedPeers.isEmpty
        }
        mappingStatusLabel.text = frame.worldMappingStatus.description
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking(nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    // MARK: - Multiuser shared session
    
    var alreadyPlaced = false
    
    /// - Tag: PlaceCharacter
    @IBAction func handleSceneTap(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: sceneView)
        
        if (alreadyPlaced) {
            let hitResults = sceneView.hitTest(tapLocation, options: [:])
            if let result = hitResults.first {
                tapLight(toNode: result.node)
            }
            return
        }
        
        else {
            // Hit test to find a place for a virtual object.
            guard let hitTestResult = sceneView
                .hitTest(tapLocation, types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
                .first
                else { return }
            
            // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
            let anchor = ARAnchor(name: "puzzle", transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: anchor)
            
            // Send the anchor info to peers, so they can place the same content.
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
            self.multipeerSession.sendToAllPeers(data)
            
            alreadyPlaced = true
        }
    }
    
    private func tapLight(toNode node: SCNNode) {
        print("!!Color Changed")
        print(node)
        light.change(whichLight: node.name ?? "no name")
        if (light.check_win()) {
            win()
        }
    }
    
    /// - Tag: GetWorldMap
    @IBAction func shareSession(_ button: UIButton) {
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                else { fatalError("can't encode map") }
            self.multipeerSession.sendToAllPeers(data)
        }
    }
    
    var mapProvider: MCPeerID?

    /// - Tag: ReceiveData
    func receivedData(_ data: Data, from peer: MCPeerID) {
        
        do {
            if let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) {
                // Run the session with the received world map.
                let configuration = ARWorldTrackingConfiguration()
                configuration.planeDetection = .horizontal
                configuration.initialWorldMap = worldMap
                sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                
                // Remember who provided the map for showing UI feedback.
                mapProvider = peer
            }
            else
            if let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
                // Add anchor to the session, ARSCNView delegate adds visible content.
                sceneView.session.add(anchor: anchor)
            }
            else {
                print("unknown data recieved from \(peer)")
            }
        } catch {
            print("can't decode data recieved from \(peer)")
        }
    }
    
    // MARK: - AR session management
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty && multipeerSession.connectedPeers.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move around to map the environment, or wait to join a shared session."
            
        case .normal where !multipeerSession.connectedPeers.isEmpty && mapProvider == nil:
            let peerNames = multipeerSession.connectedPeers.map({ $0.displayName }).joined(separator: ", ")
            message = "Connected with \(peerNames)."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing) where mapProvider != nil,
             .limited(.relocalizing) where mapProvider != nil:
            message = "Received map from \(mapProvider!.displayName)."
            
        case .limited(.relocalizing):
            message = "Resuming session — move to where you were when the session was interrupted."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        alreadyPlaced = false
    }
    
    // MARK: - AR session management
    private func loadPuzzle() -> SCNNode {
        let sceneURL = Bundle.main.url(forResource: "ButtonWall", withExtension: "scn", subdirectory: "Assets.scnassets")!
        let referenceNode = SCNReferenceNode(url: sceneURL)!
        referenceNode.load()
        
        light.top = referenceNode.childNode(withName: "Top", recursively: true)!
        light.middle = referenceNode.childNode(withName: "Middle", recursively: true)!
        light.bottom = referenceNode.childNode(withName: "Bottom", recursively: true)!
        light.set(top_col: 2, mid_col: 2, bot_col: 1) // red,yellow,green
        
        //redLight!.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        
        return referenceNode
    }
}

