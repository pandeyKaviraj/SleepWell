//
//  ContentView.swift
//  SleepWell
//
//  Created by Kaviraj Pandey on 21/05/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Picker(selection: $coffeeAmount, label: EmptyView()) {
                        ForEach(1..<21) {
                            Text("\($0 == 1 ? "1 cup" : "\($0) cups") ")
                        }
                    }
                }
                Section(header: Text("Recommended bedtime")) {
                    Text("\(calculateBedTime())")
                        .font(.largeTitle)
                }
            }
            .navigationTitle("SleepWell")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    // We can refresh our data
                    wakeUp = ContentView.defaultWakeTime
                    sleepAmount = 8.0
                    coffeeAmount = 1
                }
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    
    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let bedtime = sleepTime.formatted(date: .omitted, time: .shortened)
            return bedtime
            
            
        }
        catch {
            alertTitle = "Error"
            alertMessage = "Ther is a technical probleam..."
            showingAlert = true
            
        }
        return ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
