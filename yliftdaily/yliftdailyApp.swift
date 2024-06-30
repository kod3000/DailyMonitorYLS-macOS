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
     let persistenceController = PersistenceController.shared

     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environment(\.managedObjectContext, persistenceController.container.viewContext)
                 .frame(minWidth: 960, minHeight: 820)
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
