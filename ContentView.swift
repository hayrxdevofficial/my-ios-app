import SwiftUI

// MARK: - Модели

struct Pipe: Identifiable {
    let id = UUID()
    var x: CGFloat
    let gapY: CGFloat
    let gapHeight: CGFloat
    var passed: Bool = false
}

struct Coin: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var collected: Bool = false
}

struct Skin: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Int
}

let ALL_SKINS: [Skin] = [
    Skin(id: "bird",  name: "Сунгаров ЭНЕРГИТИЧЕСКИЙ МОНСТЕР",            price: 0),
    Skin(id: "bird1", name: "Сунгаров ЭНЕРГИТИЧЕСКИЙ МОНСТЕР ФИОЛЕТОВЫЙ", price: 20)
]

enum AppScreen {
    case menu
    case game
    case skins
}

// MARK: - Стор

final class GameStore: ObservableObject {
    @Published var coins: Int {
        didSet { UserDefaults.standard.set(coins, forKey: "coins") }
    }
    @Published var ownedSkins: [String] {
        didSet { UserDefaults.standard.set(ownedSkins, forKey: "ownedSkins") }
    }
    @Published var selectedSkin: String {
        didSet { UserDefaults.standard.set(selectedSkin, forKey: "selectedSkin") }
    }

    init() {
        self.coins = UserDefaults.standard.integer(forKey: "coins")
        self.ownedSkins = UserDefaults.standard.stringArray(forKey: "ownedSkins") ?? ["bird"]
        self.selectedSkin = UserDefaults.standard.string(forKey: "selectedSkin") ?? "bird"
    }

    func buy(_ skin: Skin) -> Bool {
        guard !ownedSkins.contains(skin.id) else { return false }
        guard coins >= skin.price else { return false }
        coins -= skin.price
        ownedSkins.append(skin.id)
        return true
    }

    func select(_ skin: Skin) {
        guard ownedSkins.contains(skin.id) else { return }
        selectedSkin = skin.id
    }
}

// MARK: - Корень

struct ContentView: View {
    @StateObject private var store = GameStore()
    @State private var screen: AppScreen = .menu

    var body: some View {
        ZStack {
            switch screen {
            case .menu:
                MainMenuView(
                    store: store,
                    onStart: { withAnimation(.easeInOut(duration: 0.3)) { screen = .game } },
                    onSkins: { withAnimation(.easeInOut(duration: 0.3)) { screen = .skins } }
                )
                .transition(.opacity)
            case .game:
                GameView(
                    store: store,
                    onExitToMenu: { withAnimation(.easeInOut(duration: 0.3)) { screen = .menu } }
                )
                .transition(.opacity)
            case .skins:
                SkinsView(
                    store: store,
                    onBack: { withAnimation(.easeInOut(duration: 0.3)) { screen = .menu } }
                )
                .transition(.opacity)
            }
        }
        .environmentObject(store)
    }
}

// MARK: - Главное меню

struct MainMenuView: View {
    @ObservedObject var store: GameStore
    let onStart: () -> Void
    let onSkins: () -> Void

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.45, green: 0.78, blue: 0.98),
                             Color(red: 0.75, green: 0.92, blue: 1.0)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(red: 0.55, green: 0.85, blue: 0.35))
                        .frame(height: 80 + safeBottom)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.45, green: 0.75, blue: 0.25))
                                .frame(height: 14),
                            alignment: .top
                        )
                }.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Шапка: монеты
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                            Text("\(store.coins)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, safeTop + 8)

                    // Заголовок
                    VStack(spacing: 2) {
                        Text("Sungarov")
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                        Text("Energiya")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                        Text("Flappy")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 8)

                    AnimatedBird(imageName: store.selectedSkin, size: min(w, h) * 0.30)

                    Spacer(minLength: 8)

                    Button(action: onStart) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text("Играть")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 260)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.55, blue: 0.15),
                                         Color(red: 0.92, green: 0.35, blue: 0.05)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    Button(action: onSkins) {
                        HStack(spacing: 8) {
                            Image(systemName: "paintpalette.fill")
                            Text("Скины")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 260)
                        .padding(.vertical, 14)
                        .background(Color.black.opacity(0.25))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)

                    Text("Рекорд: \(UserDefaults.standard.integer(forKey: "bestScore"))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .padding(.top, 12)

                    Spacer().frame(height: max(safeBottom, 20) + 12)
                }
            }
        }
        .statusBarHidden(true)
    }
}

// MARK: - Экран скинов

struct SkinsView: View {
    @ObservedObject var store: GameStore
    let onBack: () -> Void

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.18, blue: 0.28),
                             Color(red: 0.08, green: 0.10, blue: 0.18)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Скины")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                            Text("\(store.coins)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, safeTop + 8)

                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(ALL_SKINS) { skin in
                                SkinRow(skin: skin, store: store)
                            }
                        }
                        .padding(16)
                    }

                    Spacer().frame(height: safeBottom)
                }
            }
        }
        .statusBarHidden(true)
    }
}

struct SkinRow: View {
    let skin: Skin
    @ObservedObject var store: GameStore

    var isOwned: Bool { store.ownedSkins.contains(skin.id) }
    var isSelected: Bool { store.selectedSkin == skin.id }
    var canAfford: Bool { store.coins >= skin.price }

    var body: some View {
        HStack(spacing: 14) {
            Image(skin.id)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 72, height: 72)
                .padding(6)
                .background(Color.white.opacity(0.08))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(skin.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .fixedSize(horizontal: false, vertical: true)

                if isOwned {
                    Text(isSelected ? "Выбран" : "Куплен")
                        .font(.caption)
                        .foregroundColor(isSelected ? .green : .gray)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                        Text("\(skin.price)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }

            Spacer()

            if isOwned {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.green)
                } else {
                    Button { store.select(skin) } label: {
                        Text("Выбрать")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(11)
                    }
                }
            } else {
                Button {
                    _ = store.buy(skin)
                } label: {
                    Text("Купить")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(canAfford ? Color.orange : Color.gray)
                        .cornerRadius(11)
                }
                .disabled(!canAfford)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Анимированный персонаж (крутится на месте)

struct AnimatedBird: View {
    let imageName: String
    let size: CGFloat
    @State private var angle: Double = 0

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(angle))
            .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 5)
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }
}

// MARK: - Игра

struct GameView: View {
    @ObservedObject var store: GameStore
    let onExitToMenu: () -> Void

    @State private var birdY: CGFloat = 0
    @State private var birdVelocity: CGFloat = 0
    @State private var pipes: [Pipe] = []
    @State private var coins: [Coin] = []
    @State private var score: Int = 0
    @State private var earnedCoins: Int = 0
    @State private var bestScore: Int = UserDefaults.standard.integer(forKey: "bestScore")
    @State private var isGameOver: Bool = false
    @State private var isStarted: Bool = false

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom

            // Умеренные размеры — играбельно и крупно
            let groundHeight: CGFloat = h * 0.09
            let birdSize: CGFloat = w * 0.12
            let pipeWidth: CGFloat = w * 0.20
            let gapHeight: CGFloat = h * 0.28
            let pipeSpacing: CGFloat = w * 0.70
            let pipeSpeed: CGFloat = w * 0.0055
            let gravity: CGFloat = h * 0.00085
            let coinSize: CGFloat = w * 0.09
            let birdX = w * 0.28

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.45, green: 0.78, blue: 0.98),
                             Color(red: 0.75, green: 0.92, blue: 1.0)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(red: 0.55, green: 0.85, blue: 0.35))
                        .frame(height: groundHeight + safeBottom)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.45, green: 0.75, blue: 0.25))
                                .frame(height: 12),
                            alignment: .top
                        )
                }.ignoresSafeArea()

                ForEach(pipes) { pipe in
                    pipeView(
                        pipe: pipe, screenHeight: h,
                        pipeWidth: pipeWidth, gapHeight: gapHeight,
                        groundHeight: groundHeight, safeBottom: safeBottom
                    )
                }

                ForEach(coins) { coin in
                    if !coin.collected {
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.85, blue: 0.2))
                                .frame(width: coinSize, height: coinSize)
                                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                            Circle()
                                .stroke(Color(red: 0.9, green: 0.65, blue: 0.05), lineWidth: 3)
                                .frame(width: coinSize, height: coinSize)
                            Image(systemName: "star.fill")
                                .font(.system(size: coinSize * 0.45))
                                .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.5))
                        }
                        .position(x: coin.x, y: coin.y)
                    }
                }

                Image(store.selectedSkin)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: birdSize, height: birdSize)
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                    .rotationEffect(.degrees(Double(birdVelocity) * 2))
                    .position(x: birdX, y: birdY)

                VStack {
                    Text("\(score)")
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                        .padding(.top, safeTop + 8)
                    Text("Рекорд: \(bestScore)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2)

                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                        Text("\(earnedCoins)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(16)
                    .padding(.top, 6)

                    Spacer()
                }

                if !isStarted && !isGameOver {
                    VStack {
                        HStack {
                            Button(action: onExitToMenu) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(11)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                            .padding(.leading, 16)
                            Spacer()
                        }
                        .padding(.top, safeTop + 4)
                        Spacer()
                    }
                }

                if !isStarted && !isGameOver { startOverlay }
                if isGameOver { gameOverOverlay }
            }
            .contentShape(Rectangle())
            .onTapGesture { handleTap() }
            .onAppear {
                birdY = (h - groundHeight) * 0.5
            }
            .onReceive(timer) { _ in
                if isStarted && !isGameOver {
                    updateGame(
                        screenW: w, screenH: h,
                        groundHeight: groundHeight, safeTop: safeTop, safeBottom: safeBottom,
                        birdSize: birdSize, pipeWidth: pipeWidth, gapHeight: gapHeight,
                        pipeSpacing: pipeSpacing, pipeSpeed: pipeSpeed,
                        gravity: gravity,
                        coinSize: coinSize, birdX: birdX
                    )
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    func pipeView(pipe: Pipe, screenHeight: CGFloat, pipeWidth: CGFloat,
                  gapHeight: CGFloat, groundHeight: CGFloat, safeBottom: CGFloat) -> some View {
        let topHeight = max(0, pipe.gapY - gapHeight / 2)
        let bottomY = pipe.gapY + gapHeight / 2
        let bottomHeight = max(0, screenHeight - bottomY - groundHeight - safeBottom)

        return ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.75, blue: 0.3),
                                              Color(red: 0.15, green: 0.55, blue: 0.2)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: pipeWidth, height: topHeight)
                .position(x: pipe.x, y: topHeight / 2)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.65, blue: 0.25))
                        .frame(width: pipeWidth + 8, height: 20)
                        .position(x: pipe.x, y: topHeight - 10)
                )
            Rectangle()
                .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.75, blue: 0.3),
                                              Color(red: 0.15, green: 0.55, blue: 0.2)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: pipeWidth, height: bottomHeight)
                .position(x: pipe.x, y: bottomY + bottomHeight / 2)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.65, blue: 0.25))
                        .frame(width: pipeWidth + 8, height: 20)
                        .position(x: pipe.x, y: bottomY + 10)
                )
        }
    }

    var startOverlay: some View {
        VStack(spacing: 10) {
            Text("First App HayrX")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
            Text("Тапни, чтобы птица взлетела")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            Text("Собирай монетки! 🪙")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
            Text("👆")
                .font(.system(size: 50))
                .padding(.top, 4)
        }
    }

    var gameOverOverlay: some View {
        VStack(spacing: 12) {
            Text("Игра окончена")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("Счёт: \(score)").font(.title2).foregroundColor(.white)
            Text("Рекорд: \(bestScore)").font(.title3).foregroundColor(.white.opacity(0.9))

            HStack(spacing: 6) {
                Image(systemName: "circle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                Text("+\(earnedCoins) монет")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Button { restart() } label: {
                Text("Играть снова")
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 13)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(13)
            }
            .padding(.top, 8)

            Button(action: onExitToMenu) {
                Text("В меню")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
            }
        }
        .padding(32)
        .background(Color.black.opacity(0.6))
        .cornerRadius(22)
    }

    // MARK: - Логика
    func handleTap() {
        if isGameOver { return }
        if !isStarted { isStarted = true }
        birdVelocity = -11
    }

    func updateGame(
        screenW: CGFloat, screenH: CGFloat,
        groundHeight: CGFloat, safeTop: CGFloat, safeBottom: CGFloat,
        birdSize: CGFloat, pipeWidth: CGFloat, gapHeight: CGFloat,
        pipeSpacing: CGFloat, pipeSpeed: CGFloat,
        gravity: CGFloat,
        coinSize: CGFloat, birdX: CGFloat
    ) {
        birdVelocity += gravity
        birdY += birdVelocity

        if birdY > screenH - groundHeight - safeBottom - birdSize / 2 {
            gameOver(); return
        }
        if birdY < safeTop + birdSize / 2 {
            birdY = safeTop + birdSize / 2
            birdVelocity = 0
        }

        for i in pipes.indices { pipes[i].x -= pipeSpeed }
        for i in coins.indices { coins[i].x -= pipeSpeed }

        pipes = pipes.filter { $0.x > -pipeWidth }
        coins = coins.filter { $0.x > -coinSize }

        for i in pipes.indices {
            if !pipes[i].passed && pipes[i].x + pipeWidth / 2 < birdX {
                pipes[i].passed = true
                score += 1
            }
        }

        for i in coins.indices where !coins[i].collected {
            let dx = abs(birdX - coins[i].x)
            let dy = abs(birdY - coins[i].y)
            if dx < (birdSize / 2 + coinSize / 2) && dy < (birdSize / 2 + coinSize / 2) {
                coins[i].collected = true
                earnedCoins += 1
            }
        }

        // Спавн труб — включая самую первую
        let needSpawn = pipes.isEmpty || pipes.last!.x < screenW - pipeSpacing
        if needSpawn {
            let minY = safeTop + gapHeight / 2 + 50
            let maxY = screenH - groundHeight - safeBottom - gapHeight / 2 - 50
            if minY < maxY {
                let gapY = CGFloat.random(in: minY...maxY)
                pipes.append(Pipe(x: screenW + pipeWidth, gapY: gapY, gapHeight: gapHeight))
                coins.append(Coin(x: screenW + pipeWidth, y: gapY))
            }
        }

        for pipe in pipes {
            let dx = abs(birdX - pipe.x)
            if dx < (pipeWidth / 2 + birdSize / 2 - 6) {
                let topY = pipe.gapY - gapHeight / 2
                let bottomY = pipe.gapY + gapHeight / 2
                if birdY - birdSize / 2 < topY || birdY + birdSize / 2 > bottomY {
                    gameOver(); return
                }
            }
        }
    }

    func gameOver() {
        isGameOver = true
        isStarted = false
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
        store.coins += earnedCoins
    }

    func restart() {
        score = 0
        earnedCoins = 0
        pipes = []
        coins = []
        birdVelocity = 0
        birdY = 0
        isGameOver = false
        isStarted = false
    }
}

#Preview {
    ContentView()
}
