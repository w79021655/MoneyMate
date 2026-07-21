# 安全、隱私與 Secrets 規則

1. 不讀取、輸出、提交或複製密碼、token、API key、憑證、provisioning profile 內容或其他 secret。
2. 不將真實使用者的交易、姓名、帳號、裝置識別資訊或其他個資放入 source、fixture、log、截圖或測試。
3. Mock data 必須是明確虛構且不具識別性的資料。
4. 金額、交易內容、persistent identifier 與完整 model 不應以 production log 輸出。
5. Debug `print`、暫時測試入口與 mock 注入不得遺留在 production path。
6. 未經使用者同意，不修改 entitlement、capability、signing、privacy manifest 或權限用途說明。
7. 若新增系統權限、analytics、tracking、外部服務或資料匯出，必須先說明資料流、使用目的與隱私影響並取得同意。
8. 刪除、批次更新或 migration 等破壞性資料操作必須有明確 scope、錯誤處理與必要的使用者確認。
