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
    
    private func analyzeAudio(_ url: URL) {
        let analyzer = AudioAnalyzer()
        audioSamples = analyzer.analyzeAudio(url: url)
    }
    
    func updateColorScheme(_ newColorScheme: ColorScheme) {
        visualizationConfig.colorScheme = newColorScheme
        updateVisualization()
    }
    
    func updateMood(_ newMood: Mood) {
        visualizationConfig.mood = newMood
        updateVisualization()
    }
    
    private func updateVisualization() {
        let sceneBuilder = SceneBuilder()
        scene = sceneBuilder.createScene(from: audioSamples, config: visualizationConfig)
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
    case boxes, spheres, radial, clouds, particles, waveform
}

enum ColorScheme: Equatable {
    case rainbow
    case monochrome
    case custom(ColorGradient)
    
    var name: String {
        switch self {
        case .rainbow: return "Rainbow"
        case .monochrome: return "Monochrome"
        case .custom: return "Custom Gradient"
        }
    }
    
    static var allCases: [ColorScheme] {
        [.rainbow, .monochrome, .custom(.init(colors: [.red, .blue]))]
    }
}

struct ColorGradient: Equatable {
    var colors: [Color]
    
    func interpolatedColor(at position: CGFloat) -> NSColor {
        guard !colors.isEmpty else { return .white }
        if colors.count == 1 { return NSColor(colors[0]) }
        
        let scaledPosition = position * CGFloat(colors.count - 1)
        let index = Int(scaledPosition)
        let nextIndex = min(index + 1, colors.count - 1)
        
        let color1 = NSColor(colors[index])
        let color2 = NSColor(colors[nextIndex])
        
        let t = scaledPosition - CGFloat(index)
        
        return color1.interpolated(to: color2, amount: CGFloat(t))
    }
}

extension NSColor {
    func interpolated(to other: NSColor, amount: CGFloat) -> NSColor {
        let r1 = self.redComponent
        let g1 = self.greenComponent
        let b1 = self.blueComponent
        let a1 = self.alphaComponent
        
        let r2 = other.redComponent
        let g2 = other.greenComponent
        let b2 = other.blueComponent
        let a2 = other.alphaComponent
        
        return NSColor(
            red: r1 + (r2 - r1) * amount,
            green: g1 + (g2 - g1) * amount,
            blue: b1 + (b2 - b1) * amount,
            alpha: a1 + (a2 - a1) * amount
        )
    }
}

enum Mood: String, CaseIterable {
    case day, night, foggy
    
    var backgroundColor: NSColor {
        switch self {
        case .day: return NSColor.cyan.withAlphaComponent(0.3)
        case .night: return NSColor.black.withAlphaComponent(0.8)
        case .foggy: return NSColor.gray.withAlphaComponent(0.5)
        }
    }
    
    var fogStartDistance: CGFloat {
        switch self {
        case .day: return 100
        case .night: return 50
        case .foggy: return 10
        }
    }
    
    var fogEndDistance: CGFloat {
        switch self {
        case .day: return 200
        case .night: return 100
        case .foggy: return 50
        }
    }
    
    var fogColor: NSColor {
        switch self {
        case .day: return NSColor.lightGray
        case .night: return NSColor.darkGray
        case .foggy: return NSColor.gray
        }
    }
}

extension SCNVector3: Equatable {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension ColorScheme: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .rainbow:
            hasher.combine(0)
        case .monochrome:
            hasher.combine(1)
        case .custom(let gradient):
            hasher.combine(2)
            hasher.combine(gradient.colors)
        }
    }
}
