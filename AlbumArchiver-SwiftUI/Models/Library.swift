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
    
    @Published var albums: [Album] = []
    
    var albumWatchers : [Cancellable] = []
    
    init() {

    }
    
//    init() {
//        albums = [] // dummy initialization
//        albums = [Album(inLibrary: self,
//            name: "First",
//            pages: [
//                Page(number: "1", withItems: [
////                    ArchivedItem(withName: "foo.jpeg"),
////                    ArchivedItem(withName: "bar.png"),
////                    ArchivedItem(withName: "baz.tiff")
//                ]),
//                Page(number: "2")
//            ]),
//                  Album(inLibrary: self,
//name: "Second",
//pages: [Page(number: "I"), Page(number: "II"), Page(number: "III")]
//),
//                  Album(inLibrary: self, name: "Third", pages: [])
//]
//        for a in albums {
//            wireObserver(forAlbum: a)
//            
//        }
//
//    }
    
    static func initWithDummyValues() -> Library {
        
        let toRet = Library()
        
        let dummyAlbumA = Album(
                               withName: "First",
                               pages: [
                                   Page(number: "1", withItems: [
                                   ]),
                                   Page(number: "2")
                               ])
        toRet.addAlbum(existingAlbum: dummyAlbumA)
        
        let dummyAlbumB = Album(
                                withName: "Second",
                                pages: [Page(number: "I"), Page(number: "II"), Page(number: "III")]
                                )
        toRet.addAlbum(existingAlbum: dummyAlbumB)
        
        let dummyAlbumC = Album(withName: "Third", pages: [])
        
        toRet.addAlbum(existingAlbum: dummyAlbumC)
        
        return toRet
        
    }
    
    static func initAtTestDirLocation() -> Library {
        let rootDirPath = "/Users/steven/Desktop/Hacking/Album Archiver Idea/Test Library"

        let rootDirUrl = URL.init(fileURLWithPath: rootDirPath) as NSURL
        
        let lib = loadLibrary(atRootDir: rootDirUrl as URL)
        
        switch lib {
        case .success(let l):
            return l
        case .failure(let e):
            print("Error loading test library: \(e)")
            return initWithDummyValues()
        }
    }
    
    func addAlbum(named: String) {
        let newAlbum = Album(inLibrary: self, name: named, pages: [])
        self.albums.append(newAlbum)
        wireObserver(forAlbum: newAlbum)
    }
    
    func addAlbum(existingAlbum anAlbum : Album) {
        anAlbum.memberOf = self
        self.albums.append(anAlbum)
        wireObserver(forAlbum: anAlbum)
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


