//
//  AlbumArchiver_SwiftUIApp.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import SwiftUI

@main
struct AlbumArchiver_SwiftUIApp: App {
    
    @StateObject var library = Library.initAtTestDirLocation()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(library)
        }
    }
}
