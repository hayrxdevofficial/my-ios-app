import SwiftUI

struct ContentView: View {
    // Переменная, которая считает нажатия на кнопку
    @State private var clicks = 0
    
    var body: some View {
        ZStack {
            // Красивый градиент на весь экран
            LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Привет, мир!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Это мое первое iOS приложение, собранное на GitHub!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Кнопка-счетчик
                Button(action: {
                    clicks += 1
                }) {
                    Text("Нажми меня! (Нажато: \(clicks))")
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.purple)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        }
    }
}
