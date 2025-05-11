//
//  VerticalSpacer.swift
//  MoneyMate
//
//  Created by 吳駿 on 2025/5/4.
//

import SwiftUI

struct VerticalSpacer: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Spacer()
            .frame(width: width, height: height)
    }
}
