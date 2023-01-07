//
//  ItemCollectionViewHost.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/31/22.
//

import Foundation
import SwiftUI

struct ItemCollectionViewHost : NSViewControllerRepresentable {
    
    @ObservedObject var myPage : Page
    
    init(forPage p : Page) {
        myPage = p
    }
    
    func makeNSViewController(context: Context) -> ItemCollectionViewController {
        let controller = ItemCollectionViewController(nibName: "ItemCollectionViewController", bundle: nil)
//        controller.label.stringValue = myPage.number
        controller.thisPage = myPage
        return controller
    }
    
    func updateNSViewController(_ nsViewController: ItemCollectionViewController, context: Context) {
        print("In updateNS")
    }
    
    typealias NSViewControllerType = ItemCollectionViewController
    
    
    
    
    
    
}
