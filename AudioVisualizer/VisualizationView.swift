import SwiftUI
import SceneKit

struct VisualizationView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var sceneView: SCNView?
    @State private var isExporting = false
    @State private var exportType: ExportType = .image
    
    enum ExportType: String, CaseIterable {
        case image, video
    }
    
    var body: some View {
        VStack {
            if let sceneView = sceneView {
                SceneView(scene: sceneView.scene, options: [.allowsCameraControl, .autoenablesDefaultLighting])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ProgressView("Loading visualization...")
            }
            
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
            }
            .padding()
        }
        .onAppear {
            createVisualization()
        }
        .alert(isPresented: $isExporting) {
            Alert(
                title: Text("Export \(exportType.rawValue.capitalized)"),
                message: Text("This feature is not yet implemented."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func createVisualization() {
        let sceneBuilder = SceneBuilder()
        let scene = sceneBuilder.createScene(from: coordinator.audioSamples, config: coordinator.visualizationConfig)
        
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = NSColor(coordinator.visualizationConfig.backgroundColor)
        
        self.sceneView = sceneView
    }
}