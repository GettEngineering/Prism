//
//  Utils.swift
//  Prism
//
//  Created by Shai Mishali on 17/04/2020.
//  Copyright © 2019 Gett. All rights reserved.
//

#if os(Linux)
import Glibc
let os_exit: (Int32) -> Never = Glibc.exit
#else
import Darwin
let os_exit: (Int32) -> Never = Darwin.exit
#endif

func terminate(with message: String?) -> Never {
    if let message = message {
        print(message)
    }

    os_exit(1)
}
