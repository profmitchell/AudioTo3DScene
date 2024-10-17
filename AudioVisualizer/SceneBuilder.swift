import SceneKit
import SwiftUI

class SceneBuilder {
    func createScene(from samples: [Float], config: VisualizationConfig) -> SCNScene {
        let scene = SCNScene()
        addFloor(to: scene, reflectivity: config.floorReflectivity)
        addCamera(to: scene, position: config.cameraPosition, angle: config.cameraAngle)
        addLighting(to: scene, mood: config.mood)
        
        switch config.visualizationType {
        case .boxes:
            addBoxes(from: samples, to: scene, config: config)
        case .spheres:
            addSpheres(from: samples, to: scene, config: config)
        case .radial:
            addRadialObjects(from: samples, to: scene, config: config)
        case .clouds:
            addClouds(from: samples, to: scene, config: config)
        case .particles:
            addParticles(from: samples, to: scene, config: config)
        case .waveform:
            addWaveform(from: samples, to: scene, config: config)
        }
        
        applyMood(to: scene, mood: config.mood)
        
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
        ambientLight.light?.color = mood.backgroundColor
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.eulerAngles = SCNVector3(x: -0.5, y: -0.5, z: 0)
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
            addGlow(to: boxNode)
            addRandomMaterial(to: boxNode)
            
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
            addGlow(to: sphereNode)
            addRandomMaterial(to: sphereNode)
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    private func addRadialObjects(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let step = samples.count / config.numberOfObjects
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let objectSize = CGFloat(sample * config.objectSizeMultiplier)
            let geometry = SCNBox(width: objectSize, height: objectSize, length: objectSize, chamferRadius: 0)
            let node = SCNNode(geometry: geometry)
            
            let angle = Float(i) / Float(samples.count) * Float.pi * 2
            let radius: Float = 10
            let x = radius * cos(angle)
            let z = radius * sin(angle)
            let y = sample * 5 * config.objectSizeMultiplier
            node.position = SCNVector3(x, y, z)
            
            node.geometry?.firstMaterial?.diffuse.contents = colorForSample(sample, index: i, count: samples.count, config: config)
            addGlow(to: node)
            addRandomMaterial(to: node)
            
            scene.rootNode.addChildNode(node)
        }
    }
    
    private func addClouds(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let cloudNode = SCNNode()
        let step = samples.count / (config.numberOfObjects * 10)
        
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let sphereRadius = CGFloat(sample * config.objectSizeMultiplier * 0.2)
            let sphereGeometry = SCNSphere(radius: sphereRadius)
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            let x = CGFloat.random(in: -10...10)
            let y = CGFloat.random(in: 5...15)
            let z = CGFloat.random(in: -10...10)
            sphereNode.position = SCNVector3(x, y, z)
            
            sphereNode.geometry?.firstMaterial?.diffuse.contents = colorForSample(sample, index: i, count: samples.count, config: config)
            sphereNode.geometry?.firstMaterial?.transparency = 0.7
            
            cloudNode.addChildNode(sphereNode)
        }
        
        scene.rootNode.addChildNode(cloudNode)
        
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 60)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        cloudNode.runAction(repeatAction)
    }
    
    private func addParticles(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleSize = 0.1
        particleSystem.particleColor = .white
        particleSystem.particleColorVariation = SCNVector4(1, 1, 1, 0.5)
        particleSystem.emitterShape = SCNBox(width: 20, height: 1, length: 1, chamferRadius: 0)
        particleSystem.birthRate = 1000
        particleSystem.particleLifeSpan = 2
        particleSystem.spreadingAngle = 45
        
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem)
        scene.rootNode.addChildNode(particleNode)
        
        // Create a force field to affect the particles based on audio samples
        let forceField = SCNPhysicsField.radialGravity()
        forceField.strength = 5
        forceField.falloffExponent = 2
        
        let step = samples.count / 100
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            let x = Float(i) / Float(samples.count) * 20 - 10
            let y = sample * 5 * config.objectSizeMultiplier
            let forceFieldNode = SCNNode()
            forceFieldNode.position = SCNVector3(x, y, 0)
            forceFieldNode.physicsField = forceField
            scene.rootNode.addChildNode(forceFieldNode)
        }
    }
    
    private func addWaveform(from samples: [Float], to scene: SCNScene, config: VisualizationConfig) {
        let step = samples.count / config.numberOfObjects
        var vertices: [SCNVector3] = []
        
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = samples[i]
            let x = Float(i) / Float(samples.count) * 20 - 10
            let y = sample * 5 * config.objectSizeMultiplier
            vertices.append(SCNVector3(x, y, 0))
        }
        
        let path = SCNGeometry.path(vertices: vertices, closed: false)
        let waveform = SCNGeometry.extrude(path: path, depth: 0.1)
        
        let waveformNode = SCNNode(geometry: waveform)
        waveformNode.geometry?.firstMaterial?.diffuse.contents = NSColor.white
        addGlow(to: waveformNode)
        
        scene.rootNode.addChildNode(waveformNode)
    }
    
    private func colorForSample(_ sample: Float, index: Int, count: Int, config: VisualizationConfig) -> NSColor {
        switch config.colorScheme {
        case .rainbow:
            let hue = CGFloat(index) / CGFloat(count)
            return NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        case .monochrome:
            return NSColor(white: CGFloat(sample), alpha: 1)
        case .custom(let gradient):
            return gradient.interpolatedColor(at: CGFloat(index) / CGFloat(count))
        }
    }
    
    private func addGlow(to node: SCNNode) {
        node.geometry?.firstMaterial?.emission.contents = node.geometry?.firstMaterial?.diffuse.contents
        node.geometry?.firstMaterial?.emission.intensity = 0.5
    }
    
    private func addRandomMaterial(to node: SCNNode) {
        let materials = [
            "metal": SCNMaterial.metallic(),
            "glass": SCNMaterial.glass(),
            "plastic": SCNMaterial.plastic()
        ]
        
        if let randomMaterial = materials.randomElement()?.value {
            node.geometry?.firstMaterial = randomMaterial
        }
    }
    
    private func applyMood(to scene: SCNScene, mood: Mood) {
        scene.background.contents = mood.backgroundColor
        scene.fogStartDistance = mood.fogStartDistance
        scene.fogEndDistance = mood.fogEndDistance
        scene.fogColor = mood.fogColor
    }
}

extension SCNMaterial {
    static func metallic() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 1.0
        material.roughness.contents = 0.5
        return material}
    
    static func glass() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.0
        material.roughness.contents = 0.2
        material.transparency = 0.5
        return material
    }
    
    static func plastic() -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.0
        material.roughness.contents = 0.3
        return material
    }
}

extension SCNGeometry {
    static func path(vertices: [SCNVector3], closed: Bool) -> SCNGeometry {
        let path = SCNGeometry.bezierPath(vertices: vertices, closed: closed)
        return SCNShape(path: path, extrusionDepth: 0)
    }
    
    static func extrude(path: SCNGeometry, depth: CGFloat) -> SCNGeometry {
        guard let shape = path as? SCNShape else { return path }
        return SCNShape(path: shape.path, extrusionDepth: depth)
    }
    
    static func bezierPath(vertices: [SCNVector3], closed: Bool) -> NSBezierPath {
        let path = NSBezierPath()
        if let first = vertices.first {
            path.move(to: NSPoint(x: CGFloat(first.x), y: CGFloat(first.y)))
        }
        for vertex in vertices.dropFirst() {
            path.line(to: NSPoint(x: CGFloat(vertex.x), y: CGFloat(vertex.y)))
        }
        if closed {
            path.close()
        }
        return path
    }
}
