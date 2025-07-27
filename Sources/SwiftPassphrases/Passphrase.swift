//
//  Passphrase.swift
//  SwiftPassphrases
//
//  Secure passphrase generation using cryptographically secure random selection
//  Created on 27/07/2025.
//

import Foundation
import Security

// MARK: - Main Public API

public struct Passphrase {
    
    /// Generate a secure passphrase with default settings.
    ///
    /// Uses the EFF Large Wordlist (7,776 words) to create a 4-word passphrase
    /// separated by hyphens in lowercase. This provides approximately 52 bits
    /// of entropy, which is suitable for most security requirements.
    ///
    /// ## Example
    /// ```swift
    /// let passphrase = Passphrase.generate()
    /// // Result: "correct-horse-battery-staple"
    /// ```
    ///
    /// - Returns: A 4-word passphrase with approximately 52 bits of entropy
    public static func generate() -> String {
        return generate(wordCount: 4, separator: "-", casing: .lowercase)
    }
    
    /// Generate a passphrase with custom options using the built-in EFF wordlist.
    ///
    /// Creates a passphrase using the EFF Large Wordlist with customizable
    /// word count, separator, and casing style. Word count is automatically
    /// clamped between 2 and 10 for security and usability.
    ///
    /// ## Example
    /// ```swift
    /// let passphrase = Passphrase.generate(
    ///     wordCount: 5,
    ///     separator: ".",
    ///     casing: .capitalize
    /// )
    /// // Result: "Aluminum.Beacon.Cluster.Devoted.Examine"
    /// ```
    ///
    /// - Parameters:
    ///   - wordCount: Number of words to include (2-10, defaults to 4)
    ///   - separator: String to place between words (defaults to "-")
    ///   - casing: How to format the word capitalization (defaults to lowercase)
    /// - Returns: Generated passphrase string
    public static func generate(
        wordCount: Int = 4,
        separator: String = "-",
        casing: CasingStyle = .lowercase
    ) -> String {
        return generateInternal(
            wordCount: wordCount,
            separator: separator,
            casing: casing,
            customWords: nil
        )
    }
    
    /// Generate a passphrase using a custom word list.
    ///
    /// Advanced method that allows providing a custom array of words instead
    /// of using the built-in EFF wordlist. Useful for specialized applications,
    /// non-English languages, or testing with predictable word sets.
    ///
    /// ## Example
    /// ```swift
    /// let customWords = ["apple", "banana", "cherry", "dog", "elephant"]
    /// let passphrase = Passphrase.generate(
    ///     wordCount: 3,
    ///     separator: "_",
    ///     casing: .uppercase,
    ///     customWords: customWords
    /// )
    /// // Result: "APPLE_CHERRY_DOG"
    /// ```
    ///
    /// - Parameters:
    ///   - wordCount: Number of words to include (2-10, defaults to 4)
    ///   - separator: String to place between words (defaults to "-")
    ///   - casing: How to format the word capitalization (defaults to lowercase)
    ///   - customWords: Array of words to select from instead of built-in list
    /// - Returns: Generated passphrase string
    public static func generate(
        wordCount: Int = 4,
        separator: String = "-",
        casing: CasingStyle = .lowercase,
        customWords: [String]
    ) -> String {
        return generateInternal(
            wordCount: wordCount,
            separator: separator,
            casing: casing,
            customWords: customWords
        )
    }
    
    /// Calculate the entropy (in bits) for a passphrase configuration.
    ///
    /// Entropy measures the theoretical strength of a passphrase based on
    /// the size of the word list and number of words selected. Higher
    /// entropy values indicate stronger passphrases.
    ///
    /// ## Example
    /// ```swift
    /// let entropy = Passphrase.entropy(wordCount: 4, wordListSize: 7776)
    /// // Result: ~51.7 bits (log2(7776^4))
    /// ```
    ///
    /// ## Entropy Guidelines
    /// - 40-50 bits: Adequate for most personal use
    /// - 50-60 bits: Strong for business applications
    /// - 60+ bits: Excellent for high-security requirements
    ///
    /// - Parameters:
    ///   - wordCount: Number of words in the passphrase
    ///   - wordListSize: Size of the word list (defaults to 7776 for EFF Large)
    /// - Returns: Entropy value in bits
    public static func entropy(wordCount: Int, wordListSize: Int = 7776) -> Double {
        guard wordCount > 0 && wordListSize > 0 else { return 0.0 }
        return Double(wordCount) * log2(Double(wordListSize))
    }
    
    /// Get information about the built-in EFF Large Wordlist.
    ///
    /// Returns metadata about the default wordlist used by this library,
    /// including word count and estimated entropy per word.
    ///
    /// ## Example
    /// ```swift
    /// let info = Passphrase.wordListInfo()
    /// print("Words: \(info.wordCount), Entropy per word: \(info.entropyPerWord) bits")
    /// // Result: "Words: 7776, Entropy per word: 12.92 bits"
    /// ```
    ///
    /// - Returns: WordListInfo containing metadata about the built-in list
    public static func wordListInfo() -> WordListInfo {
        return WordListInfo(
            name: "EFF Large Wordlist",
            wordCount: 7776,
            entropyPerWord: log2(7776), // ~12.92 bits
            description: "Curated by the Electronic Frontier Foundation for secure passphrase generation"
        )
    }
}

// MARK: - Supporting Types

/// Style options for word capitalization in generated passphrases.
public enum CasingStyle {
    /// All words in lowercase
    /// Example: "correct-horse-battery-staple"
    case lowercase
    
    /// All words in uppercase
    /// Example: "CORRECT-HORSE-BATTERY-STAPLE"
    case uppercase
    
    /// First letter of each word capitalized
    /// Example: "Correct-Horse-Battery-Staple"
    case capitalize
    
    /// First word capitalized, rest lowercase (sentence style)
    /// Example: "Correct-horse-battery-staple"
    case sentenceCase
    
    /// Alternating between lowercase and uppercase words
    /// Example: "correct-HORSE-battery-STAPLE"
    case alternating
}

/// Information about a word list used for passphrase generation.
public struct WordListInfo {
    /// Human-readable name of the word list
    public let name: String
    
    /// Total number of words in the list
    public let wordCount: Int
    
    /// Entropy contribution per word (in bits)
    public let entropyPerWord: Double
    
    /// Description of the word list source or purpose
    public let description: String
}

// MARK: - Internal Implementation

private extension Passphrase {
    
    /// Internal method that handles all passphrase generation logic.
    ///
    /// This method consolidates the generation logic for both built-in and
    /// custom word lists, applying security constraints and formatting.
    ///
    /// - Parameters:
    ///   - wordCount: Number of words to generate
    ///   - separator: String to join words with
    ///   - casing: Capitalization style to apply
    ///   - customWords: Optional custom word list (nil uses built-in EFF list)
    /// - Returns: Generated passphrase string
    static func generateInternal(
        wordCount: Int,
        separator: String,
        casing: CasingStyle,
        customWords: [String]?
    ) -> String {
        
        // Clamp word count to reasonable bounds for security and usability
        let clampedWordCount = max(2, min(10, wordCount))
        
        // Use custom words or load built-in EFF list
        let words = customWords ?? WordList.loadBuiltInWords()
        
        // Ensure we have enough words to generate from
        guard !words.isEmpty else {
            fatalError("Cannot generate passphrase: word list is empty")
        }
        
        // Generate the specified number of random words
        let selectedWords = (0..<clampedWordCount).map { _ in
            selectRandomWord(from: words)
        }
        
        // Apply the requested casing style
        let casedWords = applyCasing(selectedWords, style: casing)
        
        // Join with the specified separator
        return casedWords.joined(separator: separator)
    }
    
    /// Select a random word from the provided word list using cryptographically secure randomness.
    ///
    /// Uses SecRandomCopyBytes to ensure true randomness suitable for
    /// cryptographic applications. This prevents algorithmic bias and
    /// ensures uniform distribution across the word list.
    ///
    /// - Parameter words: Array of words to select from
    /// - Returns: A randomly selected word from the array
    static func selectRandomWord(from words: [String]) -> String {
        // Generate cryptographically secure random bytes
        var randomBytes = Data(count: 4)
        let status = randomBytes.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 4, bytes.bindMemory(to: UInt8.self).baseAddress!)
        }
        
        // Ensure random generation succeeded
        guard status == errSecSuccess else {
            fatalError("Failed to generate cryptographically secure random bytes")
        }
        
        // Convert bytes to integer and get array index
        let randomValue = randomBytes.withUnsafeBytes { bytes in
            bytes.bindMemory(to: UInt32.self).first ?? 0
        }
        
        let index = Int(randomValue % UInt32(words.count))
        return words[index]
    }
    
    /// Apply the specified casing style to an array of words.
    ///
    /// Transforms word capitalization according to the chosen style while
    /// preserving the original word content and order.
    ///
    /// - Parameters:
    ///   - words: Array of words to transform
    ///   - style: Casing style to apply
    /// - Returns: Array of words with applied casing
    static func applyCasing(_ words: [String], style: CasingStyle) -> [String] {
        switch style {
        case .lowercase:
            return words.map { $0.lowercased() }
            
        case .uppercase:
            return words.map { $0.uppercased() }
            
        case .capitalize:
            return words.map { $0.capitalized }
            
        case .sentenceCase:
            return words.enumerated().map { index, word in
                index == 0 ? word.capitalized : word.lowercased()
            }
            
        case .alternating:
            return words.enumerated().map { index, word in
                index % 2 == 0 ? word.lowercased() : word.uppercased()
            }
        }
    }
    
}
