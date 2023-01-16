//
//  main.swift
//  AlbumIOScratchpad
//
//  Created by Steven Bedrick on 1/10/23.
//

import Foundation

let rootDirPath = "/Users/steven/Desktop/Hacking/Album Archiver Idea/Test Library"

let rootDirUrl = URL.init(fileURLWithPath: rootDirPath) as NSURL

print(rootDirUrl)
print(rootDirUrl.fileReferenceURL())


let lib = loadLibrary(atRootDir: rootDirUrl as URL)

switch lib {
case .success(let l):
    print("Loaded a library!")
    
    for a in l.albums {
        print("\t\(a.name)")
        for p in a.pages {
            print("\t\t\(p.number)")
            for i in p.items {
                if i.name == "IMG_2211.jpg" || i.name == "IMG_2211 fewer faces.jpg" {
                    //                print("\t\t\t\(i.name)")
                    if let faces = FaceDetectionManager.facesInItem(item: i) {
                        if faces.count > 0 {
                            
                            print("\t\t\t\(i.name)")
                            print(faces)
                        }
                    } else {
                        print("No faces in item \(i.name)")
                    }
                }
                    
            }
        }
    }
    
//    print(l)
case .failure(let e):
    print("Error loading library: \(e)")
}
