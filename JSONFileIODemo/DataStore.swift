import Foundation

// This demonstrates persisting data in a local JSON file.
// This approach is only appropriate for relatively small amounts of data.
// For larger amounts of data, consider using Core Data, CloudKit, or Realm.
struct Artist: Codable, Identifiable {
    let name: String
    var albums: [Album]

    var id: String { name }
}

struct Album: Codable, Identifiable {
    let artistName: String
    let title: String

    var id: String { "\(artistName)-\(title)" }
}

@MainActor
class DataStore: ObservableObject {
    @Published var artists: [String: Artist] = [:]
    @Published var error: Error?

    init() {
        load()
    }

    func addAlbum(artistName: String, title: String) {
        var artist = artists[artistName]
        if artist == nil {
            artist = Artist(name: artistName, albums: [])
        }

        var album = artist!.albums.first { album in album.title == title }
        guard album == nil else {
            print("album already exists")
            return
        }

        album = Album(artistName: artistName, title: title)
        artist!.albums.append(album!)

        // Replace the artist in the Dictionary with a new instance
        // that is updated with the new album.
        artists[artistName] = artist

        dump()
        save()
    }

    func artistNames() -> [String] {
        Array(artists.keys).sorted()
    }

    func deleteAlbum(_ album: Album) {
        let name = album.artistName
        let artist = artists[name]
        guard var artist else { return }
        artist.albums.removeAll { $0.title == album.title }
        artists[name] = artist
        save()
    }

    func deleteArtist(_ artist: Artist) {
        artists.removeValue(forKey: artist.name)
        save()
    }

    func dump() {
        for artistName in artistNames() {
            let artist = artists[artistName]!
            print("artist: \(artist.name)")
            for album in artist.albums {
                print("  title: \(album.title)")
            }
        }
    }

    func load() {
        let url = URL.documentsDirectory.appending(path: "music.json")
        print(URL.documentsDirectory)
        guard FileManager().fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            artists = try JSONDecoder()
                .decode([String: Artist].self, from: data)
            dump()
        } catch {
            self.error = error
        }
    }

    func save() {
        do {
            let url = URL.documentsDirectory.appending(path: "music.json")
            let data = try JSONEncoder().encode(artists)
            try data.write(to: url)
        } catch {
            self.error = error
        }
    }
}
