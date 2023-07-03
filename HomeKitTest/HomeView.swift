//
//  ContentView.swift
//  HomeView
//
//  Created by Marco Carmona on 6/19/23.
//

import SwiftUI
import HomeKit

struct HomeView: View {
    @State private var path = NavigationPath()
    @ObservedObject var model: HomeStore
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section(
                    content: {
                        ForEach(model.homes, id: \.uniqueIdentifier) { home in
                            NavigationLink(
                                value: home,
                                label: {
                                    Text(home.name)
                                }
                            )
                            .navigationDestination(for: HMHome.self) {
                                AccessoriesView(
                                    model: model,
                                    homeID: $0.uniqueIdentifier
                                )
                            }
                        }
                    },
                    header: {
                        HStack {
                            Text("My Homes")
                        }
                    }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(model: .init())
    }
}
