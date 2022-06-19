//
//  ViewController.swift
//  LearnAR
//
//  Created by Alfin on 19/06/22.
//

import UIKit
import ARKit
import RealityKit

class ViewController: UIViewController {
    
    let models = ["robot"]
    
    @IBOutlet var arView: ARView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        setupARView()
        
        arView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(
                    handleTap(recognizer:)
                )
            )
        )
        
        arView.addGestureRecognizer(
            UILongPressGestureRecognizer(
                target: self,
                action: #selector(
                    handleLongPress(recognizer:)
                )
            )
        )
    }
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: models.first!, transform: firstResult.worldTransform)
                
            arView.session.add(anchor: anchor)
        } else {
            print("⚠️ Gagal menempatkan objek - Tidak dapat menemukan permukaan.")
        }
    }
    
    @objc
    func handleLongPress(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let entity = arView.entity(at: location)
        
        entity?.removeFromParent()
    }
    
    func placeObject(named entityName: String?, for anchor: ARAnchor) {
        guard let entityName = entityName, models.contains(entityName) else { return }

        let entity = try! ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: entity)

        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
                
        arView.scene.addAnchor(anchorEntity)
    }
}


extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            placeObject(named: anchor.name, for: anchor)
        }
    }
}
