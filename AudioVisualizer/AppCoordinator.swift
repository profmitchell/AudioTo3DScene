import SwiftUI
import SceneKit

class AppCoordinator: ObservableObject {
    @Published var currentScreen: Screen = .fileSelection
    @Published var audioURL: URL?
    @Published var visualizationConfig: VisualizationConfig = .default
    @Published var audioSamples: [Float] = []
    @Published var scene: SCNScene?
    
    enum Screen {
        case fileSelection
        case configuration
        case visualization
    }
    
    func selectAudioFile(_ url: URL) {
        audioURL = url
        analyzeAudio(url)
        currentScreen = .configuration
    }
    
    func generateVisualization() {
        let sceneBuilder = SceneBuilder()
        scene = sceneBuilder.createScene(from: audioSamples, config: visualizationConfig)
        currentScreen = .visualization
    }
    
    func updateMood(_ newMood: Mood) {
        visualizationConfig.mood = newMood
        updateSceneMood()
    }
    
    private func analyzeAudio(_ url: URL) {
        let analyzer = AudioAnalyzer()
        audioSamples = analyzer.analyzeAudio(url: url)
    }
    
    func updateSceneMood() {
        guard let scene = scene else { return }
        
        // Update background color
        scene.background.contents = visualizationConfig.mood.backgroundColor
        
        // Update lighting
        if let ambientLight = scene.rootNode.childNode(withName: "ambientLight", recursively: true),
           let light = ambientLight.light {
            light.color = visualizationConfig.mood.ambientLightColor
        }
        
        if let directionalLight = scene.rootNode.childNode(withName: "directionalLight", recursively: true),
           let light = directionalLight.light {
            light.color = visualizationConfig.mood.directionalLightColor
        }
        
        // Update fog
        scene.fogStartDistance = visualizationConfig.mood.fogStartDistance
        scene.fogEndDistance = visualizationConfig.mood.fogEndDistance
        scene.fogColor = visualizationConfig.mood.fogColor
        
        objectWillChange.send()
    }
}

struct VisualizationConfig: Equatable {
    var visualizationType: VisualizationType = .boxes
    var colorScheme: ColorScheme = .rainbow
    var objectSizeMultiplier: Float = 1.0
    var numberOfObjects: Int = 100
    var floorReflectivity: Float = 0.5
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 10, z: 20)
    var cameraAngle: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    var mood: Mood = .day
    
    static let `default` = VisualizationConfig()
    
    static func == (lhs: VisualizationConfig, rhs: VisualizationConfig) -> Bool {
        return lhs.visualizationType == rhs.visualizationType &&
        lhs.colorScheme == rhs.colorScheme &&
        lhs.objectSizeMultiplier == rhs.objectSizeMultiplier &&
        lhs.numberOfObjects == rhs.numberOfObjects &&
        lhs.floorReflectivity == rhs.floorReflectivity &&
        lhs.cameraPosition == rhs.cameraPosition &&
        lhs.cameraAngle == rhs.cameraAngle &&
        lhs.mood == rhs.mood
    }
}

enum VisualizationType: String, CaseIterable, Equatable {
    case boxes, spheres, radial
}

enum ColorScheme: String, CaseIterable, Equatable {
    case rainbow, monochrome, custom
}

enum Mood: String, CaseIterable, Equatable {
    case day, night, foggy
    
    var backgroundColor: NSColor {
        switch self {
        case .day:
            return NSColor(red: 0.529, green: 0.808, blue: 0.922, alpha: 1.0) // Sky blue
        case .night:
            return NSColor(red: 0.059, green: 0.059, blue: 0.133, alpha: 1.0) // Dark blue
        case .foggy:
            return NSColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1.0) // Light gray
        }
    }
    
    var ambientLightColor: NSColor {
        switch self {
        case .day:
            return NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        case .night:
            return NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        case .foggy:
            return NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        }
    }
    
    var directionalLightColor: NSColor {
        switch self {
        case .day:
            return NSColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0) // Warm sunlight
        case .night:
            return NSColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0) // Dim moonlight
        case .foggy:
            return NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) // Diffused light
        }
    }
    
    var fogColor: NSColor {
        switch self {
        case .day:
            return NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0) // Very light gray
        case .night:
            return NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Very dark blue
        case .foggy:
            return NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light gray
        }
    }
    
    var fogStartDistance: CGFloat {
        switch self {
        case .day:
            return 100
        case .night:
            return 50
        case .foggy:
            return 10
        }
    }
    
    var fogEndDistance: CGFloat {
        switch self {
        case .day:
            return 200
        case .night:
            return 100
        case .foggy:
            return 50
        }
    }
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
