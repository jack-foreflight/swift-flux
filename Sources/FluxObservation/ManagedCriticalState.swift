//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

// MODIFIED: Updated _ManagedCriticalState to use OSAllocatedUnfairLock instead of
// custom ManagedBuffer implementation. This simplifies the locking mechanism by
// leveraging the Synchronization framework while maintaining the same API and
// thread-safety guarantees.

import os

struct _ManagedCriticalState<State> {
    final class LockedBuffer {
        let lock: OSAllocatedUnfairLock<State>

        init(_ initial: State) {
            self.lock = OSAllocatedUnfairLock(uncheckedState: initial)
        }
    }

    private let buffer: LockedBuffer

    init(_ initial: State) {
        buffer = LockedBuffer(initial)
    }

    func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        try buffer.lock.withLockUnchecked {
            try critical(&$0)
        }
    }
}

extension _ManagedCriticalState.LockedBuffer: Sendable where State: Sendable {}

extension _ManagedCriticalState: Sendable where State: Sendable {}

extension _ManagedCriticalState: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(buffer)
    }
}
