//
//  CMSKit.swift
//  App
//
//  Created by Jérôme Danthinne on 05/12/2019.
//

import Leaf

extension LeafTagConfig {
    public mutating func useCMSKitTags() {
        use(InputFieldTag(), as: "inputField")
        use(SelectFieldTag(), as: "selectField")
        use(FormTag(), as: "form")
    }
}
