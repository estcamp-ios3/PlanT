//
//  UserAuthModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine

final class UserAuthModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
}

