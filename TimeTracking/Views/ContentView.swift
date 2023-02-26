//
//  ContentView.swift
//  TimeTracking
//
//  Created by Mijo Gracanin on 21.02.2023..
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView {
            VStack {
                ActivityList()
                Spacer()
                ActivityCreator()
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
