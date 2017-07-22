//
//  BundleExtensions.swift
//  Pods
//
//  Created by Administrator on 26.06.17.
//
//

import Foundation

extension Bundle {

    static func libraryBundle() -> Bundle {
        let bundle = Bundle(for: Ronni.self)
        return bundle
    }
}
