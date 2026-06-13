import SwiftUI

struct MainTabView: View {
    @State private var viewModel = HabitViewModel()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "checkmark.circle.fill")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
        }
        .environment(viewModel)
        .tint(.indigo)
    }
}

#Preview {
    MainTabView()
}
