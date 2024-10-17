import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var config: VisualizationConfig
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _config = State(initialValue: coordinator.visualizationConfig)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Visualization Settings")) {
                Picker("Visualization Type", selection: $config.visualizationType) {
                    ForEach(VisualizationType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                
                Picker("Color Scheme", selection: $config.colorScheme) {
                    ForEach(ColorScheme.allCases, id: \.self) { scheme in
                        Text(scheme.rawValue.capitalized).tag(scheme)
                    }
                }
                
                ColorPicker("Background Color", selection: $config.backgroundColor)
                
                Slider(value: $config.objectSizeMultiplier, in: 0.1...5) {
                    Text("Object Size Multiplier: \(config.objectSizeMultiplier, specifier: "%.2f")")
                }
                
                Stepper("Number of Objects: \(config.numberOfObjects)", value: $config.numberOfObjects, in: 10...1000, step: 10)
                
                Slider(value: $config.fogIntensity, in: 0...1) {
                    Text("Fog Intensity: \(config.fogIntensity, specifier: "%.2f")")
                }
                
                ColorPicker("Fog Color", selection: $config.fogColor)
                
                Slider(value: $config.floorReflectivity, in: 0...1) {
                    Text("Floor Reflectivity: \(config.floorReflectivity, specifier: "%.2f")")
                }
            }
            
            Section(header: Text("Camera Settings")) {
                VStack(alignment: .leading) {
                    Text("Camera Position")
                    HStack {
                        TextField("X", value: $config.cameraPosition.x, formatter: NumberFormatter())
                        TextField("Y", value: $config.cameraPosition.y, formatter: NumberFormatter())
                        TextField("Z", value: $config.cameraPosition.z, formatter: NumberFormatter())
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Camera Angle")
                    HStack {
                        TextField("X", value: $config.cameraAngle.x, formatter: NumberFormatter())
                        TextField("Y", value: $config.cameraAngle.y, formatter: NumberFormatter())
                        TextField("Z", value: $config.cameraAngle.z, formatter: NumberFormatter())
                    }
                }
            }
            
            Button("Generate Visualization") {
                coordinator.visualizationConfig = config
                coordinator.generateVisualization()
            }
            .padding()
        }
        .padding()
    }
}