//
//  ContentView.swift
//  ProjectTV
//
//  Created by Ray Hunter on 21/02/2020.
//  Copyright © 2020 Rekall. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    //var model = AppEnvironment.shared
    
    var body: some View {
        TabView(selection: $selection){
            Text("First View")
                .font(.title)
                .tabItem {
                    HStack {
                        Image("first")
                        Text("First")
                    }
                }
                .tag(0)
            Text("Second View")
                .font(.title)
                .tabItem {
                    HStack {
                        Image("second")
                        Text("Second")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
