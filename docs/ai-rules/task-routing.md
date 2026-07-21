# AI 任務路由規則

本文件是 MoneyMate 任務前置閱讀與加讀條件的唯一權威來源。

## 所有任務必讀

1. `CLAUDE.md`
2. `docs/ai-rules/workflow/intake-and-scope.md`
3. `docs/ai-rules/workflow/definition-of-done.md`

若任務會修改 production code、測試或 project 設定，再讀：

4. `docs/ai-rules/core/project-baseline.md`
5. `docs/ai-rules/core/architecture.md`
6. `docs/ai-rules/workflow/verification.md`
7. `docs/ai-rules/security/privacy-and-secrets.md`

## 依任務加讀

1. 新功能、頁面或資料流程：`docs/ai-rules/entrypoints/feature-development.md`。
2. crash、錯誤行為、資料錯亂或 regression：`docs/ai-rules/entrypoints/bug-fix.md`。
3. SwiftUI View、畫面狀態、navigation、sheet、List、ForEach 或 animation：`docs/ai-rules/ui/swiftui-implementation.md`。
4. 顏色、字型、spacing、radius、共用元件、UI 文案或 Accessibility：`docs/ai-rules/ui/design-system-and-accessibility.md`。
5. async/await、Task、MainActor、actor、SwiftData context 或 repository：`docs/ai-rules/core/concurrency-and-swiftdata.md`。
6. 金額、收支、月份、日期、分頁或統計：`docs/ai-rules/core/money-domain.md`。
7. Unit Test、UI Test、mock、fake、in-memory container 或測試失敗：`docs/ai-rules/quality/testing.md`。
8. 新增或修改 Swift 型別、方法、property、protocol、enum、`MARK`、TODO 或程式註解：`docs/ai-rules/quality/annotation.md`。

一個任務可以同時符合多個條件；只要條件成立，就必須加讀對應文件。

## 開始修改前

1. 先檢查目標檔案及直接呼叫端。
2. 以繁體中文回報已閱讀哪些規則。
3. 說明本次預計修改的邊界。
4. 若發現需要新增 dependency、改 public contract、做 schema migration 或大範圍重構，先取得使用者同意。

## 完成前

1. 依 `docs/ai-rules/workflow/verification.md` 選擇最小有效驗證。
2. 依 `docs/ai-rules/workflow/definition-of-done.md` 做最終檢查。
3. 以繁體中文回報實際變更、驗證結果與剩餘風險。
