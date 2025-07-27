# Swift Passphrase Generator

A modern Swift package for generating cryptographically secure passphrases using the EFF Large Wordlist. Perfect for creating memorable yet strong passwords for your applications.

## Features

- 🔒 **Cryptographically Secure** - Uses `SecRandomCopyBytes` for true randomness
- 📝 **EFF Large Wordlist** - Built-in 7,776-word curated list from the Electronic Frontier Foundation
- 🎯 **Customizable** - Control word count, separators, and capitalization
- ⚡ **High Performance** - Efficient caching with lazy initialization
- 🛡️ **Thread-Safe** - Concurrency-safe implementation for modern Swift
- 📱 **Cross-Platform** - Supports iOS, macOS, tvOS, and watchOS

## Installation

### Swift Package Manager

Add SwiftPassphrases to your project using Xcode or by adding it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arraypress/swift-passphrase-generator.git", from: "1.0.0")
]
```

## Quick Start

```swift
import PassphraseGenerator

// Generate a default passphrase (4 words, lowercase, hyphen-separated)
let passphrase = PassphraseGenerator.generate()
// Result: "correct-horse-battery-staple"
```

## Usage Examples

### Basic Generation

```swift
// Default: 4 words, lowercase, hyphen-separated
let basic = PassphraseGenerator.generate()
// "aluminum-beacon-cluster-devoted"

// Custom word count (automatically clamped between 2-10)
let longer = PassphraseGenerator.generate(wordCount: 6)
// "aluminum-beacon-cluster-devoted-examine-firewall"
```

### Custom Formatting

```swift
// Different separators
let dotted = PassphraseGenerator.generate(separator: ".")
// "aluminum.beacon.cluster.devoted"

let spaced = PassphraseGenerator.generate(separator: " ")
// "aluminum beacon cluster devoted"

// Different capitalization styles
let capitalized = PassphraseGenerator.generate(casing: .capitalize)
// "Aluminum-Beacon-Cluster-Devoted"

let sentence = PassphraseGenerator.generate(casing: .sentenceCase)
// "Aluminum-beacon-cluster-devoted"

let alternating = PassphraseGenerator.generate(casing: .alternating)
// "aluminum-BEACON-cluster-DEVOTED"
```

### Custom Word Lists

```swift
// Use your own word list
let customWords = ["apple", "banana", "cherry", "dragon", "elephant"]
let custom = PassphraseGenerator.generate(
    wordCount: 3,
    separator: "_",
    casing: .uppercase,
    customWords: customWords
)
// "APPLE_DRAGON_BANANA"
```

### Security Analysis

```swift
// Calculate entropy for your passphrase configuration
let entropy = PassphraseGenerator.entropy(wordCount: 4) // ~51.7 bits
let strongEntropy = PassphraseGenerator.entropy(wordCount: 6) // ~77.5 bits

// Get information about the built-in wordlist
let info = PassphraseGenerator.wordListInfo()
print("Using \(info.name) with \(info.wordCount) words")
print("Entropy per word: \(info.entropyPerWord) bits")
```

## API Reference

### Core Methods

#### `generate()`
Generate a passphrase with default settings (4 words, lowercase, hyphen-separated).

#### `generate(wordCount:separator:casing:)`
Generate a customized passphrase using the built-in EFF wordlist.

- `wordCount`: Number of words (2-10, automatically clamped)
- `separator`: String to place between words
- `casing`: Capitalization style

#### `generate(wordCount:separator:casing:customWords:)`
Generate a passphrase using your own word list.

### Utility Methods

#### `entropy(wordCount:wordListSize:)`
Calculate the entropy (strength) of a passphrase configuration in bits.

#### `wordListInfo()`
Get metadata about the built-in EFF Large Wordlist.

### Casing Styles

```swift
public enum CasingStyle {
    case lowercase     // "word-word-word"
    case uppercase     // "WORD-WORD-WORD"
    case capitalize    // "Word-Word-Word"
    case sentenceCase  // "Word-word-word"
    case alternating   // "word-WORD-word"
}
```

## Security Guidelines

### Entropy Recommendations

- **40-50 bits**: Adequate for most personal use
- **50-60 bits**: Strong for business applications
- **60+ bits**: Excellent for high-security requirements

### Default Configuration Security

The default 4-word passphrase provides approximately **51.7 bits of entropy**, which is suitable for most applications. For higher security requirements, increase the word count:

```swift
// High security: ~77.5 bits of entropy
let secure = PassphraseGenerator.generate(wordCount: 6)
```

### Custom Word Lists

When using custom word lists, ensure they:
- Contain enough words (hundreds or thousands)
- Use diverse, unrelated words
- Avoid predictable patterns or sequences

## Performance

SwiftPassphrases is optimized for performance:

- **First call**: ~2ms (includes word list loading)
- **Subsequent calls**: ~0.002ms (cached word list)
- **Memory usage**: ~200KB for the EFF wordlist cache
- **Thread-safe**: No performance penalty for concurrent access

## Requirements

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 6.0+
- Xcode 16.0+

## About the EFF Large Wordlist

This library uses the [EFF Large Wordlist](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases), which contains 7,776 carefully selected words that are:

- **Memorable** - Common, recognizable words
- **Distinct** - Phonetically different to avoid confusion
- **Clean** - Free from offensive or problematic content
- **Optimized** - Uniform length distribution for maximum entropy

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- **EFF Large Wordlist** - Created by the [Electronic Frontier Foundation](https://www.eff.org)
- **Inspiration** - Based on the [Diceware](https://diceware.dmuth.org/) passphrase generation method

---

**Made with ❤️ for secure, memorable passwords**
