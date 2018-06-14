//
//  SecondViewController.swift
//  NDCSecondMobileApp
//
//  Created by Anne Cahalan on 6/12/18.
//  Copyright © 2018 Anne Cahalan. All rights reserved.
//

import UIKit
import ARKit

class SecondViewController: UIViewController {

    @IBOutlet weak var randomizerLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRandomizerResultsLabel(with: 5)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
}

extension SecondViewController: RandomlyShowing { }
