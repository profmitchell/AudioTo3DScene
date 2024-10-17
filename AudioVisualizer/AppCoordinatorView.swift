import SwiftUI

struct AppCoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .fileSelection:
                FileSelectionView(coordinator: coordinator)
            case .configuration:
                ConfigurationView(coordinator: coordinator)
            case .visualization:
                VisualizationView(coordinator: coordinator)
            }
        }
    }
}