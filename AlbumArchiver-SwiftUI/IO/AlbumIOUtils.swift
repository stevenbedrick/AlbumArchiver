//
//  IOUtils.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 1/10/23.
//

import Foundation
import Cocoa

enum FileEntityTypes : String {
    case album = "Albums"
    case page = "Pages"
}

enum LibraryLoadError : Error {
    // If we try and load a directory as a Library but there's no "Albums/" subdirectory
    case topLevelAlbumsDirMissing(rootDir: URL)
    
    // If for some reason we can't enumerate the "Albums/" directory
    case topLevelAlbumsDirInvalid(rootDir: URL, underlyingError: Error?)

    case albumLoadError(albumUrl: URL, underlyingError: Error?)
}

enum AlbumLoadError : Error {
    // If an Album directory is missing the "Pages/" subdirectory
    case pagesDirMissing(albumDir: URL)
    
    // In case we can't enumerate the contents of the pages dir
    case pagesDirInvalid(albumDir: URL, underlyingError: Error?)
    
    // If we encounter an issue loading a page of this album
    case pageLoadError(pageUrl : URL, underlyingError : Error?)
}

enum PageLoadError : Error {
    // If we can't enumerate the contents of pageDir
    case pageDirInvalid(pageDir: URL, underlyingError: Error?)
    
    // If we can't load an item that we should be able to load
    case invalidImageForItem(itemUrl: URL, underlyingError: Error?)
}



func loadLibrary(atRootDir rootDirUrl: URL) -> Result<Library,LibraryLoadError> {
    let fm = FileManager.default

    // for now, the only things in this directory that we care about are the presence
    // of a top-level directory called "Albums"
    
    // try and find a child directory named "Albums"
    let albumsDir = rootDirUrl.appendingPathComponent(FileEntityTypes.album.rawValue)
    var isDir : ObjCBool = false
    if fm.fileExists(atPath: albumsDir.path, isDirectory: &isDir) {
        if !isDir.boolValue {
            return .failure(.topLevelAlbumsDirMissing(rootDir: rootDirUrl))
        }
    } else {
        return .failure(.topLevelAlbumsDirMissing(rootDir: rootDirUrl))
    }
    
    // now, get the children of our albumsDir:
    
    let possibleAlbums : [URL]
    do {
        possibleAlbums = try fm.contentsOfDirectory(at: albumsDir as URL, includingPropertiesForKeys: [.isDirectoryKey])
    } catch let e {
        return .failure(.topLevelAlbumsDirInvalid(rootDir: rootDirUrl, underlyingError: e))
    }
    
    let toRet = Library()
    
    for albumDir in possibleAlbums {
        // look at each child...
        let dirProps : URLResourceValues
        do {
            dirProps = try albumDir.resourceValues(forKeys: [.isDirectoryKey])
        } catch let e {
            return .failure(.albumLoadError(albumUrl: albumDir, underlyingError: e))
        }
        
        // if it is a directory, try loading it as an album
        if dirProps.isDirectory! {
            let thisAlbum = loadAlbumFromDir(atPath: albumDir)
            
            switch thisAlbum {
            case .success(let alb):
                toRet.addAlbum(existingAlbum: alb)
            case .failure(let err):
                return .failure(.albumLoadError(albumUrl: albumDir, underlyingError: err))
            }
        }
    }
    
    return .success(toRet)

}


func loadAlbumFromDir(atPath albumDir: URL) -> Result<Album,AlbumLoadError> {
    
//    print("About to try loading \(albumDir.lastPathComponent)")
    
    let pagesDir = albumDir.appendingPathComponent(FileEntityTypes.page.rawValue)
    // does the "Pages" directory actually exist?
    var isDir : ObjCBool = false
    if FileManager.default.fileExists(atPath: pagesDir.path, isDirectory: &isDir) {
        if !isDir.boolValue {
            return .failure(.pagesDirMissing(albumDir: albumDir))
        }
    } else {
        return .failure(.pagesDirMissing(albumDir: albumDir))
    }
    
    // find each child directory of pagesDir, process:
    let pageDirs : [URL]
    do {
        pageDirs = try FileManager.default.contentsOfDirectory(at: pagesDir as URL, includingPropertiesForKeys: [.isDirectoryKey])
    } catch let e {
        return .failure(.pagesDirInvalid(albumDir: albumDir, underlyingError: e))
    }
    
    var pagesForThisAlbum : [Page] = []
    
    for possiblePage in pageDirs {
        // look at each child...
        let dirProps : URLResourceValues
        do {
            dirProps = try possiblePage.resourceValues(forKeys: [.isDirectoryKey])
        } catch let e {
            return .failure(.pageLoadError(pageUrl: possiblePage, underlyingError: e))
        }
        
        // if it is a directory, try loading it as an album
        if dirProps.isDirectory! {
            let thisPage = loadPageFromDir(atPath: possiblePage)
            switch thisPage {
            case .success(let p):
                pagesForThisAlbum.append(p)
            case .failure(let e):
                return .failure(.pageLoadError(pageUrl: possiblePage, underlyingError: e))
            }
        }
    }
    
    return .success(Album(withName: albumDir.lastPathComponent, pages: pagesForThisAlbum))
    
}


func loadPageFromDir(atPath pageDir: URL) -> Result<Page,PageLoadError> {
    
//    print("Loading page \(pageDir.lastPathComponent)")
    
    let possibleItems : [URL]
    do {
        possibleItems = try FileManager.default.contentsOfDirectory(at: pageDir as URL, includingPropertiesForKeys: [.contentTypeKey])
    } catch let err {
        return .failure(.pageDirInvalid(pageDir: pageDir, underlyingError: err))
    }
    
    var itemsForThisPage : [ArchivedItem] = []
    
    for item in possibleItems {
//        print("possible item found: \(item.lastPathComponent)")
        
        let itemProps : URLResourceValues
        
        do {
            itemProps = try item.resourceValues(forKeys: [.contentTypeKey])
        } catch let err {
            return .failure(.invalidImageForItem(itemUrl: item, underlyingError: err))
        }
        
//        print("\t\(itemProps.contentType)")
        let isImage = itemProps.contentType!.conforms(to: .image)
//        print("isImage: \(isImage)")
        if !isImage {
            // skip this file
            continue
        }
        
        let thisItem = ArchivedItem(withName: item.lastPathComponent)
        thisItem.imageFileURL = item
        
        let rawIm = NSImage(byReferencing: item)
        if rawIm.isValid {
            thisItem.image = rawIm
        } else {
            return .failure(.invalidImageForItem(itemUrl: item, underlyingError: nil))
        }
        
        itemsForThisPage.append(thisItem)
        
    }
    
    return .success(Page(number: pageDir.lastPathComponent, withItems: itemsForThisPage))
    
}
