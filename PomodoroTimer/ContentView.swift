import SwiftUI

enum SessionType {
    case work
    case breakTime
}

struct ContentView: View {
    // Timer state
    @State private var timeRemaining = 25 * 60
    @State private var timerRunning = false
    @State private var timer: Timer?
    
    // Session state
    @State private var sessionType: SessionType = .work
    
    // Persisted plant count
    @AppStorage("plantCount") private var plantCount: Int = 0
    
    // Durations
    private let workDuration = 1*1//25 * 60
    private let breakDuration = 1*2//5 * 60   // short break

    var body: some View {
        VStack(spacing: 20) {
            // Plant counter
            VStack {
                Text("Your Plants")
                    .font(.headline)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(0..<plantCount, id: \.self) { _ in
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 200) // Limit the garden height
            }
            .padding(.horizontal)



            // Session label
            Text(sessionType == .work ? "Work Session" : "Break")
                .font(.headline)

            // Timer display
            Text(formatTime(timeRemaining))
                .font(.system(size: 50, weight: .bold, design: .monospaced))
                .padding()

            // Controls
            HStack {
                Button(timerRunning ? "Pause" : "Start") {
                    if timerRunning { pauseTimer() } else { startTimer() }
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    resetTimer()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            timeRemaining = workDuration
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // Timer helpers
    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                timerRunning = false
                
                if sessionType == .work {
                    // ✅ Only add a plant for completed work sessions
                    plantCount += 1
                    // Switch to break
                    sessionType = .breakTime
                    timeRemaining = breakDuration
                } else {
                    // Switch back to work
                    sessionType = .work
                    timeRemaining = workDuration
                }
            }
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timerRunning = false
    }

    func resetTimer() {
        timer?.invalidate()
        timerRunning = false
        sessionType = .work
        timeRemaining = workDuration
    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    ContentView()
}
