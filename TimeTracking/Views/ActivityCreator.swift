//
//  ActivityCreator.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 24.02.2023..
//

import SwiftUI
import CoreData

struct ActivityCreator: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        HStack {
            VStack {
                TextField("I'm working on...", text: $viewModel.title)
                Text("\(viewModel.timePassed)")
                    .frame(height: 21)
            }
            Button {
                viewModel.toggleTimer()
            } label: {
                Image(systemName: viewModel.buttonImageName)
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundColor(viewModel.buttonImageColor)
            }
        }
        .onAppear {
            viewModel.viewContext = viewContext
        }
    }
}

extension ActivityCreator {
    class ViewModel: ObservableObject {
        @Published private(set) var timePassed: String = ""
        @Published var title = ""
        @Published private(set) var buttonImageName = "play.circle"
        @Published var buttonImageColor = Color.purple
        private var timer: Timer?
        private var start: Date?
        var viewContext: NSManagedObjectContext?
        
        func toggleTimer() {
            if timer == nil {
                startActivity()
            } else {
                stopActivity()
            }
        }
        
        private func startActivity() {
            start = Date()
            buttonImageName = "stop.circle"
            buttonImageColor = Color.orange
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] timer in
                guard let start = self?.start else { return }
                self?.timePassed = Date().timeIntervalSince(start).toTimerString()
            })
        }
        
        private func stopActivity() {
            timer?.invalidate()
            self.timer = nil
            self.timePassed = ""
            buttonImageName = "play.circle"
            buttonImageColor = Color.purple
            addActivity()
        }
        
        private func addActivity() {
            guard let viewContext else { return }
            withAnimation {
                let activity = Activity(context: viewContext)
                activity.start = start!
                activity.end = Date()
                activity.title = title

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

struct ActivityCreator_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCreator()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.fixed(width: 300, height: 80))
    }
}
