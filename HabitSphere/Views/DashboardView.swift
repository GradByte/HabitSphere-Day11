import SwiftUI

struct DashboardView: View {
    @Environment(HabitViewModel.self) private var viewModel
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Date and Progress
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Date(), format: .dateTime.weekday(.wide).month().day())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                
                                Text("Today")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                            
                            // Progress Ring
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(viewModel.todayProgress))
                                    .stroke(Color.indigo, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.todayProgress)
                                
                                Text("\(Int(viewModel.todayProgress * 100))%")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .frame(width: 60, height: 60)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        if viewModel.habits.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 48))
                                    .foregroundColor(.indigo.opacity(0.5))
                                Text("No habits yet. Let's build some routines!")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.habits) { habit in
                                    HabitCardView(habit: habit) {
                                        viewModel.toggleHabit(habit)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarHidden(true)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    showingAddHabit = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.indigo)
                        .clipShape(Circle())
                        .shadow(color: .indigo.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding()
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
    }
}
