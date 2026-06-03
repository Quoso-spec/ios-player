import Foundation

final class LrcParser {
    static let shared = LrcParser()

    private init() {}

    func parse(from url: URL) async -> Lyrics {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return parse(content: content)
        } catch {
            do {
                let content = try String(contentsOf: url, encoding: .isoLatin1)
                return parse(content: content)
            } catch {
                print("Failed to read LRC file: \(error)")
                return Lyrics.empty()
            }
        }
    }

    func parse(content: String) -> Lyrics {
        var lines: [LyricLine] = []
        var title = ""
        var artist = ""
        var album = ""
        var hasTranslation = false
        var hasRomanization = false

        let rawLines = content.components(separatedBy: .newlines)

        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if let metadata = parseMetadata(trimmed) {
                switch metadata.key.lowercased() {
                case "ti": title = metadata.value
                case "ar": artist = metadata.value
                case "al": album = metadata.value
                case "by": break
                case "offset": break
                case "length": break
                default:
                    break
                }
                continue
            }

            if parseTranslation(trimmed) {
                hasTranslation = true
            }

            if parseRomanization(trimmed) {
                hasRomanization = true
            }

            if let line = parseLine(trimmed) {
                lines.append(line)
            }
        }

        return Lyrics(
            title: title,
            artist: artist,
            album: album,
            lines: lines.sorted { $0.time < $1.time },
            hasTranslation: hasTranslation,
            hasRomanization: hasRomanization
        )
    }

    private func parseMetadata(_ line: String) -> (key: String, value: String)? {
        let pattern = #"^\[([a-zA-Z]+):(.+)\]$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        guard let keyRange = Range(match.range(at: 1), in: line),
              let valueRange = Range(match.range(at: 2), in: line) else {
            return nil
        }

        return (String(line[keyRange]), String(line[valueRange]).trimmingCharacters(in: .whitespaces))
    }

    private func parseLine(_ line: String) -> LyricLine? {
        let pattern = #"\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\](.*)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }

        guard let minutesRange = Range(match.range(at: 1), in: line),
              let secondsRange = Range(match.range(at: 2), in: line),
              let textRange = Range(match.range(at: 4), in: line) else {
            return nil
        }

        let minutes = Double(line[minutesRange]) ?? 0
        let seconds = Double(line[secondsRange]) ?? 0

        var centiseconds = 0.0
        if let csRange = Range(match.range(at: 3), in: line) {
            let csString = String(line[csRange])
            if csString.count == 2 {
                centiseconds = (Double(csString) ?? 0) / 100.0
            } else if csString.count == 3 {
                centiseconds = (Double(csString) ?? 0) / 1000.0
            }
        }

        let time = minutes * 60 + seconds + centiseconds
        let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)

        guard !text.isEmpty else { return nil }

        return LyricLine(time: time, text: text)
    }

    private func parseTranslation(_ line: String) -> Bool {
        let pattern = #"\[ti:.*\]|\[ar:.*\]|\[al:.*\]|\[by:.*\]|\[offset:.*\]|\[re:.*\]|\[ve:.*\]"#
        return line.range(of: pattern, options: .regularExpression) == nil && line.contains("[")
    }

    private func parseRomanization(_ line: String) -> Bool {
        return false
    }

    func findLrcFile(for song: Song) async -> URL? {
        let baseURL = song.fileURL.deletingPathExtension()
        let possibleExtensions = ["lrc", "txt"]
        let searchDirs = [baseURL.deletingLastPathComponent()]

        for dir in searchDirs {
            for ext in possibleExtensions {
                let lrcURL = dir.appendingPathComponent("\(baseURL.lastPathComponent).\(ext)")
                if FileManager.default.fileExists(atPath: lrcURL.path) {
                    return lrcURL
                }
            }

            let looseLrcURL = dir.appendingPathComponent("\(song.title).lrc")
            if FileManager.default.fileExists(atPath: looseLrcURL.path) {
                return looseLrcURL
            }
        }

        return nil
    }

    func loadLyrics(for song: Song) async -> Lyrics {
        if let lrcURL = await findLrcFile(for: song) {
            return await parse(from: lrcURL)
        }
        return Lyrics.empty()
    }
}
