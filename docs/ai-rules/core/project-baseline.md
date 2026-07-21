# 專案基線

## 技術環境

- App：MoneyMate，iOS 記帳 App。
- UI：SwiftUI。
- Persistence：SwiftData。
- Xcode project：`MoneyMate.xcodeproj`。
- App scheme：`MoneyMate`。
- Unit test scheme：`MoneyMateTests`。
- UI test target：`MoneyMateUITests`。
- Swift language mode：目前 project 設定為 Swift 5。
- Unit Test：Swift Testing。
- UI Test：XCTest。
- 第三方 dependency：目前未發現 Package.swift、CocoaPods 或其他外部 dependency 管理檔案。

## Deployment Target

`project.pbxproj` 目前同時存在 iOS 17.0 與 18.1 設定。任何程式碼都必須以目標 target 的實際 build setting 為準，不得自行假設全專案已統一。

1. 未經使用者要求，不修改 deployment target。
2. 使用新 API 前，先確認受影響 target 的 availability。
3. 若必須支援較低版本，使用 `if #available` 或選擇相容 API。
4. 若任務需要統一 deployment target，必須將其視為 project setting 變更並單獨驗證。

## Project 設定

1. 不手動大範圍重排 `project.pbxproj`。
2. 新增 Swift 檔案後，確認 target membership 與 Xcode file reference。
3. 未經同意，不修改 signing、team、bundle identifier、capability、entitlement 或 build configuration。
4. 未經同意，不新增或升級 production dependency。
5. 不提交 DerivedData、使用者專屬 Xcode 設定、暫存檔或 `.DS_Store`。
