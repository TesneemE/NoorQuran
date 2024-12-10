//
//  AppLoadingView.swift
//  NoorQuran
//
//  Created by Tes Essa 
//

import SwiftUI



struct AppLoadingView: View {
    @EnvironmentObject var bookmarkHadithStore: BookmarkHadithStore
    @EnvironmentObject var bookmarkAyahStore: BookmarkAyahStore
    @EnvironmentObject var memorizationStore: MemorizationStore
    @EnvironmentObject var audioManager: AudioManager

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .transition(.opacity)
                    .environmentObject(bookmarkAyahStore)
                    .environmentObject(memorizationStore)
                    .environmentObject(bookmarkHadithStore)
                    .environmentObject(audioManager)
            }
        }
    }
}

struct SplashScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("Green"), Color("AccentGreen")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            card(letter: "Quran", color: "Pink")
                .splashAnimation(finalYposition: 240, delay: 0)
            card(letter: "R", color: "Pink")
                .splashAnimation(finalYposition: 120, delay: 0.2)
            card(letter: "O", color: "Pink")
                .splashAnimation(finalYposition: 0, delay: 0.4)
            card(letter: "O", color: "Pink")
                .splashAnimation(finalYposition: -120, delay: 0.6)
            card(letter: "N", color: "Pink")
                .splashAnimation(finalYposition: -240, delay: 0.8)
        }
    }

    func card(letter: String, color: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .shadow(radius: 3)
                .frame(width: 120, height: 160)
                .foregroundColor(Color("AccentPink").opacity(0.9))
            
            Text(letter)
                .fontWeight(.bold)
                .foregroundColor(Color(color).opacity(0.9))
                .frame(width: 80)
        }
    }
}

private struct SplashAnimation: ViewModifier {
    @State private var animating = true
    let finalYPosition: CGFloat
    let delay: Double
    let animation = Animation.interpolatingSpring(
        mass: 0.2,
        stiffness: 80,
        damping: 5,
        initialVelocity: 0.0)

    func body(content: Content) -> some View {
        content
            .offset(y: animating ? -700 : finalYPosition)
            .rotationEffect(animating ? .zero : Angle(degrees: Double.random(in: -10...10))) // Random rotation
            .animation(animation.delay(delay), value: animating)
            .onAppear {
                animating = false
            }
    }
}

private extension View {
    func splashAnimation(finalYposition: CGFloat, delay: Double) -> some View {
        modifier(SplashAnimation(finalYPosition: finalYposition, delay: delay))
    }
}

struct AppLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        AppLoadingView()
            .environmentObject(BookmarkAyahStore())
            .environmentObject(MemorizationStore())
            .environmentObject(BookmarkHadithStore())
            .environmentObject(AudioManager())
    }
}
