//
//  ContentView.swift
//  AudioVisualizer
//
//  Created by Mitchell Cohen on 10/5/24.
//
import SwiftUI
import SceneKit
import AVFoundation

struct ContentView: View {
    @State private var audioURL: URL?
    @State private var sceneView: SCNView?
    
    var body: some View {
        VStack {
            if let sceneView = sceneView {
                SceneView(scene: sceneView.scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                    .frame(width: 700, height: 700)
                    
            } else {
                Text("Select an audio file to visualize")
            }
            
            Button("Select Audio File") {
                selectAudioFile()
            }
        }
        .padding()
    }
    
    private func selectAudioFile() {
        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                audioURL = url
                analyzeAudioAndCreateScene(url: url)
            }
        }
    }
    
    private func analyzeAudioAndCreateScene(url: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let format = audioFile.processingFormat
            let frameCount = UInt32(audioFile.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
            try audioFile.read(into: buffer)
            
            guard let channelData = buffer.floatChannelData?[0] else { return }
            
            let sampleCount = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: channelData, count: sampleCount))
            
            createScene(from: samples)
        } catch {
            print("Error analyzing audio: \(error)")
        }
    }
    
    private func createScene(from samples: [Float]) {
        let scene = SCNScene()
        
        // Create a floor
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0.5
        let floorNode = SCNNode(geometry: floorGeometry)
        scene.rootNode.addChildNode(floorNode)
        
        // Add fog
        scene.fogStartDistance = 10
        scene.fogEndDistance = 50
        scene.fogColor = NSColor.gray
        
        // Create objects based on audio data
        let step = samples.count / 100 // Reduce number of objects for performance
        for i in stride(from: 0, to: samples.count, by: step) {
            let sample = abs(samples[i])
            
            let boxSize = CGFloat(sample * 5)
            let boxGeometry = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0)
            let boxNode = SCNNode(geometry: boxGeometry)
            
            let x = Float(i) / Float(samples.count) * 20 - 10
            let y = sample * 10
            boxNode.position = SCNVector3(x, y, 0)
            
            let hue = CGFloat(i) / CGFloat(samples.count)
            boxNode.geometry?.firstMaterial?.diffuse.contents = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            
            scene.rootNode.addChildNode(boxNode)
        }
        
        // Set up camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 20)
        scene.rootNode.addChildNode(cameraNode)
        
        // Create SceneView
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .black
        
        self.sceneView = sceneView
    }
}
