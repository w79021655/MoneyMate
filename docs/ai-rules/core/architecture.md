# 架構與檔案組織規則

## 現行架構

MoneyMate 採用 feature-based 組織，並依各 feature 的責任選擇 MV 或 MVVM，搭配 Repository 與選配 Service：

```text
SwiftUI View
    -> Feature Model 或 ViewModel
    -> Service（視複雜度）
    -> Repository Protocol
    -> Repository
    -> SwiftData
```

App 目前由 `MoneyMateApp` 與 `AppDependencies` 組成 composition root，透過 initializer 注入 Repository、Service、Feature Model 與 ViewModel。既有 persistence model 仍帶有部分 UI metadata；這類 schema 或 domain boundary 調整不得在無關任務中一次全面遷移。

## MV 與 MVVM 選擇

1. 每個 feature 依責任獨立選擇 MV 或 MVVM，不要求全專案所有畫面採用同一形式。
2. 預設優先使用 MV。當 View 能直接使用 domain 或 application data，不需要額外 presentation transformation 時，使用 `@MainActor @Observable` Feature Model，並以 `Model` 結尾命名。
3. Feature Model 可以持有 feature state、透過 protocol dependency injection 使用 Repository 或 Service、執行非同步操作，以及管理 loading、saving 與 error 等操作狀態。
4. 只有需要明確 presentation adapter 時才使用 MVVM，並以 `ViewModel` 結尾命名。適用情境包含：
   - 組合多個 domain model 或資料來源。
   - 將 domain model 轉換成 view-specific data。
   - 管理複雜畫面狀態機、分頁、重試或請求競態。
   - 準備畫面專用的分組、排序、格式化或顯示狀態。
   - Presentation 行為需要獨立測試。
5. 不以是否使用 `@Observable`、是否逐欄暴露資料或型別名稱本身判定 MV/MVVM；判斷依據是物件的實際責任。
6. 不為每個子 View 機械式建立 Model 或 ViewModel，也不建立與 domain model 一對一複製而沒有實際價值的顯示型別。
7. 純展示或只有局部互動狀態的 View，直接使用 `let`、`@State private`、`@Binding` 與 action closure。

## 各層責任

### View

1. 呈現狀態、組合子 View、傳遞使用者 action。
2. 可管理 navigation、sheet、focus 與短生命週期的 UI state。
3. 不放商業規則、SwiftData 查詢或 repository 操作。
4. 不在 `body` 執行昂貴轉換、排序、篩選或產生不穩定 identity。

### Feature Model

1. 提供 View 可直接使用的 application data 與 feature-level state。
2. UI-facing Observable Model 必須在 `MainActor` 隔離。
3. 不直接操作 SwiftUI View、dismiss、navigation destination 或底層 `ModelContext`。
4. Repository 或 Service 依賴由 initializer 注入，優先依賴 protocol。
5. 可以被同一 feature 內真正共享狀態的多個 View 使用，但不得為追求共用而膨脹成全域 God Object。

### ViewModel

1. 作為 View 與 domain/application data 之間的 presentation adapter。
2. UI-facing ViewModel 必須在 `MainActor` 隔離。
3. 不直接操作 SwiftUI View、navigation destination 或底層 `ModelContext`。
4. 依賴由 initializer 注入，優先依賴 protocol。
5. 依功能需要表達 loading、empty、error、content、pagination 與 retry 等 presentation state。

### Service

1. Service 是選配層，不為了形式完整而建立空殼。
2. 跨 Repository、業務規則、統計、驗證或 side effect 協調時使用 Service。
3. 不持有 View 或 UI state。
4. 金額與月份統計等 domain logic 優先放在此層或 domain type。
5. 單純轉送 Repository method、沒有增加規則或協調價值時，不額外包一層 Service。

### Repository

1. 封裝 SwiftData 或其他 data source。
2. 不處理 toast、alert、navigation 或頁面 loading state。
3. 對上層暴露明確型別與錯誤，不靜默吞掉重要 persistence failure。
4. 新程式碼不得新增對全域 singleton 的依賴。

## 檔案位置

- App 入口：`MoneyMate/MoneyMateApp.swift`。
- Feature 內的 Model、ViewModel 與 View：`MoneyMate/Features/<Feature>/`。
- 跨 feature 共用的 domain/persistence model：`MoneyMate/Models/`。
- 跨功能共用 View：`MoneyMate/Views/Common/`。
- 跨 feature 共用的 Service：`MoneyMate/Services/`。
- Repository protocol：`MoneyMate/Repositories/<Domain>/` 或現有 `Protocol/` 結構。
- Repository 實作：`MoneyMate/Repositories/<Domain>/`。
- Design token：`MoneyMate/DesignSystem/`。
- 通用 extension：`MoneyMate/Extension/`，只有確實跨功能通用時才新增。
- Helper：`MoneyMate/Helpers/`，不得作為無法分類責任的收容區。
- Unit Test：`MoneyMateTests/`，測試替身放在 `MoneyMateTests/Mock/` 或與測試就近的位置。

## 修改範圍

1. 小型 bug fix 延續目標模組可運作的既有模式，採最小修正。
2. 新功能遵循上述依賴方向與注入方式。
3. 若要更換既有 feature 的 MV/MVVM 選擇、將 `ObservableObject` 遷移到 Observation、移除 singleton 或重整資料夾，必須是使用者要求或完成當前任務不可避免的範圍。
