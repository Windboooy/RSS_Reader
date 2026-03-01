# Simple RSS Reader (Flutter)

一个使用 Flutter 开发的简洁风格 RSS 阅读器。支持自定义订阅源、管理订阅列表以及在应用内浏览完整文章。

## ✨ 主要功能 (Features)

*   **RSS 订阅管理**:
    *   ➕ **添加订阅**: 支持输入 RSS 链接添加订阅源。会自动补全 `https://` 前缀。
    *   ✏️ **编辑订阅**: 长按订阅项可修改标题或链接。
    *   🗑️ **删除订阅**: 长按订阅项可删除不需要的源。
*   **阅读体验**:
    *   📜 **摘要预览**: 在列表中快速浏览文章标题和发布时间。
    *   📖 **文章详情**: 查看 RSS 提供的文章内容（支持 HTML 渲染）。
    *   🌐 **阅读原文**: 对于仅提供摘要的订阅源（如百度热搜 RSS），提供“阅读原文”按钮，在应用内通过内置浏览器查看完整网页内容。
*   **网络支持**:
    *   🔒 支持 HTTPS 和 HTTP (已配置 Cleartext Traffic)。
    *   🔄 下拉刷新获取最新内容。

## 🛠️ 技术栈 (Tech Stack)

*   **框架**: [Flutter](https://flutter.dev/) (Dart)
*   **状态管理**: [Riverpod](https://riverpod.dev/) (`AsyncNotifierProvider`)
*   **RSS 解析**: [rss_dart](https://pub.dev/packages/rss_dart)
*   **本地存储**: [shared_preferences](https://pub.dev/packages/shared_preferences)
*   **HTML 渲染**: [flutter_widget_from_html](https://pub.dev/packages/flutter_widget_from_html)
*   **内置浏览器**: [webview_flutter](https://pub.dev/packages/webview_flutter)

## 🚀 快速开始 (Getting Started)

### 环境要求
*   Flutter SDK
*   Android Studio / VS Code (推荐 JDK 17+)

### 运行项目

1.  克隆仓库：
    ```bash
    git clone https://github.com/Windboooy/RSS_Reader.git
    cd RSS_Reader
    ```

2.  获取依赖：
    ```bash
    flutter pub get
    ```

3.  运行应用：
    ```bash
    flutter run
    ```

### 打包发布 (Build APK)

构建发布版 APK：
```bash
flutter build apk --release
```
生成的 APK 文件位于：`build/app/outputs/flutter-apk/app-release.apk`

## 📄 许可证 (License)

本项目采用 [GPL-3.0 License](LICENSE) 开源。
如果您修改了本项目的源代码并进行分发，则必须开源您的修改版本。

---
**Author**: Windboooy
