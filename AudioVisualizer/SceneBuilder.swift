import SceneKit
import SwiftUI

class SceneBuilder {
    func createScene(from samples: [Float], config: VisualizationConfig) -> SCNScene {
        let scene = SCNScene()
        addFloor(to: scene, reflectivity: config.floorReflectivity)
        addCamera(to: scene, position: config.cameraPosition, angle: config.cameraAngle)
        addLighting(to: scene, mood: config.mood)
        
        scene.background.contents = config.mood.backgroundColor
        scene.fogStartDistance = config.mood.fogStartDistance
        scene.fogEndDistance = config.mood.fogEndDistance
        scene.fogColor = config.mood.fogColor
        
        switch config.visualizationType {
        case .boxes:
            addBoxes(from: samples, to: scene, config: config)
        case .spheres:
            addSpheres(from: samples, to: scene, config: config)
        case .radial:
            addRadialObjects(from: samples, to: scene, config: config)
        }
        
        return scene
    }
    
    private func addFloor(to scene: SCNScene, reflectivity: Float) {
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = CGFloat(reflectivity)
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.name = "floor"
        scene.rootNode.addChildNode(floorNode)
    }
    
    private func addCamera(to scene: SCNScene, position: SCNVector3, angle: SCNVector3) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = position
        cameraNode.eulerAngles = angle
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func addLighting(to scene: SCNScene, mood: Mood) {
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = mood.ambientLightColor
        ambientLight.name = "ambientLight"
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = mood.directionalLightColor
        directionalLight.eulerAngles = SCNVector3(x: -0.5, y: -0.5, z: 0)
        directionalLight.name = "directionalLight"
        scene.rootNode.addChildNode(directionalLight)
    }
    
    private func addBoxes(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let step = samples.count / config.numberOfObjects
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let boxSize = CGFloat(sample * config.objectSizeMultiplier)
            let boxGeometry = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0)
            let boxNode = SCNNode(geometry: boxGeometry)
            
            let x = Float(i) / Float(samples.count) * 20 - 10
            let y = sample * 10 * config.objectSizeMultiplier
            boxNode.position = SCNVector3(x, y, 0)
            
            boxNode.geometry?.firstMaterial?.diffuse.contents = colorForSample(sample, index: i, count: samples.count, config: config)
            
            scene.rootNode.addChildNode(boxNode)
        }
    }
    
    private func addSpheres(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let step = samples.count / config.numberOfObjects
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let sphereRadius = CGFloat(sample * config.objectSizeMultiplier)
            let sphereGeometry = SCNSphere(radius: sphereRadius)
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            let x = Float(i) / Float(samples.count) * 20 - 10
            let y = sample * 10 * config.objectSizeMultiplier
            sphereNode.position = SCNVector3(x, y, 0)
            
            sphereNode.geometry?.firstMaterial?.diffuse.contents = colorForSample(sample, index: i, count: samples.count, config: config)
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    private func addRadialObjects(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let step = samples.count / config.numberOfObjects
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let objectSize = CGFloat(sample * config.objectSizeMultiplier)
            let geometry: SCNGeometry
            
            switch config.visualizationType {
            case .boxes:
                geometry = SCNBox(width: objectSize, height: objectSize, length: objectSize, chamferRadius: 0)
            case .spheres, .radial:
                geometry = SCNSphere(radius: objectSize / 2)
            }
            
            let node = SCNNode(geometry: geometry)
            
            let angle = Float(i) / Float(samples.count) * Float.pi * 2
            let radius: Float = 10
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y = sample * 5 * config.objectSizeMultiplier
            node.position = SCNVector3(x, y, z)
            
            node.geometry?.firstMaterial?.diffuse.contents = colorForSample(sample, index: i, count: samples.count, config: config)
            
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func colorForSample(_ sample: Float, index: Int, count: Int, config: VisualizationConfig) -> NSColor {
        switch config.colorScheme {
        case .rainbow:
            let hue = CGFloat(index) / CGFloat(count)
            return NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        case .monochrome:
            return NSColor(white: CGFloat(sample), alpha: 1)
        case .custom:
            // You can implement custom color schemes here
            return NSColor(Color.blue)
        }
    }
}
