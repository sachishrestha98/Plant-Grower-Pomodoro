import SwiftUI

enum SessionType {
    case work
    case breakTime
}

// Growth stages: soil → seed → sprout → tree
let plantStages = ["square.fill", "circle.fill", "leaf.fill", "tree.fill"]

struct FarmPlot: Identifiable, Codable {
    let id: UUID
    var stage: Int
}

struct ContentView: View {
    // Timer state
    @State private var timeRemaining = 25 * 60
    @State private var timerRunning = false
    @State private var timer: Timer?
    @State private var sessionType: SessionType = .work

    // Garden (persist using JSON)
    @AppStorage("farmData") private var farmData: String = ""
    @State private var farm: [FarmPlot] = []

    // Durations (use small values for testing)
    private let workDuration = 1*5//25 * 60
    private let breakDuration = 5 * 60

    // Garden size (fixed)
    private let gardenSize = 6
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(spacing: 16) {
            // Garden header
            Text("Your Garden")
                .font(.headline)

            // Garden grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(farm) { plot in
                    let stage = min(plot.stage, plantStages.count - 1)
                    Image(systemName: plantStages[stage])
                        .font(.system(size: 36))
                        .foregroundColor(stage == 0 ? .brown : .green)
                        .frame(width: 60, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.brown.opacity(0.15))
                        )
                }
            }
            .padding()

            Divider()

            // Session label
            Text(sessionType == .work ? "Work Session" : "Break")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Timer display
            Text(formatTime(timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding(.top, 6)

            // Controls
            HStack(spacing: 20) {
                Button(timerRunning ? "Pause" : "Start") {
                    if timerRunning { pauseTimer() } else { startTimer() }
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    resetTimer()
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 24)

            Spacer()
        }
        .onAppear {
            loadFarm()
            timeRemaining = workDuration
        }
        .onDisappear {
            timer?.invalidate()
        }
        .padding()
    }

    // MARK: - Timer
    func startTimer() {
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                timerRunning = false

                if sessionType == .work {
                    growNextPlant()
                    sessionType = .breakTime
                    timeRemaining = breakDuration
                } else {
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

    // MARK: - Garden Logic
    func growNextPlant() {
        if let index = farm.firstIndex(where: { $0.stage < plantStages.count - 1 }) {
            farm[index].stage += 1
            saveFarm()
        }
    }

    func loadFarm() {
        if let data = farmData.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([FarmPlot].self, from: data) {
            farm = decoded
        } else {
            farm = Array(repeating: FarmPlot(id: UUID(), stage: 0), count: gardenSize)
        }
    }

    func saveFarm() {
        if let encoded = try? JSONEncoder().encode(farm),
           let jsonString = String(data: encoded, encoding: .utf8) {
            farmData = jsonString
        }
    }
}

#Preview {
    ContentView()
}
