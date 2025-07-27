//
//  PassphraseTests.swift
//  SwiftPassphrases
//
//  Comprehensive test suite for passphrase generation
//  Created on 27/07/2025.
//

import XCTest
@testable import SwiftPassphrases

final class PassphraseTests: XCTestCase {
    
    // MARK: - Basic Generation Tests
    
    func testDefaultGeneration() {
        let passphrase = Passphrase.generate()
        
        // Should contain exactly 3 hyphens (4 words)
        let components = passphrase.components(separatedBy: "-")
        XCTAssertEqual(components.count, 4, "Default passphrase should have 4 words")
        
        // Each component should be a non-empty word
        for component in components {
            XCTAssertFalse(component.isEmpty, "Each word should be non-empty")
            XCTAssertTrue(component.allSatisfy { $0.isLetter }, "Each word should contain only letters")
        }
        
        // Should be lowercase by default
        XCTAssertEqual(passphrase, passphrase.lowercased(), "Default passphrase should be lowercase")
    }
    
    func testCustomWordCount() {
        let testCases = [2, 3, 5, 6, 10]
        
        for wordCount in testCases {
            let passphrase = Passphrase.generate(wordCount: wordCount)
            let components = passphrase.components(separatedBy: "-")
            
            XCTAssertEqual(components.count, wordCount, "Passphrase should have \(wordCount) words")
        }
    }
    
    func testWordCountBounds() {
        // Test minimum bound (should clamp to 2)
        let tooFew = Passphrase.generate(wordCount: 1)
        XCTAssertEqual(tooFew.components(separatedBy: "-").count, 2, "Word count should be clamped to minimum of 2")
        
        // Test maximum bound (should clamp to 10)
        let tooMany = Passphrase.generate(wordCount: 15)
        XCTAssertEqual(tooMany.components(separatedBy: "-").count, 10, "Word count should be clamped to maximum of 10")
        
        // Test negative number (should clamp to 2)
        let negative = Passphrase.generate(wordCount: -5)
        XCTAssertEqual(negative.components(separatedBy: "-").count, 2, "Negative word count should be clamped to 2")
    }
    
    func testCustomSeparator() {
        let separators = [".", "_", " ", "🎯", "123"]
        
        for separator in separators {
            let passphrase = Passphrase.generate(separator: separator)
            let components = passphrase.components(separatedBy: separator)
            
            XCTAssertEqual(components.count, 4, "Should have 4 words regardless of separator")
            XCTAssertTrue(passphrase.contains(separator), "Passphrase should contain the custom separator")
        }
    }
    
    // MARK: - Casing Style Tests
    
    func testLowercaseCasing() {
        let passphrase = Passphrase.generate(casing: .lowercase)
        XCTAssertEqual(passphrase, passphrase.lowercased(), "Lowercase casing should produce all lowercase")
    }
    
    func testUppercaseCasing() {
        let passphrase = Passphrase.generate(casing: .uppercase)
        XCTAssertEqual(passphrase, passphrase.uppercased(), "Uppercase casing should produce all uppercase")
    }
    
    func testCapitalizeCasing() {
        let passphrase = Passphrase.generate(casing: .capitalize)
        let words = passphrase.components(separatedBy: "-")
        
        for word in words {
            XCTAssertTrue(word.first?.isUppercase == true, "Each word should start with uppercase")
            if word.count > 1 {
                let remaining = String(word.dropFirst())
                XCTAssertEqual(remaining, remaining.lowercased(), "Rest of word should be lowercase")
            }
        }
    }
    
    func testSentenceCaseCasing() {
        let passphrase = Passphrase.generate(casing: .sentenceCase)
        let words = passphrase.components(separatedBy: "-")
        
        // First word should be capitalized
        if !words.isEmpty {
            let firstWord = words[0]
            XCTAssertTrue(firstWord.first?.isUppercase == true, "First word should start with uppercase")
            
            // Remaining words should be lowercase
            for word in words.dropFirst() {
                XCTAssertEqual(word, word.lowercased(), "Remaining words should be lowercase")
            }
        }
    }
    
    func testAlternatingCasing() {
        let passphrase = Passphrase.generate(wordCount: 4, casing: .alternating)
        let words = passphrase.components(separatedBy: "-")
        
        XCTAssertEqual(words.count, 4, "Should have 4 words for this test")
        
        // Even indices (0, 2) should be lowercase, odd indices (1, 3) should be uppercase
        for (index, word) in words.enumerated() {
            if index % 2 == 0 {
                XCTAssertEqual(word, word.lowercased(), "Even-indexed words should be lowercase")
            } else {
                XCTAssertEqual(word, word.uppercased(), "Odd-indexed words should be uppercase")
            }
        }
    }
    
    // MARK: - Custom Word List Tests
    
    func testCustomWordList() {
        let customWords = ["apple", "banana", "cherry", "dog", "elephant"]
        let passphrase = Passphrase.generate(wordCount: 3, customWords: customWords)
        let words = passphrase.components(separatedBy: "-")
        
        XCTAssertEqual(words.count, 3, "Should have 3 words")
        
        // All words should be from the custom list
        for word in words {
            XCTAssertTrue(customWords.contains(word), "Word '\(word)' should be from custom list")
        }
    }
    
    func testCustomWordListWithDifferentCasing() {
        let customWords = ["RED", "green", "BluE"]
        let passphrase = Passphrase.generate(wordCount: 3, casing: .lowercase, customWords: customWords)
        let words = passphrase.components(separatedBy: "-")
        
        // All words should be lowercase regardless of input casing
        for word in words {
            XCTAssertEqual(word, word.lowercased(), "Words should be converted to lowercase")
        }
    }
    
    func testSingleWordCustomList() {
        let customWords = ["onlyword"]
        let passphrase = Passphrase.generate(wordCount: 3, customWords: customWords)
        
        // Should generate "onlyword-onlyword-onlyword"
        XCTAssertEqual(passphrase, "onlyword-onlyword-onlyword", "Should repeat the single word")
    }
    
    // MARK: - Entropy Calculation Tests
    
    func testEntropyCalculation() {
        // Test default EFF wordlist (7776 words)
        let entropy4Words = Passphrase.entropy(wordCount: 4)
        let expectedEntropy = 4.0 * log2(7776.0) // ~51.7 bits
        
        XCTAssertEqual(entropy4Words, expectedEntropy, accuracy: 0.1, "Entropy calculation should be accurate")
        
        // Test custom word list size
        let entropy5WordsCustom = Passphrase.entropy(wordCount: 5, wordListSize: 1000)
        let expectedCustom = 5.0 * log2(1000.0) // ~49.8 bits
        
        XCTAssertEqual(entropy5WordsCustom, expectedCustom, accuracy: 0.1, "Custom entropy calculation should be accurate")
    }
    
    func testEntropyEdgeCases() {
        // Zero word count should return 0
        XCTAssertEqual(Passphrase.entropy(wordCount: 0), 0.0, "Zero words should have zero entropy")
        
        // Zero word list size should return 0
        XCTAssertEqual(Passphrase.entropy(wordCount: 4, wordListSize: 0), 0.0, "Zero word list size should have zero entropy")
        
        // Negative values should return 0
        XCTAssertEqual(Passphrase.entropy(wordCount: -1), 0.0, "Negative word count should return zero entropy")
        XCTAssertEqual(Passphrase.entropy(wordCount: 4, wordListSize: -100), 0.0, "Negative word list size should return zero entropy")
    }
    
    // MARK: - Word List Info Tests
    
    func testWordListInfo() {
        let info = Passphrase.wordListInfo()
        
        XCTAssertEqual(info.name, "EFF Large Wordlist", "Should return correct wordlist name")
        XCTAssertEqual(info.wordCount, 7776, "Should return correct word count")
        XCTAssertEqual(info.entropyPerWord, log2(7776), accuracy: 0.01, "Should return correct entropy per word")
        XCTAssertFalse(info.description.isEmpty, "Should have a description")
    }
    
    // MARK: - Randomness and Uniqueness Tests
    
    func testRandomnessAndUniqueness() {
        var generatedPassphrases = Set<String>()
        let iterations = 100
        
        // Generate many passphrases and ensure they're mostly unique
        for _ in 0..<iterations {
            let passphrase = Passphrase.generate()
            generatedPassphrases.insert(passphrase)
        }
        
        // Should have generated mostly unique passphrases
        // Allow for some duplicates due to randomness, but most should be unique
        let uniqueCount = generatedPassphrases.count
        let uniquenessRatio = Double(uniqueCount) / Double(iterations)
        
        XCTAssertGreaterThan(uniquenessRatio, 0.9, "Should generate mostly unique passphrases (>90%)")
    }
    
    func testRandomnessWithCustomWordList() {
        let customWords = ["word1", "word2", "word3"]
        var results = [String: Int]()
        let iterations = 300 // Multiple of 3 for even distribution testing
        
        // Generate many 2-word passphrases and check first word distribution
        for _ in 0..<iterations {
            let passphrase = Passphrase.generate(wordCount: 2, customWords: customWords)
            let firstWord = passphrase.components(separatedBy: "-")[0]
            results[firstWord, default: 0] += 1
        }
        
        // Each word should appear roughly equally as the first word (within reasonable variance)
        let expectedCount = iterations / customWords.count
        let tolerance = expectedCount / 2 // Allow 50% variance
        
        for word in customWords {
            let actualCount = results[word] ?? 0
            XCTAssertGreaterThan(actualCount, expectedCount - tolerance, "Word '\(word)' should appear reasonably often")
            XCTAssertLessThan(actualCount, expectedCount + tolerance, "Word '\(word)' shouldn't appear too often")
        }
    }
    
    // MARK: - Built-in Word List Tests
    
    func testBuiltInWordListLoads() {
        // This test ensures the built-in word list can be loaded
        // If the test fails, it means the eff-large-wordlist.txt file is missing or corrupted
        let passphrase = Passphrase.generate()
        
        // If we get here without crashing, the word list loaded successfully
        XCTAssertFalse(passphrase.isEmpty, "Should generate non-empty passphrase with built-in word list")
    }
    
    func testBuiltInWordListStructure() {
        // Generate a passphrase to trigger word list loading
        _ = Passphrase.generate()
        
        // Check if we can get statistics
        let stats = WordList.getStatistics()
        
        XCTAssertGreaterThan(stats.wordCount, 7000, "Should have loaded a substantial word list")
        XCTAssertGreaterThan(stats.averageWordLength, 3.0, "Average word length should be reasonable")
        XCTAssertLessThan(stats.averageWordLength, 15.0, "Average word length shouldn't be too long")
    }
    
    // MARK: - Performance Tests
    
    func testGenerationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = Passphrase.generate()
            }
        }
    }
    
    func testCustomWordListPerformance() {
        let customWords = Array(0..<1000).map { "word\($0)" }
        
        measure {
            for _ in 0..<1000 {
                _ = Passphrase.generate(customWords: customWords)
            }
        }
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testEmptyCustomWordList() {
        // Empty word list should cause a fatal error, but we can't easily test that
        // This is more of a documentation of expected behavior
        // In practice, users should ensure their custom word lists are not empty
    }
    
    func testVeryLongSeparator() {
        let longSeparator = String(repeating: "🎯", count: 100)
        let passphrase = Passphrase.generate(separator: longSeparator)
        
        XCTAssertTrue(passphrase.contains(longSeparator), "Should handle very long separators")
    }
    
    func testUnicodeWordsInCustomList() {
        let unicodeWords = ["café", "naïve", "résumé", "🦄", "🎯"]
        let passphrase = Passphrase.generate(wordCount: 3, customWords: unicodeWords)
        let words = passphrase.components(separatedBy: "-")
        
        XCTAssertEqual(words.count, 3, "Should handle Unicode words correctly")
        
        for word in words {
            XCTAssertTrue(unicodeWords.contains(word), "Generated word should be from Unicode list")
        }
    }
}
