# 功能開發入口

## 適用情境

新增或調整頁面、Feature Model、ViewModel、Service、Repository、SwiftData 行為或完整使用者流程。

## 開始前

1. 依 `docs/ai-rules/task-routing.md` 完成共通與條件式閱讀。
2. 檢查目標功能附近的 View、Feature Model／ViewModel、Service、Repository、domain model 與 tests。
3. 定義資料流、source of truth、錯誤狀態與檔案邊界。
4. 依 `docs/ai-rules/core/architecture.md` 判斷功能使用 MV 或 MVVM，不因命名或 `@Observable` 本身決定。
5. 判斷是否真的需要 Service；只有跨資料源、協調多步驟流程或具可重用業務規則時新增。
6. 判斷是否需要 protocol；需要替換資料來源、測試隔離或跨層 contract 時使用。

## 實作流程

1. 先建立最小且可測試的 domain／data flow，再接 UI。
2. View 保持 declarative，狀態由 Feature Model、ViewModel 或適當 source of truth 驅動。
3. Persistence 透過 Repository，不新增 singleton context 依賴。
4. 補齊 loading、empty、error、success 與 cancellation 等適用狀態。
5. 金額與日期遵循 `docs/ai-rules/core/money-domain.md`。
6. UI 遵循 `docs/ai-rules/ui/swiftui-implementation.md` 與 `docs/ai-rules/ui/design-system-and-accessibility.md`。
7. 依 `docs/ai-rules/quality/testing.md` 補上相稱測試。

## 完成回報

1. 完成的使用者行為。
2. 修改的層級與主要檔案。
3. MV／MVVM 的選擇，以及 Service／protocol 的採用或省略原因。
4. 驗證結果與剩餘風險。
