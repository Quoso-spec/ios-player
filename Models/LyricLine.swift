import Foundation

struct LyricLine: Identifiable, Hashable {
    let id: String
    var time: TimeInterval
    var text: String
    var endTime: TimeInterval?

    init(id: String = UUID().uuidString, time: TimeInterval, text: String, endTime: TimeInterval? = nil) {
        self.id = id
        self.time = time
        self.text = text
        self.endTime = endTime
    }

    var formattedTime: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let centiseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "[%02d:%02d.%02d]", minutes, seconds, centiseconds)
    }
}

struct Lyrics: Identifiable {
    let id: String
    var title: String
    var artist: String
    var album: String
    var lines: [LyricLine]
    var hasTranslation: Bool
    var hasRomanization: Bool

    init(
        id: String = UUID().uuidString,
        title: String = "",
        artist: String = "",
        album: String = "",
        lines: [LyricLine] = [],
        hasTranslation: Bool = false,
        hasRomanization: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.lines = lines.sorted { $0.time < $1.time }
        self.hasTranslation = hasTranslation
        self.hasRomanization = hasRomanization
    }

    func lineIndex(at time: TimeInterval) -> Int? {
        for i in stride(from: lines.count - 1, through: 0, by: -1) {
            if lines[i].time <= time {
                return i
            }
        }
        return nil
    }

    func currentLine(at time: TimeInterval) -> LyricLine? {
        guard let index = lineIndex(at: time) else { return nil }
        return lines[index]
    }

    var isEmpty: Bool {
        lines.isEmpty
    }

    var hasContent: Bool {
        !lines.isEmpty && lines.contains { !$0.text.isEmpty }
    }

    static func empty() -> Lyrics {
        Lyrics()
    }
}
