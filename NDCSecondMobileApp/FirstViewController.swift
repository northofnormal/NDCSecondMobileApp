//
//  FirstViewController.swift
//  NDCSecondMobileApp
//
//  Created by Anne Cahalan on 6/12/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import UIKit
import ARKit

class FirstViewController: UIViewController {

    @IBOutlet weak var randomizerLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var planes = [UUID: VirtualPlane]()
    var magicNode: SCNNode?
    var selectedPlane: VirtualPlane?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRandomizerResultsLabel(with: 2)
        setupARScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        initializeMagicNode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func setupARScene() {
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        
        // set up world tracking configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func initializeMagicNode() {
        let magicScene = SCNScene(named: "santa_hat.dae")
        magicNode = magicScene?.rootNode.childNode(withName: "santa_hat", recursively: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shouldShow(divisor: 2) else { return }
        
        guard let touch = touches.first else {
            print("👆🏻🚫👆🏻🚫👆🏻🚫 Unable to identify touches on any plane, ignoring everything.")
            return
        }
        
        let touchPoint = touch.location(in: sceneView)
        guard let plane = virtualPlaneProperlySet(touchPoint: touchPoint) else { return }
        addMagicToPlane(plane: plane, at: touchPoint)
    }
    
    func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        guard hits.count > 0 else { return nil  }
        guard let firstHit = hits.first, let identifier = firstHit.anchor?.identifier, let plane = planes[identifier] else {
            return nil
        }
        
        selectedPlane = plane
        return plane
    }
    
    func addMagicToPlane(plane: VirtualPlane, at point: CGPoint) {
        let hits = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
        guard hits.count > 0 else { return }
        guard let firstHit = hits.first else { return }
        
        guard let someMagic = magicNode?.clone() else { return }
        someMagic.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(someMagic)
    }

}

extension FirstViewController: RandomlyShowing { }

extension FirstViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor {
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            self.planes[arPlaneAnchor.identifier] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = planes[arPlaneAnchor.identifier] {
            plane.updateWithNewAnchor(anchor: arPlaneAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAnchor.identifier) {
            planes.remove(at: index)
        }
    }
    
}
