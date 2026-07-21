# Swift Concurrency 與 SwiftData 規則

## Concurrency

1. 優先使用 structured concurrency 與 `async/await`。
2. UI-facing observable model 與 UI state mutation 必須在 `MainActor`。
3. 不使用 `Task.detached` 執行 SwiftData 工作。
4. 不以任意 `Task.sleep` 協調 app 行為、等待資料完成或掩蓋 race condition。
5. cancellation 通常不是錯誤狀態；捕捉錯誤時需保留取消語意。
6. 建立非同步任務時，必須考慮 View 消失、重複觸發與 stale result 覆蓋新狀態。
7. 不將 non-Sendable 物件跨 actor 傳遞，也不使用 `@unchecked Sendable` 略過問題，除非有完整安全性說明與使用者同意。

## SwiftData

1. `ModelContext` 與 SwiftData model instance 不得任意跨 actor boundary 傳遞。
2. SwiftData 存取集中於 repository 或專用 persistence boundary。
3. 新程式碼不得依賴 `modelContextProvider` 這類全域 mutable context；既有依賴只在相關 migration 範圍內處理。
4. 若 persistence 工作需離開 Main Actor，採用清楚隔離的 SwiftData actor 設計，並以 `PersistentIdentifier` 或可傳遞 value 對接，不直接跨 actor 傳 model instance。
5. Fetch 必須具有可預期且穩定的排序；分頁排序欄位可能相同時，需有第二排序鍵。
6. Insert、delete、save 與 migration failure 不得無條件忽略或只用 `print` 處理。
7. Schema 欄位、唯一性、relationship 或 delete rule 變更需評估 migration 與既有資料相容性。
8. Preview 與測試使用獨立的 in-memory container，不得污染正式資料。

## Observation

1. 新建 UI model 優先使用 `@Observable`，並標示 `@MainActor`。
2. 既有 `ObservableObject` 與 `@StateObject` 不因風格偏好而順便遷移。
3. `@State` 一律宣告為 `private`。
4. `@Binding` 僅用於子 View 確實需要修改父層持有狀態的情境。
5. `@Observable` 儲存屬性型別可合理符合 `Equatable` 時，優先提供 conformance，減少相同值造成的無效 invalidation。
