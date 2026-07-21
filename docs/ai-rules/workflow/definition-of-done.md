# 完成定義

## 完成前檢查

1. 已依 `docs/ai-rules/task-routing.md` 閱讀必要規則。
2. 實際修改符合使用者要求，沒有無關變更。
3. 架構、檔案位置、資料流與 Design System 符合對應規則。
4. 沒有新增未確認的 dependency、global state、secret、個資或 debug code。
5. 行為改變已依 `docs/ai-rules/workflow/verification.md` 執行相稱驗證。
6. UI 改變已檢查必要狀態、Dynamic Type、Dark Mode 與 Accessibility。
7. 已檢查最終 diff、未追蹤檔案與文件連結。
8. 新增或修改的說明本文、Markdown、註解與完成回報使用繁體中文，例外遵循 `CLAUDE.md`。

## 完成回報

先講成果，再以繁體中文簡要說明：

1. 修改的主要檔案與行為。
2. 執行的驗證與結果。
3. 未執行的驗證及原因。
4. 剩餘風險、重要假設或後續建議。

## 不可宣稱完成

1. 核心需求仍未實作。
2. 必要驗證未執行且沒有合理原因。
3. 測試失敗但尚未定位與本次修改的關係。
4. 需要使用者決定的 contract、schema、dependency 或敏感設定尚未確認。
5. 修改可能覆蓋使用者既有變更而尚未解決。
