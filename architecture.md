# MoneyMate 架構

## 架構摘要

MoneyMate 採用 SwiftUI、Observation 與 SwiftData，以 feature-based 方式組織程式碼；每個 feature 依責任選擇 MV 或 MVVM，搭配選配 Service 與 Repository：

```text
SwiftUI View
    -> @Observable Feature Model / ViewModel
    -> Service（選配）
    -> Repository Protocol
    -> SwiftData Repository
    -> ModelContext
```

`MoneyMateApp` 是 composition root，負責建立 `ModelContainer` 與 `AppDependencies`。View、Feature Model 與 ViewModel 不直接建立 Repository，也不直接持有 `ModelContext`。

## MV / MVVM 選擇

- 預設使用 MV：View 能直接使用 application/domain data 時，以 `@MainActor @Observable` Feature Model 管理狀態與 Repository 操作。
- 需要 presentation adapter 時使用 MVVM：例如多來源組合、view-specific data、複雜狀態機、分頁、重試、格式化或請求競態。
- 純展示與局部互動 View 只使用值、`@State`、`@Binding` 與 action，不建立 Model 或 ViewModel。
- 不以 `@Observable` 或命名本身判定架構，也不要求每個 View 一對一建立 ViewModel。

## 各層責任

### App Composition

- `MoneyMateApp`：建立 production `ModelContainer`。
- `AppDependencies`：以相同 `ModelContext` 建立 Repository、Service、長生命週期 ViewModel 與 feature-scoped Model。
- 具草稿狀態的 `ExpenseEditorModel` 每次開啟 sheet 時重新建立。

### Presentation

- SwiftUI View 呈現狀態、管理 navigation/sheet 與傳遞使用者 action。
- `HomeViewModel` 管理首頁的 loading、content、empty、failed、分頁與 mutation 後刷新。
- `ExpenseEditorModel` 直接提供 `ExpenseDraft`，並管理儲存中、儲存失敗與 Repository 寫入。
- UI-facing observable model 使用 `@MainActor @Observable`。

### Domain / Service

- `MonthlyExpenseService` 使用 `Calendar` 建立明確的月份區間。
- 月統計讀取整月資料，不與分頁 query 共用 fetch limit。
- 收入、支出與餘額計算集中於 Service。

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
    -> MonthlyExpenseService
    -> ExpenseRepository
    -> SwiftData
    -> HomeLoadState
    -> SwiftUI
```

### 新增記帳

```text
ExpenseEditorSheet
    -> ExpenseEditorModel.save
    -> ExpenseRepository.addExpense + ModelContext.save
    -> 成功後刷新 HomeViewModel
    -> dismiss sheet
```

若儲存失敗，sheet 保持開啟並顯示錯誤，不會把失敗當成成功。

## 測試策略

- Repository：使用獨立 in-memory `ModelContainer` 驗證月份邊界、排序與分頁。
- Service：注入固定 `Calendar` 與 mock Repository，驗證跨月與統計規則。
- Feature Model / ViewModel：驗證 loading、empty、error、success 與儲存失敗狀態。
- UI Test：驗證新增、刪除與 sheet 流程。

## 已知技術債

1. `Expense` 仍同時是 SwiftData persistence model 與畫面資料來源。
2. `Category` 仍包含 `Color`、SF Symbol 與中文顯示值，domain 與 presentation 尚未完全分離。
3. Repository 目前在 Main Actor 使用主 `ModelContext`；若資料量顯著增加，再評估獨立 SwiftData actor 與 value projection。
4. `date` 與 `dateTime` 在 persistence schema 中語意重疊；需在有 migration 計畫時才調整。

上述項目都可能影響既有 persistence schema 或資料遷移，不應在無關功能中直接修改。
