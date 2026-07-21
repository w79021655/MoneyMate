# 測試規則

## 測試工具

1. 新增 Unit Test 使用 Swift Testing 的 `@Test` 與 `#expect`。
2. UI Test 延續 XCTest。
3. 測試名稱以行為與預期結果表達；技術 symbol 可保留英文，說明文字使用繁體中文。

## 測試隔離

1. SwiftData 測試使用獨立的 in-memory `ModelContainer`。
2. 每個測試自行建立並注入依賴，不共享 singleton mutable state。
3. Unit Test 不存取 production store、網路、真實時間或使用者資料。
4. 非同步測試使用可觀察的完成條件，不使用任意 sleep 等待。
5. 日期行為注入固定 date、calendar、time zone 或 clock。

## 測試層級

1. ViewModel：測試 loading、empty、error、success、重複請求與取消。
2. UseCase：測試業務規則、邊界、資料整合與 side effect。
3. Repository：測試 insert、fetch、sort、pagination、delete、failure 與 isolation。
4. 記帳 domain：測試收入、支出、餘額、跨月、同時間資料與空資料。
5. Bug fix：可行時加入能先失敗、修正後通過的 regression test。
6. UI behavior 或 navigation 改變時，視風險加入 UI Test 或提供可重現的 smoke test。

## 測試品質

1. 不為讓測試通過而刪除有效 assertion、放寬預期或吞掉錯誤。
2. Mock 與 fake 依賴 protocol，不複製 production business logic。
3. 測試只驗證 public behavior；除非必要，不綁定內部實作細節。
4. 測試失敗時先判斷是否由本次修改造成，既有失敗需明確標示。
5. 無法執行測試時，回報嘗試的指令、阻礙與剩餘風險，不得宣稱通過。
