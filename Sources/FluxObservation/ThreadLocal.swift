//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

struct _ThreadLocal {
    private static let key: pthread_key_t = {
        var key: pthread_key_t = 0
        pthread_key_create(&key, nil)
        return key
    }()

    static var value: UnsafeMutableRawPointer? {
        get { pthread_getspecific(key) }
        set { pthread_setspecific(key, newValue) }
    }
}
