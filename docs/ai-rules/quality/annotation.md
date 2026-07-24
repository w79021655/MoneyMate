# Swift 註解規則

本文件統一 MoneyMate 的 Swift 註解與 DocC 撰寫方式。註解的目標是保留程式碼無法自行表達的責任、業務規則、限制與設計原因，而不是逐行翻譯實作。

## 語言規範

1. 新增或修改的註解一律使用繁體中文。
2. Swift symbol、Apple API、framework、actor、protocol 與無法合理翻譯的技術名詞保留原文。
3. 不為了統一語言而大範圍翻譯本次任務未涉及的既有註解。
4. 註解引用 symbol 時使用反引號，例如 `ModelContext`、`fetchExpenses(from:)`。

## 核心原則

1. 註解優先回答「為什麼」、「負責什麼」、「有哪些限制」與「違反後會發生什麼」。
2. 命名與型別已完整表達的內容，不再用註解重述。
3. 註解必須和程式碼同步更新；錯誤或過時的註解比沒有註解更危險。
4. 優先改善含糊的命名與結構，不以長篇註解補救難以理解的程式碼。
5. 註解保持精簡；只有 contract、複雜業務規則、非同步時序或重要限制需要詳細說明。
6. 不為了提高註解覆蓋率，在每個 property、initializer、modifier 或直白 helper 上加入噪音。

## DocC 與一般註解的使用時機

### 使用 `///`

以下內容使用 DocC 註解：

1. 對其他型別提供 contract 的 `class`、`struct`、`enum`、`protocol` 與 extension。
2. Feature Model、ViewModel、Service、Repository 與 domain model 等具有架構責任的型別。
3. 對外 API、protocol requirement、業務邏輯方法與不容易從 signature 理解的方法。
4. 具有重要語意的 property，例如金額單位、時間區間、cache、repository 或 persistence dependency。

### 使用 `//`

以下內容使用一般行內註解：

1. 解釋區塊內特定實作選擇或 workaround。
2. 說明 concurrency、SwiftData context、pagination、lifecycle 或 state transition 的時序原因。
3. 標示不能安全刪除、合併或改寫的非顯而易見條件。
4. 補充短期 `TODO` 或已知限制。

不要使用一般行內註解取代應成為 API contract 的 DocC。

## 型別註解

1. 型別宣告前使用 `///`，第一句說明主要責任。
2. 型別位於資料流或架構邊界時，補充它與上、下游的關係。
3. 不寫「這是一個 class／struct／View」等沒有資訊量的描述。
4. 純 private、極小且只服務單一實作細節的輔助型別，若名稱與所在位置已足夠清楚，可以省略。
5. SwiftUI View 的註解描述畫面責任、輸入或互動邊界，不描述 `body` 使用了 `VStack`、`Text` 等字面結構。

```swift
/// 管理首頁的月統計與交易列表狀態。
///
/// 透過 `MonthlyExpenseService` 與 Repository 取得資料，並在 Main Actor 更新畫面狀態。
@MainActor
final class HomeViewModel { }
```

## 方法註解

1. 第一句以動作描述用途，但不要只重複方法名稱。
2. 方法包含業務規則時，說明規則與邊界條件。
3. 多參數、參數具有 domain 語意，或預設值會影響行為時，使用 `- Parameters:`。
4. 回傳值帶有狀態、可選語意、轉換結果或特殊單位時，使用 `- Returns:`。
5. 可能拋出錯誤時，使用 `- Throws:` 說明錯誤條件，不需要列出實際不會拋出的錯誤。
6. 需要呼叫端特別遵守前置條件時，可使用 `- Important:` 或 `- Warning:`。
7. 直白且沒有額外規則的 private helper 可省略註解。

```swift
/// 計算指定月份的收入、支出與餘額。
///
/// 月份邊界依傳入的 calendar 與 time zone 判定。
///
/// - Parameters:
///   - date: 用來決定目標月份的基準日期。
///   - calendar: 計算月份區間時使用的日曆。
/// - Returns: 指定月份的收入、支出與餘額。
func fetchMonthlySummary(
    for date: Date,
    calendar: Calendar
) async -> MonthlySummary
```

## Property、Enum 與 Protocol

1. Property 名稱已能清楚表達用途時，不逐一加入註解。
2. 金額單位、正負號 convention、date boundary、cache lifetime 或 ownership 不明確時，必須註明。
3. `enum` 本身說明管理的狀態或事件；語意直白的 case 不需逐一註解。
4. Case 具有特殊 mapping、fallback、相容性或 side effect 時，補充該 case 的規則。
5. Protocol 註解應描述抽象的責任與 contract，不描述目前唯一實作的細節。
6. Protocol requirement 的錯誤、排序、執行緒或 persistence 語意不明顯時，必須分別註明。

```swift
/// 以最小貨幣單位儲存的交易金額；正值代表收入，負值代表支出。
var amount: Int
```

## SwiftUI 註解

1. 不逐行說明 modifier、layout container 或 SF Symbol。
2. Source of truth、`@State`／`@Binding` ownership、navigation ownership 不明顯時，說明狀態由誰持有及誰可修改。
3. `.task(id:)`、`.onChange` 或 animation 具有特殊觸發條件時，說明選擇該觸發方式的原因。
4. 為避免 view invalidation、維持 stable identity 或保留 row state 而採取的非直觀設計，應說明限制。
5. Accessibility 行為若無法從 standard control 推斷，需註明預期朗讀或互動語意。

## Swift Concurrency 與 SwiftData 註解

1. Actor isolation 無法從宣告直接理解時，說明資料在哪個 actor 擁有與修改。
2. 不得在缺少安全性理由時使用 `nonisolated`、`@unchecked Sendable` 或 `Task.detached`；若經核准使用，必須記錄 invariant。
3. SwiftData fetch 必須說明非顯而易見的 predicate、排序、月份區間與 pagination cursor 語意。
4. Schema migration、relationship、delete rule 或資料相容性 workaround 必須記錄原因與移除條件。
5. 不在註解中聲稱 thread-safe、atomic 或 Sendable，除非程式設計與測試能支持該保證。

## `MARK` 分段

1. 使用 `// MARK: -` 分隔具有明確責任的區段，例如 State、Dependencies、Lifecycle、Actions、Private Helpers。
2. 小型檔案不為了格式一致強制加入 `MARK`。
3. `MARK` 名稱簡短且反映責任，不使用「其他」、「雜項」等含糊名稱。
4. Extension 依 protocol conformance 或明確責任拆分時，可以 `MARK` 標示；不要只為縮短檔案而建立無語意 extension。

## TODO、FIXME 與 Workaround

1. `TODO` 必須描述尚未完成的具體工作，能對應 issue 時附上編號或連結。
2. `FIXME` 僅用於已知錯誤或風險，需說明觸發條件與預期修正方向。
3. Workaround 必須說明原因、適用版本或移除條件，不只寫「暫時處理」。
4. 不留下沒有上下文、無法採取行動或永久存在的 TODO。

```swift
// FIXME: 相同 timestamp 可能造成分頁重複；改用 date 與 persistent ID 的複合 cursor 後移除。
```

## 禁止事項

1. 逐行翻譯程式碼。
2. 描述顯而易見的 getter、setter、initializer 或 layout。
3. 保留已失效、與實作矛盾或被註解掉的舊程式碼。
4. 以註解掩蓋 unsafe cast、錯誤吞噬、race condition 或不清楚的 ownership。
5. 在註解中放入 secret、token、真實交易、個資或 production endpoint。
6. 加入沒有根據的效能、安全性或執行緒保證。
7. 為了補註解而改動本次任務無關的整個檔案。

## 完成檢查

新增或修改 Swift 程式碼後，依本次變更範圍確認：

1. 新增的架構型別是否有責任清楚的 DocC。
2. Public API、protocol requirement 與業務方法是否說明重要 contract。
3. 金額單位、正負號、月份邊界與 persistence 行為是否沒有歧義。
4. 非同步時序、actor isolation、SwiftData context 與 pagination 限制是否在必要處被說明。
5. 註解是否仍與目前實作一致，且沒有重述程式碼。
6. 新增或修改的註解是否使用繁體中文，並保留必要的技術原文。

自查口訣：

> 型別寫責任、方法寫規則、參數寫語意、回傳寫狀態、非同步寫時序、直白程式不硬註解。
