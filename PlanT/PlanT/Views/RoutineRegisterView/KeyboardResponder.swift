//
//  KeyboardResponder.swift
//  PlanT
//
//  Created by 박성관 on 10/21/25.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            
        willShow
            .merge(with: willHide)
            .sink {[ weak self] notification in
                guard let self = self else { return }
                if notification.name == UIResponder.keyboardWillShowNotification,
                   let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = frame.height
                } else {
                    self.keyboardHeight = 0
                }
            }
            .store(in: &cancellableSet)
    }
}
