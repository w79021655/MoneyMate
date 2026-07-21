# MoneyMate 架構

## 架構摘要

MoneyMate 採用 SwiftUI、Observation 與 SwiftData，應用程式以 MVVM 為主，搭配 UseCase 與 Repository：

```text
SwiftUI View
    -> @Observable ViewModel
    -> UseCase
    -> Repository Protocol
    -> SwiftData Repository
    -> ModelContext
```

`MoneyMateApp` 是 composition root，負責建立 `ModelContainer` 與 `AppDependencies`。View 與 ViewModel 不直接建立 repository，也不直接持有 `ModelContext`。

## 各層責任

### App Composition

- `MoneyMateApp`：建立 production `ModelContainer`。
- `AppDependencies`：以相同 `ModelContext` 建立 repository、use case 與長生命週期 ViewModel。
- 具草稿狀態的 `ExpenseEditorViewModel` 每次開啟 sheet 時重新建立。

### Presentation

- SwiftUI View 呈現狀態、管理 navigation/sheet 與傳遞使用者 action。
- `HomeViewModel` 管理首頁的 loading、content、empty、failed、分頁與 mutation 後刷新。
- `ExpenseEditorViewModel` 管理表單驗證、儲存中與儲存失敗狀態。
- UI-facing observable model 使用 `@MainActor @Observable`。

### Domain / UseCase

- `HomeUseCase` 使用 `Calendar` 建立明確的月份區間。
- 月統計讀取整月資料，不與分頁 query 共用 fetch limit。
- 收入、支出與餘額計算集中於 UseCase。

### Data

- `ExpenseRepositoryProtocol` 定義月份查詢、分頁與 mutation contract。
- `ExpenseRepository` 封裝 SwiftData `ModelContext`。
- 寫入與刪除會明確呼叫 `save()`，錯誤透過 `throws` 傳回上層。
- 分頁以 `(date, id)` 作複合游標及排序鍵，避免相同 timestamp 漏資料。

## 主要資料流

### 首頁載入

```text
HomeView.task
    -> HomeViewModel.refresh
    -> HomeUseCase
    -> ExpenseRepository
    -> SwiftData
    -> HomeLoadState
    -> SwiftUI
```

### 新增記帳

```text
ExpenseEditorSheet
    -> ExpenseEditorViewModel.createExpense
    -> ExpenseRepository.addExpense + ModelContext.save
    -> 成功後刷新 HomeViewModel
    -> dismiss sheet
```

若儲存失敗，sheet 保持開啟並顯示錯誤，不會把失敗當成成功。

## 測試策略

- Repository：使用獨立 in-memory `ModelContainer` 驗證月份邊界、排序與分頁。
- UseCase：注入固定 `Calendar` 與 mock repository，驗證跨月與統計規則。
- ViewModel：驗證 loading、empty、error、success 與儲存失敗狀態。
- UI Test：驗證新增、刪除與 sheet 流程。

## 已知技術債

1. `Expense` 仍同時是 SwiftData persistence model 與畫面資料來源。
2. `Category` 仍包含 `Color`、SF Symbol 與中文顯示值，domain 與 presentation 尚未完全分離。
3. Repository 目前在 Main Actor 使用主 `ModelContext`；若資料量顯著增加，再評估獨立 SwiftData actor 與 value projection。
4. `date` 與 `dateTime` 在 persistence schema 中語意重疊；需在有 migration 計畫時才調整。

上述項目都可能影響既有 persistence schema 或資料遷移，不應在無關功能中直接修改。
