//
//  ContentView.swift
//  yliftdaily
//
//  Created by Nestor Rivera (aka dany.codes) on 6/25/24.
//

import SwiftUI
import CoreData
import SwiftUICharts
import UserNotifications


struct ActivityResponse: Codable {
    let lastActive: String
    let elapsedIdle: String
    let activeIdle: String
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case lastActive = "last_active"
        case elapsedIdle = "elapsed_idle"
        case activeIdle = "active_idle"
        case isActive = "is_active"
    }
}

struct Account: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let recentlyOrdered: Bool
}

struct ProbabilityResponse: Codable {
    let monday: DayProbability
    let tuesday: DayProbability
    let wednesday: DayProbability
    let thursday: DayProbability
    let friday: DayProbability
    let saturday: DayProbability
    let sunday: DayProbability
    
    enum CodingKeys: String, CodingKey {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
}

struct DayProbability: Codable {
    let probability: Double
    let busyHours: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case probability
        case busyHours = "busy_hours"
    }
}

struct BusyTimesChartView: View {
    let busyTimesResponse: ProbabilityResponse
    let hourLabels = [ "1 am", "2 am", "3 am", "4 am", "5 am", "6 am", "7 am", "8 am", "9 am", "10 am", "11 am","12 pm", "1 pm", "2 pm", "3 pm", "4 pm", "5 pm", "6 pm", "7 pm", "8 pm", "9 pm", "10 pm", "11 pm"]
    
    var body: some View {
        GeometryReader { geometry in

            VStack {
           
                HStack(alignment: .top, spacing: 0) {
                    // Time scale on the left
                    VStack(alignment: .trailing, spacing: 0) {
                        
                        ForEach(hourLabels, id: \.self) { hour in
                            Text(hour)
                                .font(.caption2)
                                .frame(height: 10)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Scrollable chart
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 20) {
                            ForEach(getDayData(), id: \.day) { dayData in
                                VStack {
                                    Text(dayData.day)
                                        .font(.caption)
                                        .frame(width: 50)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(sortedHours(dayData.hours), id: \.key) { hour, value in
                                            Rectangle()
                                                .fill(Color.blue)
                                                .opacity(value)
                                                .frame(width: max(30, (geometry.size.width - 50) / 8),height: 10)
                                        }
                                    }
                                    .frame(height: 240)
                                    
                                    Text(String(format: "%.0f", (dayData.probability * 100) ) + "%")
                                        .font(.caption)
                                        .frame(width: max(30, (geometry.size.width - 50) / 8))
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                HStack {
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack {
                            Text("Legend:")
                                .padding(.top,3)
                                .font(.headline)
                            ForEach([0.0, 0.25, 0.5, 0.75, 1.0], id: \.self) { value in
                                VStack {
                                    Rectangle()
                                        .fill(Color.blue)
                                        .opacity(value)
                                        .frame(width: 15, height: 10)
                                    Text(String(format: "%.2f", value))
                                        .font(.caption)
                                }
                            }
                        }
                        Text("Color intensity represents the level of store activity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    Text("Activity via Day & Hour")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding([.trailing],5)
                        .font(.title)

                }
            }
            
        }
    }
    
    func getDayData() -> [(day: String, hours: [String: Double], probability: Double)] {
        return [
            ("Sun", busyTimesResponse.sunday.busyHours, busyTimesResponse.sunday.probability),
            ("Mon", busyTimesResponse.monday.busyHours, busyTimesResponse.monday.probability),
            ("Tue", busyTimesResponse.tuesday.busyHours, busyTimesResponse.tuesday.probability),
            ("Wed", busyTimesResponse.wednesday.busyHours, busyTimesResponse.wednesday.probability),
            ("Thu", busyTimesResponse.thursday.busyHours, busyTimesResponse.thursday.probability),
            ("Fri", busyTimesResponse.friday.busyHours, busyTimesResponse.friday.probability),
            ("Sat", busyTimesResponse.saturday.busyHours, busyTimesResponse.saturday.probability)
        ]
    }
    
    func sortedHours(_ hours: [String: Double]) -> [(key: String, value: Double)] {
        return hours.sorted { $0.key < $1.key }
    }
}

struct ContentView: View {
    @State private var activityResponse: ActivityResponse?
    @State private var probabilityResponse: ProbabilityResponse?
    @State private var accounts: [Account] = []
    @State private var accountsTimer: Timer?
    @State private var knownAccountIds: Set<Int> = []

    var body: some View {
         ScrollView {
             VStack(spacing: 20) {
                 // Activity Section
                 VStack {
                     if let activity = activityResponse {
                         HStack {
                             Spacer()
                             TimerView(lastActive: activity.lastActive, isActive: activity.isActive)
                                 .padding(5)
                         }
                     } else {
                         Text("Loading activity data...")
                     }
                 }
                 .padding(10)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)
                 
                 // Probability Chart Section
                 VStack {
                     if let probability = probabilityResponse {
                         BusyTimesChartView(busyTimesResponse: probability)
                     } else {
                         Text("Loading probability data...")
                     }
                 }
                 .padding(10)
                 .frame(minHeight: 400)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)
                 
                 // Customer Carts Section
                 VStack {
                     // Header titles
                     HStack {
                         Text("Name")
                             .fontWeight(.bold)
                             .frame(maxWidth: .infinity, alignment: .leading)
                         Text("Email")
                             .fontWeight(.bold)
                             .frame(maxWidth: .infinity, alignment: .leading)
                         Text("Status")
                             .fontWeight(.bold)
                             .frame(maxWidth: .infinity, alignment: .leading)
                     }
                     .padding(.bottom, 5)
                     
                     // Scrollable list
                     ScrollView {
                         LazyVStack(alignment: .leading, spacing: 10) {
                             ForEach(accounts) { account in
                                 HStack {
                                     Text(account.name)
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                     Text(account.email)
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                     Text(account.recentlyOrdered ? "Order is Completed" : "Building Order..")
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                 }
                             }
                         }
                     }
                     .frame(height: 200)
                     
                     Text("Live Carts")
                         .font(.title)
                         .frame(maxWidth: .infinity, alignment: .trailing)
                         .padding(.top, 10)
                 }
                 .padding(10)
                 .background(Color.gray.opacity(0.1))
                 .cornerRadius(10)
             }
             .padding(20)
             .frame(maxWidth: .infinity, alignment: .center)
         }
         .onAppear {
             fetchData()
             stopAccountsTimer()
         }
         .onDisappear {
             stopAccountsTimer()
         }
     }
    
    func fetchData() {
        fetchActivityData(retries: 3)
        fetchProbabilityData(retries: 3)
        fetchAccountsData(retries: 3)
    }
    
    func startAccountsTimer() {
          accountsTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
              fetchAccountsData(retries: 3)
          }
      }

      func stopAccountsTimer() {
          accountsTimer?.invalidate()
          accountsTimer = nil
      }
    
    func fetchActivityData(retries: Int) {
        guard let activityURL = URL(string: (Config.shared.value(forKey: "API_URL") as? String ?? "") + "activity") else { return }

        URLSession.shared.dataTask(with: activityURL) { data, response, error in
            if let error = error {
                print("Activity data fetch error: \(error.localizedDescription)")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchActivityData(retries: retries - 1)
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No data received from activity endpoint")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchActivityData(retries: retries - 1)
                    }
                }
                return
            }

        
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let lastActive = json["last_active"] as? String ?? ""
                    let elapsedIdle = json["elapsed_idle"] as? String ?? ""
                    let activeIdle = json["active_idle"] as? String ?? ""
                    let isActive = json["is_active"] as? Bool ?? false
                    
                    let activityResponse = ActivityResponse(lastActive: lastActive, elapsedIdle: elapsedIdle, activeIdle: activeIdle, isActive: isActive)
                    DispatchQueue.main.async {
                        self.activityResponse = activityResponse
                        print("Activity data loaded: \(String(describing: self.activityResponse))")
                    }
                } else {
                    print("Failed to parse JSON")
                }
            } catch {
                print("Failed to decode activity data: \(error)")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchActivityData(retries: retries - 1)
                    }
                }
            }
        }.resume()
    }

    func fetchProbabilityData(retries: Int) {

        guard let probabilityURL = URL(string: (Config.shared.value(forKey: "API_URL") as? String ?? "") + "probability") else { return }
        
        
           URLSession.shared.dataTask(with: probabilityURL) { data, response, error in
               if let error = error {
                   print("Probability data fetch error: \(error.localizedDescription)")
                   if retries > 0 {
                       DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                           self.fetchProbabilityData(retries: retries - 1)
                       }
                   }
                   return
               }
               
               guard let data = data else {
                   print("No data received from probability endpoint")
                   if retries > 0 {
                       DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                           self.fetchProbabilityData(retries: retries - 1)
                       }
                   }
                   return
               }
               
               let decoder = JSONDecoder()
               decoder.keyDecodingStrategy = .convertFromSnakeCase
               if let rawJSON = String(data: data, encoding: .utf8) {
                   print("Received Probability raw JSON: \(rawJSON)")
               }
               
               do {
                   let decoder = JSONDecoder()
                   let decodedResponse = try decoder.decode(ProbabilityResponse.self, from: data)
                   DispatchQueue.main.async {
                       self.probabilityResponse = decodedResponse
                       print("Probability data loaded:")
                       self.printDayDetails("Monday", day: decodedResponse.monday)
                       self.printDayDetails("Tuesday", day: decodedResponse.tuesday)
                       self.printDayDetails("Wednesday", day: decodedResponse.wednesday)
                       self.printDayDetails("Thursday", day: decodedResponse.thursday)
                       self.printDayDetails("Friday", day: decodedResponse.friday)
                       self.printDayDetails("Saturday", day: decodedResponse.saturday)
                       self.printDayDetails("Sunday", day: decodedResponse.sunday)
                   }
               } catch {
                   print("Failed to decode probability data: \(error)")
                   if retries > 0 {
                       DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                           self.fetchProbabilityData(retries: retries - 1)
                       }
                   }
               }
           }.resume()
       }
    
    func printDayDetails(_ dayName: String, day: DayProbability) {
        print("\(dayName) probability: \(day.probability)")
        print("\(dayName) busy hours: \(day.busyHours)")
    }

    func fetchAccountsData(retries: Int) {
        guard let accountsURL = URL(string: (Config.shared.value(forKey: "API_URL") as? String ?? "") + "accounts") else { return }

        
        
        URLSession.shared.dataTask(with: accountsURL) { data, response, error in
            if let error = error {
                print("Accounts data fetch error: \(error.localizedDescription)")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchAccountsData(retries: retries - 1)
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No data received from accounts endpoint")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchAccountsData(retries: retries - 1)
                    }
                }
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedResponse = try decoder.decode([Account].self, from: data)
                DispatchQueue.main.async {
                    self.checkForNewAccounts(decodedResponse)
                    self.accounts = decodedResponse
                }
            } catch {
                print("Failed to decode accounts data: \(error)")
                if retries > 0 {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                        self.fetchAccountsData(retries: retries - 1)
                    }
                }
            }
        }.resume()
    }

    func checkForNewAccounts(_ newAccounts: [Account]) {
        for account in newAccounts {
            if !knownAccountIds.contains(account.id) {
                sendNotification(for: account)
                knownAccountIds.insert(account.id)
            }
        }
    }

    func sendNotification(for account: Account) {
        let content = UNMutableNotificationContent()
        content.title = "New Account"
        content.body = "\(account.name) - Status: \(account.recentlyOrdered ? "Completed their Order" : "Still pending")"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
}

struct TimerView: View {
    let lastActive: String
    let isActive: Bool
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        Text(isActive ? "Store is Active for \(formatTime(elapsedTime))" : "Store is Inactive for \(formatTime(elapsedTime))")
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
    }
    
    func startTimer() {
        guard let lastActiveDate = DateFormatter.activityDateFormatter.date(from: lastActive) else { return }
        elapsedTime = -lastActiveDate.timeIntervalSinceNow
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

private extension DateFormatter {
    static let activityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
