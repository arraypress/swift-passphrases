//
//  WordList.swift
//  SwiftPassphrases
//
//  Word list loading and caching functionality
//  Created on 27/07/2025.
//

import Foundation

// MARK: - Word List Management

internal struct WordList {
    
    /// Thread-safe cached word list using lazy static initialization
    private static let cachedWordList: [String] = {
        do {
            return try loadEFFWordListFromBundle()
        } catch {
            fatalError("Failed to load built-in word list: \(error.localizedDescription)")
        }
    }()
    
    /// Load the built-in EFF Large Wordlist with thread-safe caching.
    ///
    /// The word list is loaded once using lazy static initialization,
    /// ensuring thread safety and optimal performance.
    ///
    /// - Returns: Array of 7,776 words from the EFF Large Wordlist
    static func loadBuiltInWords() -> [String] {
        return cachedWordList
    }
    
    /// Get statistics about the loaded word list.
    ///
    /// - Returns: WordListStatistics containing metadata about the loaded list
    internal static func getStatistics() -> WordListStatistics {
        let words = cachedWordList
        
        let totalCharacters = words.reduce(0) { $0 + $1.count }
        let averageLength = Double(totalCharacters) / Double(words.count)
        
        let estimatedMemoryUsage = words.reduce(0) { total, word in
            total + MemoryLayout<String>.size + word.utf8.count
        }
        
        return WordListStatistics(
            wordCount: words.count,
            averageWordLength: averageLength,
            totalCharacters: totalCharacters,
            estimatedMemoryUsage: estimatedMemoryUsage
        )
    }
    
    /// Clear cache (no-op for testing compatibility)
    internal static func clearCache() {
        // No-op - lazy static can't be cleared, which is actually better
        // for immutable data that should only be loaded once
    }
    
    /// Load the EFF Large Wordlist from bundle resources.
    private static func loadEFFWordListFromBundle() throws -> [String] {
        guard let url = Bundle.module.url(forResource: "eff-large-wordlist", withExtension: "txt") else {
            throw PassphraseError.wordListNotFound(
                "eff-large-wordlist.txt not found in bundle resources."
            )
        }
        
        let content = try String(contentsOf: url, encoding: .utf8)
        
        let words = content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard words.count > 1000 else {
            throw PassphraseError.invalidWordList(
                "Word list appears incomplete. Expected 7,776 words, found \(words.count)."
            )
        }
        
        return words
    }
}

// MARK: - Supporting Types

public enum PassphraseError: LocalizedError {
    case wordListNotFound(String)
    case wordListLoadError(String)
    case invalidWordList(String)
    
    public var errorDescription: String? {
        switch self {
        case .wordListNotFound(let message):
            return "Word list not found: \(message)"
        case .wordListLoadError(let message):
            return "Word list load error: \(message)"
        case .invalidWordList(let message):
            return "Invalid word list: \(message)"
        }
    }
}

internal struct WordListStatistics {
    let wordCount: Int
    let averageWordLength: Double
    let totalCharacters: Int
    let estimatedMemoryUsage: Int
}
