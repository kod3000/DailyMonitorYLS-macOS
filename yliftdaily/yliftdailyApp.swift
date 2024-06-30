//
//  yliftdailyApp.swift
//  yliftdaily
//
//  Created by Nestor Rivera (aka dany.codes) on 6/25/24.
//

import SwiftUI
import UserNotifications
import AppKit

@main
struct yliftdailyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoading = true
     let persistenceController = PersistenceController.shared

     var body: some Scene {
         WindowGroup {
                     ZStack {
                         ContentView(isLoading: $isLoading)
                             .environment(\.managedObjectContext, persistenceController.container.viewContext)
                             .frame(minWidth: 960, minHeight: 820)
                         
                         if isLoading {
                             SplashView()
                                 .transition(.opacity)
                                 .zIndex(1)
                         }
                     }
                     .onAppear {
                         let startTime = Date()
                                  Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                                      if !self.isLoading || Date().timeIntervalSince(startTime) >= 20 {
                                          withAnimation {
                                              self.isLoading = false
                                          }
                                          timer.invalidate()
                                      }
                                  }
                     }
        }
         .windowStyle(TitleBarWindowStyle())
         .commands {
             CommandGroup(replacing: .newItem) { }
         }
     }
}


class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermissions()
        
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                window.title = "Y Lift Daily Monitor"
                window.setContentSize(NSSize(width: 960, height: 820))
                window.minSize = NSSize(width: 960, height: 820)
            }
        }
    }
    
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
}
