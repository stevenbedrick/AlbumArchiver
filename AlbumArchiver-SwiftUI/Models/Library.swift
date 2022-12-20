//
//  Library.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import Foundation
import Cocoa
import SwiftUI
import Combine

class Library : Identifiable, ObservableObject {
    
    let id = UUID()
    
    @Published var albums: [Album]
    
    var albumWatchers : [Cancellable] = []
    
    init() {
        albums = [] // dummy initialization
        albums = [Album(inLibrary: self,
            name: "First",
pages: [Page(number: "1"), Page(number: "2")]
),
                  Album(inLibrary: self,
name: "Second",
pages: [Page(number: "I"), Page(number: "II"), Page(number: "III")]
),
                  Album(inLibrary: self, name: "Third", pages: [])
]
        for a in albums {
            wireObserver(forAlbum: a)
            
        }

    }
    
    func addAlbum(named: String) {
        let newAlbum = Album(inLibrary: self, name: named, pages: [])
        self.albums.append(newAlbum)
        wireObserver(forAlbum: newAlbum)
    }
    
    
    // If we don't do this, changes to an album in self.albums will not necessarily
    // cause the Library (or things watching ths library) to know there's been
    //  a change. This is specifically important in the case of a new Page being added
    // to an Album.
    //
    func wireObserver(forAlbum: Album) {
        albumWatchers.append(forAlbum.objectWillChange.sink(receiveValue: { a in
            self.objectWillChange.send()
        }))

    }
    

    
    

}


