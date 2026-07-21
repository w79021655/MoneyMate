# MoneyMate AI 規則文件架構

本資料夾集中管理 MoneyMate 的 AI 協作與工程規則。規範依任務路由、入口、核心架構、UI、品質、安全與工作流拆分，避免單一 `CLAUDE.md` 過長，也避免每次任務載入全部資訊。

## 文件地圖

- `task-routing.md`：唯一的任務選讀入口。
- `entrypoints/`：功能開發與 bug fix 的任務流程。
- `core/`：專案基線、架構、Concurrency、SwiftData 與記帳領域規則。
- `ui/`：SwiftUI、Design System、在地化與 Accessibility 規則。
- `quality/`：Swift 註解、單元測試、UI 測試與測試隔離規範。
- `security/`：隱私、secrets、log 與測試資料規範。
- `workflow/`：需求範圍、驗證矩陣與完成定義。

## 閱讀方式

1. 所有任務先讀 repository 根目錄的 `CLAUDE.md`。
2. 再讀 `docs/ai-rules/task-routing.md`。
3. 只加讀與任務直接相關的規則，避免不必要的 context 膨脹。
4. 規則內容與任務路由有衝突時，以 `CLAUDE.md` 的優先順序處理。

## 維護原則

1. `task-routing.md` 是前置閱讀與加讀條件的唯一權威來源。
2. 共通規則只維護一份，其他文件以連結引用，不複製整段文字。
3. 長期有效的 invariant 才放入本資料夾；一次性計畫放在 feature spec、issue 或對應任務文件。
4. 專案的 target、工具鏈、架構邊界、資料夾、驗證策略或交付流程改變時，必須檢查相關規則是否需要同步更新。
5. 新增規則時應能被觀察或驗證，避免「寫出好程式碼」這類無法判斷的描述。
6. 本資料夾內新增或修改的本文一律使用繁體中文；程式識別字與技術專有名詞依 `CLAUDE.md` 保留原文。
