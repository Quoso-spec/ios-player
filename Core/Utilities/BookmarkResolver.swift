import Foundation

public struct ResolvedBookmark {
    public var url: URL
    public var isStale: Bool
    public var didStartAccessingSecurityScopedResource: Bool

    public init(url: URL, isStale: Bool, didStartAccessingSecurityScopedResource: Bool) {
        self.url = url
        self.isStale = isStale
        self.didStartAccessingSecurityScopedResource = didStartAccessingSecurityScopedResource
    }
}

public protocol BookmarkResolving {
    func bookmark(for url: URL) throws -> Data
    func resolveBookmark(_ data: Data) throws -> ResolvedBookmark
    func resolveBookmark(for track: Track) throws -> ResolvedBookmark
    func stopAccessing(_ resolved: ResolvedBookmark)
}

public enum BookmarkResolverError: Error {
    case emptyBookmark
}

public final class DefaultBookmarkResolver: BookmarkResolving {
    public init() {}

    public func bookmark(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: [.minimalBookmark, .withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }

    public func resolveBookmark(_ data: Data) throws -> ResolvedBookmark {
        guard !data.isEmpty else {
            throw BookmarkResolverError.emptyBookmark
        }

        var isStale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        let didStart = url.startAccessingSecurityScopedResource()
        return ResolvedBookmark(url: url, isStale: isStale, didStartAccessingSecurityScopedResource: didStart)
    }

    public func resolveBookmark(for track: Track) throws -> ResolvedBookmark {
        try resolveBookmark(track.sourceURLBookmark)
    }

    public func stopAccessing(_ resolved: ResolvedBookmark) {
        if resolved.didStartAccessingSecurityScopedResource {
            resolved.url.stopAccessingSecurityScopedResource()
        }
    }
}

