import SwiftUI

struct FileSelectionView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Select an audio file to visualize")
                .font(.title)
                .padding()
            
            Button("Select Audio File") {
                selectAudioFile()
            }
            .padding()
        }
    }
    
    private func selectAudioFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            coordinator.selectAudioFile(url)
        }
    }
}
