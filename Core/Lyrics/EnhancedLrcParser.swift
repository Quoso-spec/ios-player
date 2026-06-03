import Foundation

final class EnhancedLrcParser {
    static let shared = EnhancedLrcParser()

    private init() {}

    struct EnhancedLyricLine {
        let time: TimeInterval
        let text: String
        let translation: String?
        let romanization: String?
        let words: [WordTiming]?
    }

    struct WordTiming {
        let word: String
        let startTime: TimeInterval
        let endTime: TimeInterval?
    }

    func parse(content: String) -> [EnhancedLyricLine] {
        var lines: [EnhancedLyricLine] = []
        let rawLines = content.components(separatedBy: .newlines)

        var currentLine: EnhancedLyricLine?
        var currentTranslation: String?
        var currentRomanization: String?

        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                if let line = currentLine {
                    let enhancedLine = EnhancedLyricLine(
                        time: line.time,
                        text: line.text,
                        translation: currentTranslation,
                        romanization: currentRomanization,
                        words: line.words
                    )
                    lines.append(enhancedLine)
                    currentLine = nil
                    currentTranslation = nil
                    currentRomanization = nil
                }
                continue
            }

            if parseMetadata(trimmed) {
                continue
            }

            if let wordTimings = parseEnhancedLine(trimmed) {
                if let existing = currentLine {
                    let enhancedLine = EnhancedLyricLine(
                        time: existing.time,
                        text: existing.text,
                        translation: currentTranslation,
                        romanization: currentRomanization,
                        words: wordTimings
                    )
                    lines.append(enhancedLine)
                    currentLine = nil
                    currentTranslation = nil
                    currentRomanization = nil
                }
                continue
            }

            if trimmed.contains("[") && !trimmed.contains("<") {
                if let line = parseLine(trimmed) {
                    if let existing = currentLine {
                        let enhancedLine = EnhancedLyricLine(
                            time: existing.time,
                            text: existing.text,
                            translation: currentTranslation,
                            romanization: currentRomanization,
                            words: existing.words
                        )
                        lines.append(enhancedLine)
                    }
                    currentLine = line
                    currentTranslation = nil
                    currentRomanization = nil
                }
            } else if !trimmed.contains("[") && !trimmed.contains("<") {
                if currentTranslation == nil && !trimmed.isEmpty {
                    currentTranslation = trimmed
                } else if currentRomanization == nil && !trimmed.isEmpty {
                    currentRomanization = trimmed
                }
            }
        }

        if let line = currentLine {
            let enhancedLine = EnhancedLyricLine(
                time: line.time,
                text: line.text,
                translation: currentTranslation,
                romanization: currentRomanization,
                words: line.words
            )
            lines.append(enhancedLine)
        }

        return lines.sorted { $0.time < $1.time }
    }

    private func parseLine(_ line: String) -> EnhancedLyricLine? {
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
            centiseconds = csString.count == 2 ? (Double(csString) ?? 0) / 100.0 : (Double(csString) ?? 0) / 1000.0
        }

        let time = minutes * 60 + seconds + centiseconds
        let text = String(line[textRange]).trimmingCharacters(in: .whitespaces)

        guard !text.isEmpty else { return nil }

        return EnhancedLyricLine(time: time, text: text, translation: nil, romanization: nil, words: nil)
    }

    private func parseEnhancedLine(_ line: String) -> [WordTiming]? {
        let pattern = #"\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\]<(\d{2}):(\d{2})(?:\.(\d{2,3}))?>"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil else {
            return nil
        }

        let allPattern = #"\[(\d{2}):(\d{2})(?:\.(\d{2,3}))?\]<(\d{2}):(\d{2})(?:\.(\d{2,3}))?>([^<\[]+)"#
        guard let allRegex = try? NSRegularExpression(pattern: allPattern) else {
            return nil
        }

        let matches = allRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
        var words: [WordTiming] = []

        for match in matches {
            guard let wordRange = Range(match.range(at: 7), in: line) else { continue }

            let minutes = Double(line[Range(match.range(at: 4), in: line)!]) ?? 0
            let seconds = Double(line[Range(match.range(at: 5), in: line)!]) ?? 0

            var centiseconds = 0.0
            if let csRange = Range(match.range(at: 6), in: line) {
                let csString = String(line[csRange])
                centiseconds = csString.count == 2 ? (Double(csString) ?? 0) / 100.0 : (Double(csString) ?? 0) / 1000.0
            }

            let startTime = minutes * 60 + seconds + centiseconds
            let word = String(line[wordRange]).trimmingCharacters(in: .whitespaces)

            if !word.isEmpty {
                words.append(WordTiming(word: word, startTime: startTime, endTime: nil))
            }
        }

        for i in 0..<words.count - 1 {
            let current = words[i]
            let next = words[i + 1]
            words[i] = WordTiming(word: current.word, startTime: current.startTime, endTime: next.startTime)
        }

        return words.isEmpty ? nil : words
    }

    private func parseMetadata(_ line: String) -> Bool {
        let pattern = #"^\[(ti|ar|al|by|offset|re|ve):.*\]$"#
        return line.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }
}
