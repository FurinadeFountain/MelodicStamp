# Melodic Stamp 测试指南 / Testing Guide

## 概述 / Overview

本文档提供 Melodic Stamp 项目的完整测试指南，包括如何运行测试、当前测试覆盖情况以及测试最佳实践。

This document provides a complete testing guide for the Melodic Stamp project, including how to run tests, current test coverage, and testing best practices.

---

## 系统要求 / System Requirements

- **操作系统 / OS**: macOS 15.0 Sequoia 或更高版本
- **开发工具 / Tools**: Xcode 16.0+ (with Swift 6.0 support)
- **测试框架 / Framework**: Swift Testing (新的 Swift 原生测试框架)

⚠️ **注意**: 此项目仅能在 macOS 上构建和测试，因为它使用了 macOS 专用的 API 和框架。

⚠️ **Note**: This project can only be built and tested on macOS as it uses macOS-specific APIs and frameworks.

---

## 测试架构 / Test Architecture

### 测试目标 / Test Targets

项目包含 3 个测试目标：

1. **ModelsTests** - 测试数据模型和业务逻辑
   - 位置 / Location: `/ModelsTests/`
   - 导入 / Import: `@testable import Models`
   - 当前状态 / Status: 仅有示例测试（待实现）

2. **InterfaceTests** - 测试 UI 组件
   - 位置 / Location: `/InterfaceTests/`
   - 导入 / Import: `@testable import Interface`
   - 当前状态 / Status: 仅有示例测试（待实现）

3. **MelodicStampTests** - 测试主应用程序
   - 位置 / Location: `/MelodicStampTests/`
   - 导入 / Import: `@testable import MelodicStamp`
   - 当前状态 / Status: 包含实际测试（2 个测试套件）

### 已实现的测试 / Implemented Tests

#### SequenceExtensionTests
测试序列扩展功能，特别是归一化方法。

```swift
@Test func normalize() {
    let sequence: [Float] = [1, 2, 3, 4, 5]
    let normalizedSequence: [Float] = [0, 0.25, 0.5, 0.75, 1]
    #expect(sequence.normalized == normalizedSequence)
}
```

**测试内容**: 验证 `normalized` 扩展方法是否正确将数组归一化到 [0, 1] 范围。

#### UUIDShortenerTests
测试 UUID 缩短和恢复功能。

```swift
@Test func shortenAndExpand() {
    let uuid = UUID()
    let shortened = UUIDShortener.shorten(uuid: uuid)
    let expanded = UUIDShortener.expand(shortened: shortened)!
    #expect(expanded == uuid)
}
```

**测试内容**: 验证 UUID 可以被缩短并正确恢复到原始值。

---

## 如何运行测试 / How to Run Tests

### 方法 1: 使用 Xcode GUI

1. **打开项目 / Open Project**
   ```bash
   open "Melodic Stamp.xcodeproj"
   ```

2. **选择测试目标 / Select Test Target**
   - 在 Xcode 中选择 `MelodicStamp` scheme
   - 或选择特定的测试 scheme（如果有）

3. **运行所有测试 / Run All Tests**
   - 快捷键: `⌘ + U` (Command + U)
   - 或者: Product → Test

4. **运行单个测试 / Run Individual Test**
   - 打开测试文件
   - 点击测试方法左侧的菱形图标
   - 或右键点击测试 → Run Test

### 方法 2: 使用命令行 / Using Command Line

#### 运行所有测试 / Run All Tests
```bash
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -quiet
```

#### 运行特定测试目标 / Run Specific Test Target
```bash
# 仅运行 Models 测试
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -only-testing:ModelsTests

# 仅运行 Interface 测试
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -only-testing:InterfaceTests

# 仅运行 MelodicStamp 测试
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -only-testing:MelodicStampTests
```

#### 运行特定测试 / Run Specific Test
```bash
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -only-testing:MelodicStampTests/SequenceExtensionTests/normalize
```

#### 生成测试报告 / Generate Test Report
```bash
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -resultBundlePath TestResults.xcresult
```

查看结果:
```bash
open TestResults.xcresult
```

### 方法 3: 持续集成 / Continuous Integration

在 CI/CD 环境中运行测试:

```bash
#!/bin/bash
set -e

# 清理构建目录
xcodebuild clean \
  -scheme MelodicStamp

# 运行测试并生成覆盖率报告
xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult

# 导出覆盖率数据（可选）
xcrun xccov view --report TestResults.xcresult > coverage.txt
```

---

## 测试覆盖率 / Test Coverage

### 当前覆盖情况 / Current Coverage

| 模块 / Module | 测试数量 / Tests | 覆盖率 / Coverage | 状态 / Status |
|---------------|------------------|-------------------|----------------|
| Models | 1 (示例) | 未知 | 🟡 需要补充 |
| Interface | 1 (示例) | 未知 | 🟡 需要补充 |
| MelodicStamp | 2 | 部分 | 🟢 有实际测试 |

### 建议的测试优先级 / Recommended Testing Priorities

#### 🔴 高优先级 / High Priority

1. **Metadata System** (`Models/Metadata/`)
   - `Metadata.swift` - 元数据容器
   - `MetadataEntry.swift` - 修改追踪
   - `MetadataEditorProtocol.swift` - 编辑器实现

2. **Player System** (`Models/Player/`)
   - `Player.swift` - 播放器协议
   - `PlaybackState.swift` - 状态管理
   - `PlaybackTime.swift` - 时间追踪

3. **Lyrics Parsing** (`Models/Lyrics/`)
   - `LRC/LRCParser.swift` - LRC 格式解析
   - `TTML/TTMLParser.swift` - TTML 格式解析
   - `Raw/RawLyricsParser.swift` - 纯文本解析

#### 🟡 中优先级 / Medium Priority

4. **Playlist Management** (`Models/Playlist/`)
   - `Playlist.swift` - 播放列表
   - `Track.swift` - 音轨管理
   - `TrackIndexer.swift` - 索引系统

5. **Core Models** (`MelodicStamp/Models/Content/`)
   - `PlayerModel.swift` - 播放器状态
   - `LibraryModel.swift` - 库管理
   - `PlaylistModel.swift` - 播放列表视图模型

#### 🟢 低优先级 / Low Priority

6. **UI Components** (`Interface/`)
   - 快照测试
   - 交互测试
   - 布局测试

---

## 测试最佳实践 / Testing Best Practices

### 1. 使用 Swift Testing 框架

```swift
import Testing
@testable import Models

@Suite struct MetadataTests {
    @Test func modificationTracking() {
        var entry = MetadataEntry(wrappedValue: "Original")
        entry.currentValue = "Modified"
        #expect(entry.isModified == true)
    }

    @Test func restoreOriginalValue() {
        var entry = MetadataEntry(wrappedValue: "Original")
        entry.currentValue = "Modified"
        entry.restore()
        #expect(entry.currentValue == "Original")
        #expect(entry.isModified == false)
    }
}
```

### 2. 测试异步代码 / Test Async Code

```swift
@Test func loadPlaylistAsync() async throws {
    let library = LibraryModel()
    await library.loadPlaylists()
    #expect(!library.playlists.isEmpty)
}
```

### 3. 使用测试夹具 / Use Test Fixtures

```swift
@Suite struct LyricsParserTests {
    let sampleLRC = """
    [00:12.00]First line
    [00:17.20]Second line
    [00:21.10]Third line
    """

    @Test func parseLRC() throws {
        let parser = LRCParser()
        let lyrics = try parser.parse(from: sampleLRC)
        #expect(lyrics.lines.count == 3)
    }
}
```

### 4. 隔离测试 / Isolate Tests

每个测试应该独立运行，不依赖其他测试的状态:

```swift
@Test func testIndependently() {
    // 创建新的实例
    let playlist = Playlist()
    // 执行测试
    #expect(playlist.tracks.isEmpty)
}
```

### 5. 测试边界情况 / Test Edge Cases

```swift
@Suite struct TrackTests {
    @Test func emptyPlaylist() {
        let playlist = Playlist()
        #expect(playlist.tracks.isEmpty)
        #expect(playlist.totalDuration == 0)
    }

    @Test func singleTrack() {
        let playlist = Playlist()
        let track = Track(/* ... */)
        playlist.addTrack(track)
        #expect(playlist.tracks.count == 1)
    }

    @Test func manyTracks() {
        let playlist = Playlist()
        for i in 0..<1000 {
            playlist.addTrack(Track(/* ... */))
        }
        #expect(playlist.tracks.count == 1000)
    }
}
```

### 6. 测试错误处理 / Test Error Handling

```swift
@Test func invalidLyricsFormat() {
    let parser = LRCParser()
    #expect(throws: LyricsParsingError.self) {
        try parser.parse(from: "invalid format")
    }
}
```

---

## 性能测试 / Performance Testing

### 测量执行时间 / Measure Execution Time

```swift
@Test func measureIndexingPerformance() async {
    let tracks = createLargeTrackCollection(count: 10000)

    let start = Date()
    let indexer = TrackIndexer()
    await indexer.index(tracks)
    let duration = Date().timeIntervalSince(start)

    print("Indexing 10,000 tracks took \(duration) seconds")
    #expect(duration < 1.0) // Should complete within 1 second
}
```

### FFT 性能测试 / FFT Performance Test

```swift
@Test func audioVisualizationPerformance() async {
    let model = AudioVisualizerModel()
    let sampleData = generateAudioSamples(count: 1024)

    let start = Date()
    for _ in 0..<100 {
        model.analyze(sampleData)
    }
    let duration = Date().timeIntervalSince(start)

    // Should maintain 10 FPS (0.1s per frame)
    #expect(duration / 100 < 0.1)
}
```

---

## UI 测试 / UI Testing

### SwiftUI 快照测试 / SwiftUI Snapshot Testing

虽然当前项目未包含快照测试，但这是推荐的做法:

```swift
// 需要添加依赖: swift-snapshot-testing
@Test func playerViewSnapshot() {
    let view = PlayerView()
        .frame(width: 800, height: 600)

    // 生成快照并与参考图像对比
    assertSnapshot(of: view, as: .image)
}
```

### 预览环境测试 / Preview Environment Testing

使用现有的预览修饰器:

```swift
import MelodicStamp

@Test func previewEnvironments() {
    // 使用 PreviewEnvironmentsModifier 创建测试环境
    let view = ContentView()
        .modifier(PreviewEnvironmentsModifier())

    // 验证视图可以正确初始化
    #expect(view != nil)
}
```

---

## 调试测试 / Debugging Tests

### 打印调试信息 / Print Debug Info

```swift
@Test func debuggingExample() {
    let uuid = UUID()
    let shortened = UUIDShortener.shorten(uuid: uuid)

    print("Original UUID: \(uuid)")
    print("Shortened: \(shortened)")

    #expect(shortened.count < uuid.uuidString.count)
}
```

### 使用断点 / Use Breakpoints

1. 在 Xcode 中打开测试文件
2. 在要调试的行左侧点击添加断点
3. 运行测试（⌘ + U）
4. 当断点触发时使用 LLDB 调试器

### 查看测试日志 / View Test Logs

在 Xcode 中:
1. 运行测试后打开 Report Navigator (⌘ + 9)
2. 选择最新的测试报告
3. 查看每个测试的详细日志

---

## 常见问题 / Troubleshooting

### 问题 1: 测试无法找到模块 / Module Not Found

**错误**: `No such module 'Models'`

**解决方案**:
```swift
// 确保使用 @testable import
@testable import Models  // ✅ 正确
import Models            // ❌ 可能无法访问内部类型
```

### 问题 2: 异步测试超时 / Async Test Timeout

**错误**: Test timed out after 600 seconds

**解决方案**:
```swift
@Test(.timeLimit(.minutes(2)))  // 设置自定义超时
func slowAsyncTest() async throws {
    // 长时间运行的测试
}
```

### 问题 3: UI 测试失败 / UI Tests Failing

**原因**: UI 测试需要窗口环境

**解决方案**:
- 确保在 Xcode 中运行（不是命令行）
- 或使用 `xcodebuild` 的 `-destination` 参数

### 问题 4: 音频相关测试失败 / Audio Tests Failing

**原因**: 音频设备可能不可用

**解决方案**:
```swift
@Test func audioTest() throws {
    // 检查音频设备是否可用
    guard AudioDeviceManager.hasOutputDevice else {
        throw TestSkipError("No audio output device available")
    }
    // 继续测试...
}
```

---

## 测试检查清单 / Testing Checklist

在提交代码前，确保:

- [ ] 所有现有测试通过
- [ ] 新功能有对应的测试
- [ ] 测试覆盖主要代码路径
- [ ] 测试边界情况和错误处理
- [ ] 异步代码有适当的测试
- [ ] 性能关键路径有性能测试
- [ ] 测试代码有清晰的注释
- [ ] 无警告或编译错误

### 运行完整测试检查 / Run Full Test Check

```bash
#!/bin/bash
# run_tests.sh

echo "🧪 Running all tests..."

xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -quiet

if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Tests failed!"
    exit 1
fi

echo "📊 Checking code coverage..."

xcodebuild test \
  -scheme MelodicStamp \
  -destination 'platform=macOS' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult \
  -quiet

xcrun xccov view --report TestResults.xcresult

echo "✨ Test check complete!"
```

使用:
```bash
chmod +x run_tests.sh
./run_tests.sh
```

---

## 未来改进 / Future Improvements

### 待添加的测试 / Tests to Add

1. **元数据系统测试 / Metadata System Tests**
   - 元数据读取和写入
   - 批量编辑
   - 撤销/恢复功能

2. **歌词解析测试 / Lyrics Parsing Tests**
   - 各种 LRC 格式变体
   - TTML 复杂结构
   - 错误格式处理

3. **播放器测试 / Player Tests**
   - 播放状态转换
   - 音频设备切换
   - 播放模式（循环、随机等）

4. **播放列表测试 / Playlist Tests**
   - 添加/移除音轨
   - 拖放操作
   - 持久化和恢复

5. **性能测试 / Performance Tests**
   - 大量音轨的索引
   - 音频可视化 FFT 性能
   - UI 滚动性能

### 测试工具改进 / Testing Tools Improvements

- [ ] 添加代码覆盖率目标（建议 >70%）
- [ ] 集成快照测试库
- [ ] 设置 CI/CD 自动测试
- [ ] 添加测试数据生成器
- [ ] 创建测试辅助工具类

---

## 参考资源 / References

### 官方文档 / Official Documentation
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [XCTest Framework](https://developer.apple.com/documentation/xctest)
- [Xcode Testing](https://developer.apple.com/documentation/xcode/testing)

### 测试最佳实践 / Best Practices
- [Swift Testing Best Practices](https://developer.apple.com/documentation/swift/testing-best-practices)
- [Writing Testable Code](https://developer.apple.com/documentation/xcode/writing-testable-code)

### 相关工具 / Related Tools
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) - 快照测试
- [ViewInspector](https://github.com/nalexn/ViewInspector) - SwiftUI 视图检查

---

## 联系与贡献 / Contact & Contributing

如果你发现测试问题或想要贡献测试用例，请:

1. 创建 Issue 描述问题
2. 提交 Pull Request 包含新的测试
3. 确保遵循现有的测试模式和风格

**记住**: 好的测试是代码质量的保障！

**Remember**: Good tests are the guarantee of code quality!

---

*最后更新 / Last Updated: 2026-01-12*
*生成于 / Generated in Session: `claude/add-claude-documentation-CZ1Oe`*
