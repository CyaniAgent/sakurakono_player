# AGENTS.md — lib/adapters/example (适配器开发骨架)

CHILD of root AGENTS.md.

## 用途

新适配器的复制起点。复制本目录 → 改名 → 在 `lib/adapters/adapters.dart` 注册 →
`--dart-define=ADAPTER=example` 即可启动一个"全能力不支持"的最小应用。

## 结构

单文件 `example_adapter.dart`:
- `ExampleAdapter implements AppAdapter`:name/onAppStart*/registerDependencies/routes/
  processImageUrl/buildShareLink/openUrl/classifyPlayInput。
- `ExampleVideoHost extends VideoHost`:继承 `DefaultPlayerCapabilities`(全部能力
  no-op + supported=false),主接口成员以 `throw UnimplementedError` 标注待实现点。

## 实现顺序建议

1. repository:先 `VideoRepository.rcmdVideoList`(驱动首页)+ `videoUrl`(驱动播放)。
2. `ExampleVideoHost`:填 playerHost(装配 lib/player 的 PlayerController)。
3. 能力按需接入:覆写 `segmentSkip/series/playlist/notes/audioMode/...` getter
   返回自身实现;页面自动解除降级。
4. 其余 Host(member/dynamics/main/setting/mine/download)按页面需求实现。

## 规则

- 只依赖 `lib/core`(含 contract)、`lib/pages`、`lib/common`、`lib/player`、`lib/router`、`lib/utils`。
- 不支持的能力保持默认,不要写半吊子实现。
- 每个覆写成员写 dartdoc(语义/参数/错误行为)。
