import Foundation

public enum LRCParser {
    public static func parse(text: String, source: LyricsSource) -> LyricsDocument {
        var title: String?
        var artist: String?
        var offset: TimeInterval = 0
        var lines: [LyricLine] = []

        for rawLine in text.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else {
                continue
            }

            if line.hasPrefix("[ti:") {
                title = tagValue(in: line, prefix: "[ti:")
                continue
            }
            if line.hasPrefix("[ar:") {
                artist = tagValue(in: line, prefix: "[ar:")
                continue
            }
            if line.hasPrefix("[offset:") {
                let milliseconds = Double(tagValue(in: line, prefix: "[offset:") ?? "") ?? 0
                offset = milliseconds / 1000
                continue
            }

            let parsed = parseTimedLine(line)
            for time in parsed.times {
                lines.append(LyricLine(time: time, text: parsed.text))
            }
        }

        return LyricsDocument(
            source: source,
            title: title,
            artist: artist,
            offset: offset,
            lines: lines.sorted { $0.time < $1.time },
            rawText: text
        )
    }

    private static func tagValue(in line: String, prefix: String) -> String? {
        guard line.hasPrefix(prefix), line.hasSuffix("]") else {
            return nil
        }
        return String(line.dropFirst(prefix.count).dropLast())
    }

    private static func parseTimedLine(_ line: String) -> (times: [TimeInterval], text: String) {
        var remainder = line
        var times: [TimeInterval] = []

        while remainder.hasPrefix("[") {
            guard let closeIndex = remainder.firstIndex(of: "]") else {
                break
            }
            let tag = String(remainder[remainder.index(after: remainder.startIndex)..<closeIndex])
            if let time = parseTimeTag(tag) {
                times.append(time)
            }
            remainder = String(remainder[remainder.index(after: closeIndex)...])
        }

        return (times, remainder.trimmingCharacters(in: .whitespaces))
    }

    private static func parseTimeTag(_ tag: String) -> TimeInterval? {
        let parts = tag.split(separator: ":")
        guard parts.count == 2, let minutes = Double(parts[0]) else {
            return nil
        }
        let secondsParts = parts[1].split(separator: ".", maxSplits: 1).map(String.init)
        guard let seconds = Double(secondsParts.first ?? "") else {
            return nil
        }
        let fraction: Double
        if secondsParts.count == 2 {
            let rawFraction = secondsParts[1]
            fraction = (Double(rawFraction) ?? 0) / pow(10, Double(rawFraction.count))
        } else {
            fraction = 0
        }
        return minutes * 60 + seconds + fraction
    }
}

