# SwiftUI 實作規則

## View 結構

1. `body` 維持 declarative，不放 persistence、商業規則或昂貴資料處理。
2. 畫面包含 header、content、list、footer 等不同區段時，拆成獨立 `View` 型別並傳入最小必要資料。
3. 不以大型 computed `some View` 或 `@ViewBuilder` property 取代真正的 View 拆分；微小且無獨立更新邊界的片段除外。
4. 避免 `AnyView`；優先使用 concrete view type、`@ViewBuilder` 或 enum-driven composition。
5. 不建立只有單一 child、沒有語意或 layout 作用的 `Group`。

## 資料流

1. View-local state 使用 `@State private`。
2. 子 View 只接收實際讀取或轉交的資料，避免為顯示單一欄位而傳入大型 value model。
3. side effect 放在明確 action、`.task` 或隔離良好的 `.onChange`，不得在 `body` 中觸發。
4. `.task(id:)` 的 id 必須代表真正需要重新執行的輸入變化。
5. Navigation、sheet 與 alert 的狀態應具有單一 source of truth。

## List 與 ForEach

1. 使用 model 的穩定 identity。
2. 不使用 array index、offset、臨時 `UUID()` 或會改變的內容欄位作為 identity。
3. 需要 index 時可預先建立穩定的 view data，但 identity 仍以 element id 為準。
4. 不在 `ForEach` 參數內反覆 filter、sort 或建立大型中間陣列；先在上層狀態或 cached value 準備。
5. Row 應維持穩定、單一且可預期的 view 結構，避免每列產生不同數量的頂層 View。
6. 分頁觸發不得只依賴不穩定的「目前陣列最後一筆」比較，需避免重複請求與 stale result。

## API 選擇

1. 新程式碼不引入 soft-deprecated SwiftUI API。
2. 修改既有程式時，不因發現 soft-deprecated API 就擴大重構；只回報與當前修改直接相關的遷移建議。
3. 優先使用 semantic styling，例如 `foregroundStyle`、`containerRelativeFrame` 適用時的現代 API，以及 leading/trailing 對齊。
4. 新 API 必須符合實際 deployment target。

## 畫面狀態

依功能需要檢查 loading、empty、error、content、disabled、selected、retry、長文字、Dynamic Type、Dark Mode 與不同尺寸。不得只完成 happy path。
