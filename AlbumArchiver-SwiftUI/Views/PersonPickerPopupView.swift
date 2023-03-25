//
//  PersonPickerPopupView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 3/25/23.
//

import SwiftUI

struct PersonPickerPopupView: View {
    
    @EnvironmentObject var library : Library
    
    var thisItem : ArchivedItem
    var faceObs : FaceObservation
    
//    @State var selectedPerson: Person
    
    var body: some View {
        VStack{
            Text("Library has \(library.people.count) people").padding()
            
        }
//        VStack {
//            Picker("Choose a person:", selection: $selectedPerson) {
//                Text("No selection...")
//                ForEach(library.people, id: \.self) {
//                    Text($0.name)
//                }
//            }.pickerStyle(.menu)
//        }
    }
    
}

