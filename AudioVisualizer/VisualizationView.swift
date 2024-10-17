import SwiftUI
import SceneKit

struct VisualizationView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var sceneView: SCNView?
    @State private var isExporting = false
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
                HStack {
                    Button("Change Visualization") {
                        coordinator.currentScreen = .configuration
                    }
                    
                    Picker("Export Type", selection: $exportType) {
                        ForEach(ExportType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                    
                    Button("Export") {
                        isExporting = true
                    }
                    
                    Button("Settings") {
                        showSettings.toggle()
                    }
                    
                    Button("Mood") {
                        showMoodSelector.toggle()
                    }
                }
                .padding()
            }
        }
        .onReceive(coordinator.objectWillChange) { _ in
            sceneUpdateCounter += 1
        }
        .alert(isPresented: $isExporting) {
            Alert(
                title: Text("Export \(exportType.rawValue.capitalized)"),
                message: Text("This feature is not yet implemented."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showMoodSelector) {
            MoodSelectorView(coordinator: coordinator)
        }
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
