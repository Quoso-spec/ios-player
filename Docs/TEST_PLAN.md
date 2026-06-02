# Test Plan

## Playback

- 前台播放、后台播放、锁屏信息、控制中心、耳机控制。
- 来电/闹钟中断后恢复策略。
- 蓝牙设备切换。
- 长时间队列播放和队列末尾行为。

## Files

- 单文件导入。
- 文件夹授权导入。
- security-scoped bookmark 恢复。
- 授权失效、文件移动、文件删除。
- 重复扫描和千首级曲库。

## Formats

- `mp3`
- `m4a`
- `aac`
- `wav`
- `flac`
- `alac`
- 不支持格式要显示明确错误或跳过原因。

## Lyrics

- 同名 `.lrc`。
- 内嵌歌词 best-effort。
- 手动保存歌词。
- 无歌词状态。
- 时间轴 offset。

## Data

- 首次迁移。
- 播放列表创建和编辑。
- 收藏切换。
- 搜索和排序。
- 播放历史。
- 备份/恢复占位流程。

## Distribution

- Debug 真机。
- Ad Hoc / 自签 IPA。
- 企业证书包。
- 后台音频 entitlement。
- Info.plist 权限文案。

