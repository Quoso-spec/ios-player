# Milestones

## M1 本地播放闭环

- Xcode target 接入当前源码。
- 文件导入和文件夹授权可选择本地音频。
- `SQLiteLibraryStore` 可持久化曲库、收藏、播放历史和缺失状态。
- `AVQueuePlaybackEngine` 可播放队列、暂停、跳转、上一首、下一首。
- `NowPlayingService` 同步锁屏信息，并响应控制中心命令。

## M2 曲库体验

- 专辑、艺人、播放列表页面接入真实数据。
- 搜索、排序、收藏和最近播放完善为空态、错误态和大曲库性能路径。
- 元数据覆盖层加入编辑 UI，但不直接修改原文件。

## M3 椒盐风格体验

- 将授权图标、Logo、品牌色和文案替换占位资源。
- 补播放器动态背景、歌词页动效和更完整的主题 token。
- 验证 iPhone 小屏、全面屏和 iPad 分屏布局。

## M4 高级音频

- 在 `PlaybackEngine` 接口下扩展 `AVAudioEngine` 实现。
- 实现均衡器、淡入淡出、ReplayGain/音量标准化策略和睡眠定时。
- 保留 `AVQueuePlaybackEngine` 作为稳定回退。

## M5 分发与运维

- 替换正式 Bundle ID、Team ID、证书和 provisioning profile。
- 增加崩溃日志、数据库备份/恢复和导出诊断包。
- 验证 Debug 真机、Ad Hoc/自签 IPA、企业证书包。

