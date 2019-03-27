//
//  Storyboard.swift
//  Prism
//
//  Created by Shai Mishali on 3/27/19.
//  Copyright © 2019 Gett. All rights reserved.
//

import PrismCore
import Foundation

enum ZeplinProject: String {
    case iOS = "5c4cafab1a14267a73a8d336"
    case android = "5c51587a50a594420cdf3dca"

    var styleguide: StyleguideFileProviding {
        switch self {
        case .iOS:
            return IOSStyleguideFileProvider()
        case .android:
            return AndroidStyleguideFileProvider()
        }
    }
}

guard let jwtToken = ProcessInfo.processInfo.environment["ZEPLIN_TOKEN"] as? String else {
    print("[CRITICAL] Missing ZEPLIN_TOKEN")
    exit(1)
}

let prism = Prism(jwtToken: jwtToken)
let sema = DispatchSemaphore(value: 0)

prism.getProject(id: ZeplinProject.iOS.rawValue) { result in
    do {
        let project = try result.get()

        let colors = project.generateColorsFile(from: ZeplinProject.iOS.styleguide)
        let styles = project.generateTextStyleFile(from: ZeplinProject.iOS.styleguide)
        print(styles)
        print("-----")
//        print(project.generateTextStyleFile(from: ZeplinProject.android.styleguide))
        sema.signal()
    } catch let err {
        print("Failed getting project: \(err)")
        exit(1)
    }
}

sema.wait()
