---
name: write-commit-summary
description: Analyze the current Git working tree and produce a concise Traditional Chinese commit summary using Conventional Commits. Use when the user asks for a commit message, commit summary, commit title/body, Git change summary, or wants current staged or unstaged changes described for a commit.
---

# Write Commit Summary

根據實際 Git 變更撰寫可直接使用的繁體中文 commit summary。保持唯讀，不修改、暫存或提交檔案。

## Workflow

1. 執行 `git status --short`，確認 staged、unstaged、deleted 與 untracked 檔案。
2. 決定摘要範圍：
   - 使用者指定範圍時遵從指定。
   - 有 staged 變更且未指定時，優先摘要 staged 內容，並簡短提醒尚有未納入的變更。
   - 沒有 staged 變更時，摘要目前所有 tracked 變更與相關 untracked 檔案。
3. 先讀取 `git diff --stat`、`git diff --name-status`；摘要 staged 內容時改用 `--cached`。
4. 檢查足夠的實際 diff 與相關新檔案內容，辨識使用者意圖、主要行為變更、測試與文件更新。大型 diff 應按檔案或模組分段讀取，避免只根據檔名猜測。
5. 找出可能不應混入同一個 commit 的內容，例如 `.DS_Store`、憑證、開發團隊 ID、產物檔、個人設定或無關文件。
6. 產生一個最能代表主要意圖的 Conventional Commit 標題，並附上 3 至 8 個重點。

## Output Rules

- 使用繁體中文，技術名稱可保留英文。
- 標題格式為 `<type>(可選 scope): 中文摘要`，控制在約 72 個字元內。
- 依主要意圖選擇 type：
  - `feat`：新增使用者可感知的功能。
  - `fix`：修正錯誤或不正確行為。
  - `refactor`：重整結構但不以新增功能或修錯為主。
  - `test`：主要變更是測試。
  - `docs`：主要變更是文件。
  - `chore`：建置、設定或維護工作。
- 重點描述「改了什麼與帶來什麼結果」，不要逐檔羅列。
- 只描述 diff 中有證據支持的內容；不要宣稱測試已通過，除非本回合確實執行並通過。
- 將 commit message 放在單一程式碼區塊，方便直接複製。
- 若發現可疑、敏感或無關變更，在程式碼區塊後另列簡短提醒，不要把提醒寫進 commit message。
- 若工作樹沒有變更，直接說明沒有可摘要的內容。

## Example

```text
refactor: 改善依賴注入與記帳資料流程

- 移除全域 SwiftData helper，改用建構式依賴注入
- 實作月份範圍查詢與穩定的游標分頁
- 補上載入、失敗、重試與儲存狀態
- 擴充 Repository、UseCase 與錯誤處理測試
```
