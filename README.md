<div align="center">
    <!-- 暂时注释掉 logo
    <img width="200" height="200" src="assets/images/logo/logo.png">
    -->
</div>

<div align="center">
    <h1>SakuraKono Player Framework (SKF)</h1>
<div align="center">
    
![GitHub repo size](https://img.shields.io/github/repo-size/CyaniAgent/sakurakono_player) 
![GitHub Repo stars](https://img.shields.io/github/stars/CyaniAgent/sakurakono_player) 
![GitHub all releases](https://img.shields.io/github/downloads/CyaniAgent/sakurakono_player/total) 
</div>
    <p><b>基于 Flutter 的通用视频播放器框架 —— 为各类视频应用提供开箱即用的模板</b></p>

> 🚧 **项目状态：重构中** – B站 适配层已隔离，核心接口已定义，Bridge 层已就绪。详见下文。

<!-- 原截图全部注释掉，因为项目还没界面
<img src="assets/screenshots/510shots_so.png" width="32%" alt="home" />
<img src="assets/screenshots/174shots_so.png" width="32%" alt="home" />
<img src="assets/screenshots/850shots_so.png" width="32%" alt="home" />
<br/>
<img src="assets/screenshots/main_screen.png" width="96%" alt="home" />
<br/>
-->

</div>

<br/>

## 适配平台

- [x] Android
- [x] iOS
- [x] Pad
- [x] Windows
- [x] Linux

---

## 当前阶段说明

- **已完成**: B站 业务代码已隔离到 `adapters/bilibili/`，核心播放器/账户/上报接口已定义（`lib/core/`），Bridge 层作为适配器唯一入口。项目已从 PiliPlus 更名为 SKF。
- **进行中**: 数据层重构（Repository 模式）、UI 解耦、插件化架构。
- 当前可编译运行，功能等同于 B站 客户端。通用框架的插件化仍在开发中。

---

## 快速开始

```bash
git clone https://github.com/CyaniAgent/sakurakono_player
cd sakurakono_player
flutter pub get
flutter analyze   # 0 errors
flutter run       # 启动 B站 客户端模式
```

---

## 规划中的功能（Roadmap）

> 以下为设想目标，并非已实现功能，将在后续开发中逐步落地。

- [x] B站 业务逻辑已隔离到 `adapters/bilibili/`
- [ ] 插件化架构（规划中）
- [x] 主题系统（已有）
- [ ] 更完善的跨平台适配（桌面端、移动端、Web）
- [x] 核心接口已定义（`lib/core/`）
- [ ] 示例应用（Demo App）供开发者参考
- [ ] 完善的文档和接入指南

---

## 与上游的关系

本项目是 [PiliPlus](https://github.com/bggRGjQaUbCoE/PiliPlus) 的衍生作品，由衷感谢原作者 [guozhigq/pilipala](https://github.com/guozhigq/pilipala) 和上游维护者 [orz12/PiliPalaX](https://github.com/orz12/PiliPalaX) 的开源贡献。  
我们将在遵守 GPLv3 协议的前提下，持续迭代，打造一个更具通用性的视频框架。

---

## 致谢

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect)
- [flutter_meedu_videoplayer](https://github.com/zezo357/flutter_meedu_videoplayer)
- [media-kit](https://github.com/media-kit/media-kit)
- [dio](https://pub.dev/packages/dio)
- 以及所有为开源社区做出贡献的开发者

---

## Star History

<a href="https://www.star-history.com/#CyaniAgent/sakurakono_player&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=CyaniAgent/sakurakono_player&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=CyaniAgent/sakurakono_player&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=CyaniAgent/sakurakono_player&type=Date" />
 </picture>
</a>
