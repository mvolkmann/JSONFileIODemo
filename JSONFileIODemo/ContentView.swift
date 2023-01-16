import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore()

    @State private var addingAlbum = false
    @State private var addingArtist = false
    @State private var albumTitle = ""
    @State private var artistName = ""

    var body: some View {
        NavigationView {
            VStack {
                if let error = store.error {
                    Text(error.localizedDescription)
                        .bold()
                        .foregroundColor(.red)
                }
                albumList
            }
            .navigationTitle("Music")
            .padding()
            .sheet(isPresented: $addingAlbum) {
                form
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(
                        action: { addingAlbum = true },
                        label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    )
                }
            }
        }
        .onAppear {
            artistName = store.artistNames().first ?? ""
            addingArtist = artistName == ""
        }
    }

    private var albumList: some View {
        // TODO: Add support for updating and deleting artists.
        List(store.artistNames(), id: \.self) { artistName in
            let artist = store.artists[artistName]!
            Text(artist.name)
                .swipeActions {
                    Button(role: .destructive) {
                        store.deleteArtist(artist)
                    } label: {
                        Image(systemName: "trash").foregroundColor(.red)
                    }
                }

            ForEach(artist.albums) { album in
                Text("\t\(album.title)")
                    .swipeActions {
                        Button(role: .destructive) {
                            store.deleteAlbum(album)
                        } label: {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    private var form: some View {
        Form {
            if addingArtist {
                TextField("Artist", text: $artistName)
            } else {
                Group {
                    Picker("Artist", selection: $artistName) {
                        ForEach(store.artistNames(), id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    Button(
                        action: {
                            artistName = ""
                            addingArtist = true
                        },
                        label: { Text("New Artist") }
                    )
                }
            }
            TextField("Album", text: $albumTitle)
            Button("Add Album") {
                store.addAlbum(
                    artistName: artistName,
                    title: albumTitle
                )
                addingArtist = false
                addingAlbum = false
                albumTitle = ""
            }
            .disabled(artistName.isEmpty || albumTitle.isEmpty)
        }
        // .presentationDetents([.medium])
        .presentationDetents([.height(200)])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
