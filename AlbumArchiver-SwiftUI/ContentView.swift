//
//  ContentView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import SwiftUI

struct ContentView: View {
    
    
    @EnvironmentObject var library: Library
    
    
    init() {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {

                LibraryMenuView(withLibrary: library)
                Button("Add Album") {
                    library.addAlbum(named: "New Album")
                }.padding()
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
