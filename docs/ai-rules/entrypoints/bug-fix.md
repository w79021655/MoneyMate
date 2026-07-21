# Bug Fix 與除錯入口

## 適用情境

Crash、執行期錯誤、畫面狀態異常、SwiftData 資料錯亂、非同步競態、錯誤統計或既有功能 regression。

## 診斷流程

1. 收集完整錯誤、stack trace、重現步驟、資料狀態、裝置／OS 與時序資訊。
2. 檢查出錯位置、直接呼叫端、狀態擁有者與最近相關變更。
3. 建立一至兩個可驗證假設，以 log、測試或最小重現排除。
4. 使用者只要求診斷時，不直接實作修正。
5. 使用者要求修正時，採能處理根因的最小變更，不以大範圍重構取代定位。

## 修正與驗證

1. 可行時先建立 regression test，使問題在修正前可重現。
2. 不用 sleep、強制 unwrap、忽略錯誤或重複刷新掩蓋 race condition。
3. SwiftData 問題需檢查 actor/context、fetch sorting、identifier 與 migration。
4. 金額或月份問題需檢查單位、正負號、Calendar、time zone 與區間邊界。
5. 修正後執行最接近問題路徑的 targeted test 或手動重現步驟。

## 完成回報

1. 根因與判斷依據。
2. 修正範圍與涉及檔案。
3. Regression test 或手動驗證結果。
4. 尚未覆蓋的裝置、OS、資料狀態或其他風險。
