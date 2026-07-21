# 驗證規則與矩陣

## 共通原則

1. 選擇能覆蓋本次風險的最小有效驗證。
2. 文件、規則或純註解變更通常檢查 diff、連結與內容一致性，不需執行 XCTest。
3. Production Swift 行為改變至少執行相關 build 或 targeted test。
4. 完整測試只在跨層、高風險、project setting 變更或使用者要求時執行。
5. 不得因 unrelated working tree changes 擴大修改或誤把其失敗歸因於本次任務。

## 驗證矩陣

| 任務 | 最小建議驗證 |
| --- | --- |
| Markdown、規則、純註解 | 檢查 diff、文件連結與語言一致性 |
| Model、formatter、helper | 對應 targeted Unit Test |
| ViewModel、UseCase | 對應 targeted Unit Test，涵蓋主要狀態與邊界 |
| Repository、SwiftData | in-memory persistence test 與相關 build |
| SwiftUI layout 或樣式 | App build，加上 preview、simulator 或手動 smoke test |
| Navigation、sheet、互動流程 | App build，加上 UI Test 或手動流程驗證 |
| `.xcodeproj`、target membership、build setting | 受影響 scheme 的 build-for-testing 或 build |
| Schema migration 或跨層變更 | 相關 targeted tests，再依風險擴大測試 |

## 指令基線

先取得可用 destination，不在規則中寫死 simulator 型號與 OS：

```bash
xcodebuild -project MoneyMate.xcodeproj -scheme MoneyMate -showdestinations
```

App build：

```bash
xcodebuild \
  -project MoneyMate.xcodeproj \
  -scheme MoneyMate \
  -destination '<DESTINATION>' \
  build
```

Unit Test：

```bash
xcodebuild \
  -project MoneyMate.xcodeproj \
  -scheme MoneyMateTests \
  -destination '<DESTINATION>' \
  test
```

若環境的 simulator service、signing 或 sandbox 阻止執行，保留完整錯誤摘要，回報已嘗試方式與未覆蓋風險，不得把環境失敗描述成測試通過。

## 完成回報

以繁體中文列出：

1. 執行的命令或手動步驟。
2. 結果為通過、失敗或無法執行。
3. 失敗或阻礙原因。
4. 未覆蓋的剩餘風險。
