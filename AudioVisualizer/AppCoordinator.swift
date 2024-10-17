import SwiftUI
import SceneKit

class AppCoordinator: ObservableObject {
    @Published var currentScreen: Screen = .fileSelection
    @Published var audioURL: URL?
    @Published var visualizationConfig: VisualizationConfig = .default
    @Published var audioSamples: [Float] = []
    
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
        currentScreen = .visualization
    }
    
    private func analyzeAudio(_ url: URL) {
        let analyzer = AudioAnalyzer()
        audioSamples = analyzer.analyzeAudio(url: url)
    }
}

struct VisualizationConfig: Equatable {
    var visualizationType: VisualizationType = .boxes
    var colorScheme: ColorScheme = .rainbow
    var backgroundColor: Color = .black
    var objectSizeMultiplier: Float = 1.0
    var numberOfObjects: Int = 100
    var fogIntensity: Float = 0.5
    var fogColor: Color = .gray
    var floorReflectivity: Float = 0.5
    var cameraPosition: SCNVector3 = SCNVector3(x: 0, y: 10, z: 20)
    var cameraAngle: SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    
    static let `default` = VisualizationConfig()
    
    static func == (lhs: VisualizationConfig, rhs: VisualizationConfig) -> Bool {
        return lhs.visualizationType == rhs.visualizationType &&
        lhs.colorScheme == rhs.colorScheme &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.objectSizeMultiplier == rhs.objectSizeMultiplier &&
        lhs.numberOfObjects == rhs.numberOfObjects &&
        lhs.fogIntensity == rhs.fogIntensity &&
        lhs.fogColor == rhs.fogColor &&
        lhs.floorReflectivity == rhs.floorReflectivity &&
        lhs.cameraPosition == rhs.cameraPosition &&
        lhs.cameraAngle == rhs.cameraAngle
    }
}

enum VisualizationType: String, CaseIterable, Equatable {
    case boxes, spheres, radial
}

enum ColorScheme: String, CaseIterable, Equatable {
    case rainbow, monochrome, custom
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
