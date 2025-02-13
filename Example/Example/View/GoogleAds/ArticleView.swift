//
//  ArticleView.swift
//  Example
//
//  Created by Thanh Hai Khong on 13/2/25.
//

import ComposableArchitecture
import SwiftUI

struct ArticleView: View {
    @Perception.Bindable var store: StoreOf<Article>
    
    var body: some View {
        Text("Article")
    }
}
