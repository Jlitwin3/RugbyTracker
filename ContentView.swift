//
//  ContentView.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to the Rugby Tracker")
                .bold().font(.title)
            SearchView()
            //LoginView()
        }
        .background(Color(.blue))
    
    }
}

@main
struct RugbyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#Preview{
    ContentView()
    //SearchView()
}


