import Foundation

/// A few of the real backgrounds from canopy-events' config/backgrounds.json
/// (TMDB backdrops), with ids made the server's way (the file path,
/// base64url) and a plausible matching hue each.
enum MockBackgrounds {
    static let all: [Background] = [
        ("/cgFV761wxNtPxfVsEVSAM5xEkcG.jpg", "Mean Girls", 340), ("/lbrYNqF6Al3Q7kEtvtc1mn9Vjke.jpg", "Mean Girls", 340),
        ("/zuv21AZA7z7XidnCYAOxc6rNQwX.jpg", "Mean Girls", 340),
        ("/9b4IBCeXkbTd1NVOreDSlXyEJJn.jpg", "The Devil Wears Prada", nil),
        ("/eqavvi8efPkBSebLnqVWWOaKUQU.jpg", "The Devil Wears Prada", nil),
        ("/1J9pj4uMCcd2SoBJqhHYn8ESc68.jpg", "The Devil Wears Prada", nil),
        ("/qCU097AXMPAsmpVK4j9kzMTxt2d.jpg", "The Wizard of Oz", 130),
        ("/bbNUSVOqgbJ2U5OtEeMC76qlqxH.jpg", "Wicked", 145), ("/5Hfj2azCDoX5qi6XH17BjrZDX9o.jpg", "Wicked", 145),
        ("/qKLfjHmyiPXjYY2TN6Hqn1NJA2f.jpg", "Wicked", 145),
        ("/1wFyBfKo6LpYppY9UABYkbv320s.jpg", "Schitt's Creek", 30),
    ].map { path, title, hue in
        Background(
            id: Data(path.utf8).base64EncodedString()
                .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: ""),
            title: title, year: nil,
            thumbUrl: URL(string: "https://image.tmdb.org/t/p/w300" + path)!,
            previewUrl: URL(string: "https://image.tmdb.org/t/p/w780" + path)!,
            width: 300, height: 169, hue: hue, grayscale: hue == nil
        )
    }
}
