import SwiftUI
import SceneKit

struct VisualizationView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var exportType: ExportType = .image
    @State private var showSettings = false
    @State private var showMoodSelector = false
    @State private var sceneUpdateCounter = 0
    
    enum ExportType: String, CaseIterable {
        case image, video
    }
    
    var body: some View {
        ZStack {
            if let scene = coordinator.scene {
                SceneView(scene: scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(sceneUpdateCounter)
            } else {
                ProgressView("Loading visualization...")
            }
            
            VStack {
                Spacer()
                
                ControlPanel()
            }
        }
        .onReceive(coordinator.objectWillChange) { _ in
            sceneUpdateCounter += 1
        }
    }
    
    @ViewBuilder
    private func ControlPanel() -> some View {
        VStack {
            HStack {
                Button("Choose New") {
                    coordinator.currentScreen = .fileSelection
                }
                
                Button("Center View") {
                    resetCameraView()
                }
                
                Picker("Export Type", selection: $exportType) {
                    ForEach(ExportType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
                
                Button("Export") {
                    exportVisualization()
                }
                
                Button("Settings") {
                    showSettings.toggle()
                }
                
                Button("Mood") {
                    showMoodSelector.toggle()
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
        }
        .padding()
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showMoodSelector) {
            MoodSelectorView(coordinator: coordinator)
        }
    }
    
    private func resetCameraView() {
        guard let cameraNode = coordinator.scene?.rootNode.childNode(withName: "camera", recursively: true) else { return }
        
        let resetPosition = SCNVector3(x: 0, y: 10, z: 20)
        let resetRotation = SCNVector3(x: -0.5, y: 0, z: 0)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        cameraNode.position = resetPosition
        cameraNode.eulerAngles = resetRotation
        SCNTransaction.commit()
    }
    
    private func exportVisualization() {
        // Implement export functionality here
        print("Exporting \(exportType.rawValue)")
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Camera Controls")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("• Option + Scroll Up/Down: Move camera forward/backward")
                Text("• Scroll Up/Down/Left/Right: Pan camera")
                Text("• Left Click + Drag: Orbit camera")
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct MoodSelectorView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var selectedMood: Mood = .day
    
    var body: some View {
        VStack {
            Picker("Mood", selection: $selectedMood) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text(mood.rawValue.capitalized).tag(mood)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Apply Mood") {
                coordinator.updateMood(selectedMood)
            }
            .padding()
        }
    }
}
