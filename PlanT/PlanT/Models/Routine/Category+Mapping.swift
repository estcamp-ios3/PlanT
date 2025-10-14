//
//  Category+Mapping.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

/// DB DTO -> 앱 모델(Category) 변환 (모델은 고정!)
extension Category {
    init(dto: CategoryRowDTO) {
        self.init(
            id: dto.id,
            slug: dto.slug,
            nameKo: dto.name_ko,
            description: dto.description,
            iconName: dto.icon_name,
            sortOrder: dto.sort_order,
            isActive: true,
        )
    }
}
