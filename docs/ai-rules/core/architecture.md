# 架構與檔案組織規則

## 現行架構

MoneyMate 採用 MVVM 為主，搭配 Repository 與部分 UseCase：

```text
SwiftUI View -> ViewModel -> UseCase（視複雜度） -> Repository Protocol -> Repository -> SwiftData
```

App 目前由 `MoneyMateApp` 與 `AppDependencies` 組成 composition root，透過 initializer 注入 repository、use case 與 ViewModel。既有 persistence model 仍帶有部分 UI metadata；這類 schema 或 domain boundary 調整不得在無關任務中一次全面遷移。

## 各層責任

### View

1. 呈現狀態、組合子 View、傳遞使用者 action。
2. 可管理 navigation、sheet、focus 與短生命週期的 UI state。
3. 不放商業規則、SwiftData 查詢或 repository 操作。
4. 不在 `body` 執行昂貴轉換、排序、篩選或產生不穩定 identity。

### ViewModel

1. 管理頁面 presentation state 與使用者事件。
2. UI-facing ViewModel 必須在 `MainActor` 隔離。
3. 不直接操作 SwiftUI View、navigation destination 或底層 `ModelContext`。
4. 依賴由 initializer 注入，優先依賴 protocol。
5. 必須能表達適用情境的 loading、empty、error 與 success 狀態。

### UseCase

1. UseCase 是選配層，不為了形式完整而建立空殼。
2. 跨 repository、業務規則、統計、驗證或 side effect 協調時使用 UseCase。
3. 不持有 View 或 UI state。
4. 金額與月份統計等 domain logic 優先放在此層或 domain type。

### Repository

1. 封裝 SwiftData 或其他 data source。
2. 不處理 toast、alert、navigation 或頁面 loading state。
3. 對上層暴露明確型別與錯誤，不靜默吞掉重要 persistence failure。
4. 新程式碼不得新增對全域 singleton 的依賴。

## 檔案位置

- App 入口：`MoneyMate/MoneyMateApp.swift`。
- 頁面與功能 View：`MoneyMate/Views/<Feature>/`。
- 跨功能共用 View：`MoneyMate/Views/Common/`。
- ViewModel 與 UseCase：延續現有 `MoneyMate/ViewModels/<Feature>/`。
- Repository protocol：`MoneyMate/Repositories/<Domain>/` 或現有 `Protocol/` 結構。
- Repository 實作與 persistence model：`MoneyMate/Repositories/<Domain>/`。
- Design token：`MoneyMate/DesignSystem/`。
- 通用 extension：`MoneyMate/Extension/`，只有確實跨功能通用時才新增。
- Helper：`MoneyMate/Helpers/`，不得作為無法分類責任的收容區。
- Unit Test：`MoneyMateTests/`，測試替身放在 `MoneyMateTests/Mock/` 或與測試就近的位置。

## 修改範圍

1. 小型 bug fix 延續目標模組可運作的既有模式，採最小修正。
2. 新功能遵循上述依賴方向與注入方式。
3. 若要將 `ObservableObject` 遷移到 Observation、移除 singleton 或重整資料夾，必須是使用者要求或完成當前任務不可避免的範圍。
