//
//  VerticalSpacer.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

/// 以明確寬高建立固定空白區域的版面輔助 View。
struct VerticalSpacer: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}
