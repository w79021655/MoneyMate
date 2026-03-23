//
//  View+Extension.swift
//  MoneyMate
//
//  Created by 吳駿 on 2026/1/12.
//

import SwiftUI

extension View {

    func cardStyle() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.Shadow.card, radius: 4, x: 0, y: 2)
    }
}
