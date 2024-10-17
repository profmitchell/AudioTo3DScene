import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var config: VisualizationConfig
    @State private var showGradientPicker = false
    @State private var customGradient = ColorGradient(colors: [.red, .blue])
    
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
                        Text(scheme.name).tag(scheme)
                    }
                }
                
                if case .custom = config.colorScheme {
                    Button("Edit Custom Gradient") {
                        showGradientPicker = true
                    }
                }
                
                Slider(value: $config.objectSizeMultiplier, in: 0.1...5) {
                    Text("Object Size Multiplier: \(config.objectSizeMultiplier, specifier: "%.2f")")
                }
                
                Stepper("Number of Objects: \(config.numberOfObjects)", value: $config.numberOfObjects, in: 10...1000, step: 10)
                
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
            
            Section {
                Button("Generate Visualization") {
                    coordinator.visualizationConfig = config
                    coordinator.generateVisualization()
                }
            }
        }
        .sheet(isPresented: $showGradientPicker) {
            GradientPickerView(gradient: $customGradient) {
                config.colorScheme = .custom(customGradient)
                coordinator.updateColorScheme(config.colorScheme)
            }
        }
    }
}

struct GradientPickerView: View {
    @Binding var gradient: ColorGradient
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                LinearGradient(gradient: Gradient(colors: gradient.colors), startPoint: .leading, endPoint: .trailing)
                    .frame(height: 50)
                    .cornerRadius(10)
                    .padding()
                
                List {
                    ForEach(gradient.colors.indices, id: \.self) { index in
                        ColorPicker("Color \(index + 1)", selection: $gradient.colors[index])
                    }
                    .onDelete { indices in
                        gradient.colors.remove(atOffsets: indices)
                    }
                }
                
                Button("Add Color") {
                    gradient.colors.append(.white)
                }
                .padding()
            }
            .navigationTitle("Custom Gradient")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
