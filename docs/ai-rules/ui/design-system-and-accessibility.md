# Design System、在地化與 Accessibility 規則

## Design System

1. 優先使用 `MoneyMate/DesignSystem/` 既有的 `Spacing`、`Radius`、Color 與 Font semantic token。
2. 不在已有 semantic token 時新增 hard-coded color、font、spacing 或 corner radius。
3. 新 token 以用途命名，不以視覺值命名，例如使用 `screenBackground`，避免 `grayF5`。
4. 只有跨兩個以上功能共用，或產品明確要求為共用元件時，才放入 `Views/Common/`。
5. 共用元件必須定義必要狀態，例如 enabled、disabled、loading、selected 與 error。

## 在地化

1. App 內使用者可見文字必須可在地化，不新增無法抽離的硬編碼文案。
2. SwiftUI View declaration 可使用支援 localization 的字串形式；在 View 之外保存可見文字時，優先使用 `LocalizedStringResource`。
3. 日期、數字、金額與清單使用 locale-aware format style。
4. 使用 `.leading`、`.trailing`，不以 `.left`、`.right` 固定方向。
5. 需要轉換大小寫時在 runtime 處理，避免將翻譯 key 本身先轉換。
6. 本 repository 的 AI 文件使用繁體中文，不代表 App 只支援繁體中文；UI 語系仍依產品需求。

## Accessibility

1. Icon-only control 必須提供 accessibility label。
2. 不以顏色作為收支、錯誤、選取或狀態的唯一辨識方式。
3. 互動元件需有合理 touch target，並支援 VoiceOver 操作順序。
4. 不以固定 frame 破壞 Dynamic Type；長文字需檢查截斷與 layout。
5. 裝飾性圖片應避免被 VoiceOver 重複朗讀。
6. 自訂 gesture 不得破壞 Button、Toggle 等標準 control 的語意與鍵盤／輔助操作。
