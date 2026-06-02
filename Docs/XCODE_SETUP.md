# Xcode 接入说明

当前仓库提供可接入 Xcode 的源码骨架，不包含 `.xcodeproj`。建议在 macOS 上按下面步骤创建工程壳。

## 1. 创建 App Target

1. 打开 Xcode 15 或更新版本。
2. 选择 `File > New > Project > iOS > App`。
3. Product Name 填 `SaltMusic`。
4. Interface 选择 `SwiftUI`，Language 选择 `Swift`。
5. Minimum Deployments 设为 `iOS 17.0`。
6. Bundle Identifier 暂填 `com.moriafly.saltplayer.ios.dev`，后续按企业/自签证书替换。

## 2. 导入源码

将以下目录拖入 App target，选择 `Create groups` 并勾选 App target：

- `App`
- `Core`
- `Services`
- `Features`
- `Resources`

如果 Xcode 自动生成了 `SaltMusicApp.swift`，删除自动生成的入口文件，保留本仓库的 `App/SaltMusicApp.swift`。

## 3. 配置 Info.plist 与能力

1. 在 target 的 `Info` 中使用 `App/Info.plist` 的内容，或手动同步其中键值。
2. 在 `Signing & Capabilities` 中启用 `Background Modes`。
3. 勾选 `Audio, AirPlay, and Picture in Picture`。
4. 企业/自签分发时替换 Team、Bundle ID 和 provisioning profile。

## 4. 链接系统框架

确保 target 能访问以下 Apple frameworks：

- `SwiftUI`
- `Foundation`
- `AVFoundation`
- `MediaPlayer`
- `UIKit`
- `UniformTypeIdentifiers`
- `SQLite3`

如果 SQLite3 链接失败，在 target `Build Phases > Link Binary With Libraries` 中添加 `libsqlite3.tbd`。

## 5. 添加测试 Target

1. 新建 iOS Unit Testing Bundle。
2. 将 `Tests/SaltMusicTests` 加入测试 target。
3. 如果 App module 名称不是 `SaltMusic`，同步修改测试文件中的 `@testable import SaltMusic`。

## 6. 首轮真机验收

优先使用真机验证文件 picker、security-scoped bookmark、后台音频、锁屏控制和系统媒体库权限。模拟器可以做 UI 和 LRC parser 快速验证，但不能代表完整音频/文件权限行为。

