//
//  ImageView.swift
//  eintodo
//
//  Created by anh :) on 31.01.22.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageView: View{
    @Binding var images: [NSImage]
    var body: some View{
        ZStack{
            VStack{
                LeftText(text: "Bilder", font: .headline)
                HStack{
                    Button(action: selectImage){
                        ZStack{
                            Rectangle()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Colors.primaryColor)
                                .cornerRadius(10)
                                .opacity(0.1)
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(Colors.primaryColor)
                        }
                    }.buttonStyle(.plain)
                    //ImageArea
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(images.indices, id: \.self){ index in
                                ImageButton(selectedIndexOfURL: index, images: $images, image: images[index])
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    private func selectImage(){
        let panel = NSOpenPanel() //Panel to select Image in Finder
        panel.prompt = "Bild auswählen"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType("public.image")!]
        if panel.runModal() == NSApplication.ModalResponse.OK {
            let results = panel.urls
            for result in results{
                images.append(load(URL: result.absoluteURL)!)
            }
        }
    }
    private func load(URL: URL) -> NSImage?{
        do {
            let imageData = try Data(contentsOf: URL)
            return NSImage(data: imageData)
        } catch {print("Error loading image in EditView: \(error)")}
        return nil
    }
}
//ImageEditView - Show the image in a fuller size
struct ImageEditView: View{
    @Binding var images: [NSImage]
    @Binding var isPresented: Bool
    @Binding var selectedIndexOfURL: Int
    let image: NSImage
    var body: some View{
        VStack{
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
            Spacer()
            HStack{
                Button(action: {
                    isPresented.toggle()
                    images.remove(at: selectedIndexOfURL)
                }, label: {
                    Text("Entfernen")
                        .foregroundColor(.red)
                        .font(.body)
                }).buttonStyle(.plain)
                Spacer()
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("Schließen")
                        .foregroundColor(Colors.primaryColor)
                        .font(.body.bold())
                }).buttonStyle(.plain)
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.bottom, 15)
            .padding(.top, 7.5)
        }
        .frame(height: 500)
    }
}
//ImageButton - For Each Image to open the ImageEditView
struct ImageButton: View{
    @State var isPresented: Bool = false
    @State var selectedIndexOfURL: Int
    @Binding var images: [NSImage]
    let image: NSImage
    var body: some View{
        Button(action: {
            isPresented.toggle()
        },
        label: {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .cornerRadius(10)

        }).sheet(isPresented: $isPresented){
            ImageEditView(images: $images, isPresented: $isPresented, selectedIndexOfURL: $selectedIndexOfURL, image: image)
        }.buttonStyle(.plain)
    }
}
