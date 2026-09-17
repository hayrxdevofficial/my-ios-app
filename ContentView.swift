import SwiftUI

// Модель одного апгрейда
struct Upgrade: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let baseCost: Int
    let incomePerSecond: Int
}

struct ContentView: View {
    // Состояние игры
    @State private var score: Int = 0
    @State private var totalClicks: Int = 0
    @State private var upgrades: [Upgrade] = [
        Upgrade(name: "Кликер v2", description: "+1 к клику", baseCost: 10, incomePerSecond: 0),
        Upgrade(name: "Авто-клик", description: "+1/сек", baseCost: 25, incomePerSecond: 1),
        Upgrade(name: "Ферма кликов", description: "+5/сек", baseCost: 100, incomePerSecond: 5),
        Upgrade(name: "Фабрика", description: "+25/сек", baseCost: 500, incomePerSecond: 25),
        Upgrade(name: "Корпорация", description: "+100/сек", baseCost: 2500, incomePerSecond: 100)
    ]
    @State private var upgradeLevels: [UUID: Int] = [:]
    
    // Таймер для пассивного дохода
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Счёт и статистика
                VStack {
                    Text("💰 \(score)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    Text("Всего кликов: \(totalClicks)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                // Большая кнопка клика
                Button {
                    let clickPower = 1 + (upgradeLevels[upgrades[0].id] ?? 0)
                    score += clickPower
                    totalClicks += 1
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                            .shadow(radius: 10)
                        Text("КЛИК")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(1.0)
                .animation(.spring(response: 0.2), value: score)

                // Список апгрейдов
                List {
                    Section("Апгрейды") {
                        ForEach(upgrades) { upgrade in
                            UpgradeRow(
                                upgrade: upgrade,
                                level: upgradeLevels[upgrade.id] ?? 0,
                                score: score,
                                onBuy: {
                                    buy(upgrade)
                                }
                            )
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Clicker")
            .onReceive(timer) { _ in
                // Пассивный доход каждую секунду
                let income = calculateIncome()
                score += income
            }
        }
    }
    
    // Подсчёт пассивного дохода
    func calculateIncome() -> Int {
        var total = 0
        for upgrade in upgrades where upgrade.incomePerSecond > 0 {
            let level = upgradeLevels[upgrade.id] ?? 0
            total += level * upgrade.incomePerSecond
        }
        return total
    }
    
    // Покупка апгрейда
    func buy(_ upgrade: Upgrade) {
        let level = upgradeLevels[upgrade.id] ?? 0
        let cost = upgrade.baseCost * (level + 1) // Растущая цена
        guard score >= cost else { return }
        score -= cost
        upgradeLevels[upgrade.id] = level + 1
    }
}

// Строка апгрейда
struct UpgradeRow: View {
    let upgrade: Upgrade
    let level: Int
    let score: Int
    let onBuy: () -> Void
    
    var currentCost: Int {
        upgrade.baseCost * (level + 1)
    }
    
    var canAfford: Bool {
        score >= currentCost
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(upgrade.name)
                    .font(.headline)
                Text(upgrade.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if level > 0 {
                    Text("Уровень: \(level)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            Spacer()
            Button {
                onBuy()
            } label: {
                Text("\(currentCost) 💰")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(canAfford ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!canAfford)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
