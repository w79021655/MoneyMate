# 記帳領域規則

## 金額

1. 金額不得使用 `Double` 或 `Float`。
2. 延續現有 `Int` 金額模型前，先確認單位是元或最小貨幣單位，不得自行推測。
3. 若支援多幣別或小數貨幣，需明確定義 currency code、scale 與 rounding policy，再評估 `Decimal` 或最小貨幣單位。
4. 收入與支出的正負號 convention 必須保持一致；轉換位置集中於 domain 或 UseCase，不散落在 View。
5. 格式化使用 locale-aware `FormatStyle`，不以字串串接手動加入貨幣符號與千分位。
6. 加總、餘額、分類統計與輸入驗證不得放在 SwiftUI View。

## 日期與月份

1. 月份區間使用 `Calendar` 計算，不使用固定秒數推算月初、月底或下一個月。
2. 月統計必須明確考慮 calendar、time zone 與區間的開閉邊界。
3. 顯示日期使用 locale-aware format style；只有 persistence 或明確 protocol 才固定 date format。
4. 分頁以日期排序時，需處理相同 timestamp，避免漏資料、重複資料或無限載入。
5. 測試必須注入固定日期或 clock，不直接依賴執行當下的 `Date()`。

## Expense Model

1. Persistence model、transport model 與 UI display model 的責任不同；當單一型別開始同時承擔多種責任時，需評估轉換邊界。
2. Domain model 不應直接持有純 UI 表現物件，例如 `Color`；既有耦合不在無關任務中擴大。
3. 刪除與更新以穩定 identifier 為基礎，不依賴陣列 index。
4. 所有統計需涵蓋空資料、只有收入、只有支出、跨月與邊界日期。
