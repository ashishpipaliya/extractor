# Contributing to Extractor

Thank you for your interest in contributing to Extractor! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Screenshots** (if applicable)
- **Environment details**:
  - Flutter version
  - Dart version
  - Android/iOS version
  - Device model

### Suggesting Features

Feature requests are welcome! Please:

- Check if the feature already exists
- Provide a clear use case
- Explain why this feature would be useful
- Consider implementation complexity

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**: `git commit -m 'Add amazing feature'`
6. **Push to your fork**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

## Development Setup

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Dart SDK
- Git

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/ashishpipaliya/extractor.git
cd extractor

# Get dependencies
flutter pub get

# Generate Pigeon code
dart run pigeon --input pigeons/youtube_dl_api.dart

# Run example app
cd example
flutter run
```

## Project Structure

```
extractor/
├── android/                 # Android native code
│   └── src/main/kotlin/
│       └── com/ashishpipaliya/extractor/
│           ├── ExtractorPlugin.kt
│           ├── core/        # Core managers
│           ├── service/     # Business logic
│           └── mapper/      # Data transformation
├── ios/                     # iOS native code (planned)
├── lib/                     # Dart code
│   └── src/
│       ├── generated/       # Pigeon-generated code
│       ├── models/          # Data models
│       └── utils/           # Helper utilities
├── pigeons/                 # Pigeon API definitions
└── example/                 # Example app
```

## Coding Standards

### Dart Code

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Format code with `dart format`
- Add documentation comments for public APIs

### Kotlin Code

- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use meaningful variable names
- Keep functions small and focused
- Add KDoc comments for public APIs

### Architecture Principles

- **SOLID Principles**: Follow Single Responsibility, Open/Closed, etc.
- **Separation of Concerns**: Keep business logic separate from UI
- **Dependency Injection**: Use constructor injection
- **Error Handling**: Always handle errors gracefully

## Testing

### Running Tests

```bash
# Run Dart tests
flutter test

# Run Android tests
cd android
./gradlew test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for critical flows
- Aim for >80% code coverage

## Pigeon API Changes

When modifying the Pigeon API:

1. Edit `pigeons/youtube_dl_api.dart`
2. Regenerate code: `dart run pigeon --input pigeons/youtube_dl_api.dart`
3. Update Kotlin implementations
4. Update Dart wrapper
5. Update documentation
6. Test thoroughly

## Documentation

- Update README.md for user-facing changes and API changes
- Add inline code comments
- Update CHANGELOG.md

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add audio extraction feature
fix: resolve download cancellation issue
docs: update README with new examples
refactor: improve service layer architecture
test: add unit tests for InfoService
chore: update dependencies
```

## Release Process

1. Update version in `pubspec.yaml`
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create GitHub release
6. Publish to pub.dev (if applicable)

## iOS Implementation

Interested in implementing iOS support? See [IOS_ROADMAP.md](IOS_ROADMAP.md) for:

- Implementation approaches
- Technical challenges
- Architecture recommendations
- Timeline estimates

## Questions?

- Open an issue for questions
- Check existing issues and discussions
- Read the documentation thoroughly

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Extractor! 🎉
