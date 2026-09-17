import SwiftUI

struct Pipe: Identifiable {
    let id = UUID()
    var x: CGFloat
    let gapY: CGFloat
    let gapHeight: CGFloat
    var passed: Bool = false
}

enum AppScreen {
    case menu
    case game
}

struct ContentView: View {
    @State private var screen: AppScreen = .menu

    var body: some View {
        ZStack {
            if screen == .menu {
                MainMenuView(onStart: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        screen = .game
                    }
                })
                .transition(.opacity)
            } else {
                GameView(onExitToMenu: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        screen = .menu
                    }
                })
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Главное меню
struct MainMenuView: View {
    let onStart: () -> Void

    @State private var rotation: Double = -8
    @State private var bobOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom

            ZStack {
                // Фон
                LinearGradient(
                    colors: [Color(red: 0.45, green: 0.78, blue: 0.98),
                             Color(red: 0.75, green: 0.92, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Земля (учитываем нижний индикатор)
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color(red: 0.55, green: 0.85, blue: 0.35))
                        .frame(height: 90 + safeBottom)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.45, green: 0.75, blue: 0.25))
                                .frame(height: 14),
                            alignment: .top
                        )
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: safeTop + 20)

                    // Название
                    VStack(spacing: 4) {
                        Text("Sungarov")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                        Text("Energiya")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.2))
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                        Text("Flappy")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 3)
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Персонаж
                    Image("bird")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(rotation))
                        .offset(y: bobOffset)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 6)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                                rotation = 8
                            }
                            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                                bobOffset = -12
                            }
                        }

                    Spacer()

                    // Кнопка
                    Button(action: onStart) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 22, weight: .bold))
                            Text("Играть")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 260)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.55, blue: 0.15),
                                         Color(red: 0.92, green: 0.35, blue: 0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    // Рекорд
                    Text("Рекорд: \(UserDefaults.standard.integer(forKey: "bestScore"))")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .padding(.top, 20)

                    Spacer().frame(height: safeBottom + 40)
                }
            }
        }
        .statusBarHidden(true)
    }
}

// MARK: - Игра
struct GameView: View {
    let onExitToMenu: () -> Void

    @State private var birdY: CGFloat = 0
    @State private var birdVelocity: CGFloat = 0
    @State private var pipes: [Pipe] = []
    @State private var score: Int = 0
    @State private var bestScore: Int = UserDefaults.standard.integer(forKey: "bestScore")
    @State private var isGameOver: Bool = false
    @State private var isStarted: Bool = false
    @State private var screenWidth: CGFloat = 375
    @State private var screenHeight: CGFloat = 812
    @State private var safeTop: CGFloat = 44
    @State private var safeBottom: CGFloat = 34

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    let gravity: CGFloat = 0.55
    let jumpForce: CGFloat = -10.5
    let pipeSpeed: CGFloat = 2.4
    let birdSize: CGFloat = 38
    let pipeWidth: CGFloat = 68
    let gapHeight: CGFloat = 190
    let pipeSpacing: CGFloat = 210
    let groundHeight: CGFloat = 80

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Фон
                LinearGradient(
                    colors: [Color(red: 0.45, green: 0.78, blue: 0.98),
                             Color(red: 0.75, green: 0.92, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Земля
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
                }
                .ignoresSafeArea()

                // Трубы
                ForEach(pipes) { pipe in
                    pipeView(pipe: pipe, screenHeight: h)
                }

                // Птица
                Image("bird")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: birdSize, height: birdSize)
                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                    .rotationEffect(.degrees(Double(birdVelocity) * 2))
                    .position(x: w * 0.28, y: birdY)

                // Счёт вверху (под чёлкой)
                VStack {
                    Text("\(score)")
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 2)
                        .padding(.top, safeTop + 8)
                    Text("Рекорд: \(bestScore)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    Spacer()
                }

                // Кнопка назад (только до старта)
                if !isStarted && !isGameOver {
                    VStack {
                        HStack {
                            Button(action: onExitToMenu) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(12)
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

                if !isStarted && !isGameOver {
                    startOverlay(safeTop: safeTop, safeBottom: safeBottom)
                }

                if isGameOver {
                    gameOverOverlay
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handleTap()
            }
            .onAppear {
                screenWidth = w
                screenHeight = h
                safeTop = geo.safeAreaInsets.top
                safeBottom = geo.safeAreaInsets.bottom
                birdY = (h - groundHeight) * 0.5
            }
            .onReceive(timer) { _ in
                if isStarted && !isGameOver {
                    updateGame()
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    // MARK: - Труба
    func pipeView(pipe: Pipe, screenHeight: CGFloat) -> some View {
        let topHeight = max(0, pipe.gapY - gapHeight / 2)
        let bottomY = pipe.gapY + gapHeight / 2
        let bottomHeight = max(0, screenHeight - bottomY - groundHeight - safeBottom)

        return ZStack {
            // Верхняя
            Rectangle()
                .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.75, blue: 0.3),
                                              Color(red: 0.15, green: 0.55, blue: 0.2)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: pipeWidth, height: topHeight)
                .position(x: pipe.x, y: topHeight / 2)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.65, blue: 0.25))
                        .frame(width: pipeWidth + 8, height: 22)
                        .position(x: pipe.x, y: topHeight - 11)
                )

            // Нижняя
            Rectangle()
                .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.75, blue: 0.3),
                                              Color(red: 0.15, green: 0.55, blue: 0.2)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: pipeWidth, height: bottomHeight)
                .position(x: pipe.x, y: bottomY + bottomHeight / 2)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.65, blue: 0.25))
                        .frame(width: pipeWidth + 8, height: 22)
                        .position(x: pipe.x, y: bottomY + 11)
                )
        }
    }

    // MARK: - Оверлеи
    func startOverlay(safeTop: CGFloat, safeBottom: CGFloat) -> some View {
        VStack(spacing: 12) {
            Text("First App HayrX")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 3)
            Text("Тапни, чтобы птица взлетела")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            Text("👆")
                .font(.system(size: 54))
                .padding(.top, 10)
        }
    }

    var gameOverOverlay: some View {
        VStack(spacing: 14) {
            Text("Игра окончена")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
            Text("Счёт: \(score)")
                .font(.title)
                .foregroundColor(.white)
            Text("Рекорд: \(bestScore)")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))

            Button {
                restart()
            } label: {
                Text("Играть снова")
                    .font(.headline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
            .padding(.top, 10)

            Button(action: onExitToMenu) {
                Text("В меню")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .underline()
            }
        }
        .padding(36)
        .background(Color.black.opacity(0.6))
        .cornerRadius(24)
    }

    // MARK: - Логика
    func handleTap() {
        if isGameOver { return }
        if !isStarted {
            isStarted = true
            spawnPipe()
        }
        birdVelocity = jumpForce
    }

    func updateGame() {
        birdVelocity += gravity
        birdY += birdVelocity

        // Столкновение с землёй
        if birdY > screenHeight - groundHeight - safeBottom - birdSize / 2 {
            gameOver()
            return
        }
        // Потолок
        if birdY < safeTop + birdSize / 2 {
            birdY = safeTop + birdSize / 2
            birdVelocity = 0
        }

        for i in pipes.indices {
            pipes[i].x -= pipeSpeed
        }

        pipes = pipes.filter { $0.x > -pipeWidth }

        for i in pipes.indices {
            if !pipes[i].passed && pipes[i].x + pipeWidth / 2 < screenWidth * 0.28 {
                pipes[i].passed = true
                score += 1
            }
        }

        if let last = pipes.last {
            if last.x < screenWidth - pipeSpacing {
                spawnPipe()
            }
        }

        // Столкновение с трубами
        let birdX = screenWidth * 0.28
        for pipe in pipes {
            let dx = abs(birdX - pipe.x)
            if dx < (pipeWidth / 2 + birdSize / 2 - 6) {
                let topY = pipe.gapY - gapHeight / 2
                let bottomY = pipe.gapY + gapHeight / 2
                if birdY - birdSize / 2 < topY || birdY + birdSize / 2 > bottomY {
                    gameOver()
                    return
                }
            }
        }
    }

    func spawnPipe() {
        let minY = safeTop + gapHeight / 2 + 60
        let maxY = screenHeight - groundHeight - safeBottom - gapHeight / 2 - 60
        let gapY = CGFloat.random(in: minY...maxY)
        pipes.append(Pipe(x: screenWidth + pipeWidth, gapY: gapY, gapHeight: gapHeight))
    }

    func gameOver() {
        isGameOver = true
        isStarted = false
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
    }

    func restart() {
        score = 0
        pipes = []
        birdVelocity = 0
        birdY = (screenHeight - groundHeight - safeBottom) * 0.5
        isGameOver = false
        isStarted = false
    }
}

#Preview {
    ContentView()
}
