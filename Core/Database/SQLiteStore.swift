import Foundation
import SQLite3

public enum SQLiteStoreError: Error, LocalizedError {
    case openFailed(String)
    case prepareFailed(String)
    case stepFailed(String)
    case bindFailed(String)

    public var errorDescription: String? {
        switch self {
        case let .openFailed(message):
            return "SQLite open failed: \(message)"
        case let .prepareFailed(message):
            return "SQLite prepare failed: \(message)"
        case let .stepFailed(message):
            return "SQLite step failed: \(message)"
        case let .bindFailed(message):
            return "SQLite bind failed: \(message)"
        }
    }
}

public final class SQLiteStore {
    private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private var database: OpaquePointer?
    public let url: URL

    public init(url: URL) throws {
        self.url = url
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        guard sqlite3_open(url.path, &database) == SQLITE_OK else {
            throw SQLiteStoreError.openFailed(lastErrorMessage)
        }
        try execute("PRAGMA foreign_keys = ON")
        try execute("PRAGMA journal_mode = WAL")
    }

    deinit {
        sqlite3_close(database)
    }

    public func execute(_ sql: String) throws {
        guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
            throw SQLiteStoreError.stepFailed(lastErrorMessage)
        }
    }

    public func withStatement<T>(_ sql: String, body: (OpaquePointer?) throws -> T) throws -> T {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteStoreError.prepareFailed(lastErrorMessage)
        }
        defer {
            sqlite3_finalize(statement)
        }
        return try body(statement)
    }

    public func run(_ sql: String, bind: (OpaquePointer?) throws -> Void = { _ in }) throws {
        try withStatement(sql) { statement in
            try bind(statement)
            guard sqlite3_step(statement) == SQLITE_DONE else {
                throw SQLiteStoreError.stepFailed(lastErrorMessage)
            }
        }
    }

    public func query<T>(_ sql: String, bind: (OpaquePointer?) throws -> Void = { _ in }, map: (OpaquePointer?) throws -> T) throws -> [T] {
        try withStatement(sql) { statement in
            try bind(statement)
            var values: [T] = []
            while true {
                let result = sqlite3_step(statement)
                if result == SQLITE_ROW {
                    values.append(try map(statement))
                } else if result == SQLITE_DONE {
                    return values
                } else {
                    throw SQLiteStoreError.stepFailed(lastErrorMessage)
                }
            }
        }
    }

    public func bind(_ value: String?, at index: Int32, in statement: OpaquePointer?) throws {
        if let value {
            guard sqlite3_bind_text(statement, index, value, -1, sqliteTransient) == SQLITE_OK else {
                throw SQLiteStoreError.bindFailed(lastErrorMessage)
            }
        } else {
            sqlite3_bind_null(statement, index)
        }
    }

    public func bind(_ value: Data?, at index: Int32, in statement: OpaquePointer?) throws {
        guard let value else {
            sqlite3_bind_null(statement, index)
            return
        }
        let result = value.withUnsafeBytes { buffer in
            sqlite3_bind_blob(statement, index, buffer.baseAddress, Int32(value.count), sqliteTransient)
        }
        guard result == SQLITE_OK else {
            throw SQLiteStoreError.bindFailed(lastErrorMessage)
        }
    }

    public func bind(_ value: Double?, at index: Int32, in statement: OpaquePointer?) throws {
        if let value {
            guard sqlite3_bind_double(statement, index, value) == SQLITE_OK else {
                throw SQLiteStoreError.bindFailed(lastErrorMessage)
            }
        } else {
            sqlite3_bind_null(statement, index)
        }
    }

    public func bind(_ value: Int?, at index: Int32, in statement: OpaquePointer?) throws {
        if let value {
            guard sqlite3_bind_int64(statement, index, sqlite3_int64(value)) == SQLITE_OK else {
                throw SQLiteStoreError.bindFailed(lastErrorMessage)
            }
        } else {
            sqlite3_bind_null(statement, index)
        }
    }

    public func textColumn(_ statement: OpaquePointer?, index: Int32) -> String? {
        guard let raw = sqlite3_column_text(statement, index) else {
            return nil
        }
        return String(cString: UnsafeRawPointer(raw).assumingMemoryBound(to: CChar.self))
    }

    public func dataColumn(_ statement: OpaquePointer?, index: Int32) -> Data? {
        guard let raw = sqlite3_column_blob(statement, index) else {
            return nil
        }
        let size = sqlite3_column_bytes(statement, index)
        return Data(bytes: raw, count: Int(size))
    }

    public func doubleColumn(_ statement: OpaquePointer?, index: Int32) -> Double {
        sqlite3_column_double(statement, index)
    }

    public func intColumn(_ statement: OpaquePointer?, index: Int32) -> Int {
        Int(sqlite3_column_int64(statement, index))
    }

    public func isNullColumn(_ statement: OpaquePointer?, index: Int32) -> Bool {
        sqlite3_column_type(statement, index) == SQLITE_NULL
    }

    private var lastErrorMessage: String {
        guard let message = sqlite3_errmsg(database) else {
            return "Unknown SQLite error"
        }
        return String(cString: message)
    }
}
