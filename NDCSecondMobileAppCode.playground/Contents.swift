// Playground for NDC Oslo Second Mobile App
// Feel free to copy and paste this code as we go
// I'll explain everything, don't worry!

import Foundation

// 1
protocol RandomlyShowing {
    func shouldShow() -> Bool
}


// 2 (in FirstViewController)
func shouldShow() -> Bool {
    let number = arc4random_uniform(101)
    return number % 2 == 0
}


// 3 (in SecondViewController)
func shouldShow() -> Bool {
    let number = arc4random_uniform(101)
    return number % 5 == 0
}

// 4 (in viewDidLoad on the FirstViewController)
if shouldShow(divisor: divisor) {
    randomizerLabel.text = "The random number was divisible by 2"
} else {
    randomizerLabel.text = "The random number was not divisible by 2"
}

// 5 (in RandomlyShowing)
func shouldShow(divisor: UInt32) -> Bool {
    let number = arc4random_uniform(101)
    return number % divisor == 0
}

// 6 (in RandomlyShowing)
func setRandomizerResultsLabel(with divisor: UInt32) {
    if shouldShow(divisor: divisor) {
        randomizerLabel.text = "The random number was divisible by \(divisor)"
    } else {
        randomizerLabel.text = "The random number was not divisible by \(divisor)"
    }
}

// 7 (in viewDidLoad on the FirstViewController)

let configuration = ARWorldTrackingConfiguration()
configuration.planeDetection = .horizontal
sceneView.session.run(configuration)

// 7b (in FirstViewController)
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
}

// 8 (in viewDidLoad in FirstViewController)
sceneView.delegate = self
let scene = SCNScene()
sceneView.scene = scene

// 9 (in VirtualPlane)
var anchor: ARPlaneAnchor!
var planeGeometry: SCNPlane!

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
}


// 10 (in VirtualPlane)
init(anchor: ARPlaneAnchor) {
    super.init()
    
    self.anchor = anchor
    planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
    
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
    
    planeGeometry.materials = [material]
    
}

// 11 (in the init(anchor:) method)
let planeNode = SCNNode(geometry: planeGeometry)
planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)

// 12 (in VirtualPlane)
func updatePlaneMaterialDimensions() {
    let material = planeGeometry.materials.first
    let width = Float(planeGeometry.width)
    let height = Float(planeGeometry.height)
    
    material?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
}

// 13 (in FirstVC)
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    if let arPlaneAnchor = anchor as? ARPlaneAnchor {
        let plane = VirtualPlane(anchor: arPlaneAnchor)
        self.planes[arPlaneAnchor.identifier] = plane
        node.addChildNode(plane)
    }
}

// 14 (in VirtualPlane)
func updateWithNewAnchor(anchor: ARPlaneAnchor) {
    planeGeometry.width = CGFloat(anchor.extent.x)
    planeGeometry.height = CGFloat(anchor.extent.z)
    
    position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    
    updatePlaneMaterialDimensions()
}

// 15 (in FirstVC)
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

// 16 (in FirstVC)
sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

// 17
func initializeMagicNode() {
    let magicScene = SCNScene(named: "santa_hat.dae")
    magicNode = magicScene?.rootNode.childNode(withName: "santa_hat", recursively: true)
}

// 18
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
        print("👆🏻🚫👆🏻🚫👆🏻🚫 Unable to identify touches on any plane, ignoring everything.")
        return
    }
    
    let touchPoint = touch.location(in: sceneView)
    guard let plane = virtualPlaneProperlySet(touchPoint: touchPoint) else { return }
}

// 19
func virtualPlaneProperlySet(touchPoint: CGPoint) -> VirtualPlane? {
    let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
    guard hits.count > 0 else { return nil  }
    guard let firstHit = hits.first, let identifier = firstHit.anchor?.identifier, let plane = planes[identifier] else {
        return nil
    }
    
    selectedPlane = plane
    return plane
}

// 20 (add to touchesBegan method)
 guard let plane = virtualPlaneProperlySet(touchPoint: touchPoint) else { return }

// 21
func addMagicToPlane(plane: VirtualPlane, at point: CGPoint) {
    let hits = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
    guard hits.count > 0 else { return }
    guard let firstHit = hits.first else { return }
    
    guard let someMagic = magicNode?.clone() else { return }
    someMagic.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
    sceneView.scene.rootNode.addChildNode(someMagic)
}

// 22 (add to touches began)
addMagicToPlane(plane: plane, at: touchPoint)




