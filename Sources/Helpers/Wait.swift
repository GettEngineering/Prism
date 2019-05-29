//
//  Wait.swift
//  Prism
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation

/// A helper to Wait for a specific asynchronous piece of work to
/// be done and provide a specific result.
///
/// The caller should invoke the `done()` closure argument with the
/// result when the asynchronous work is done.
class WaitForResult<Result> {
    private let semaphore: DispatchSemaphore
    private var _result: Result?

    var result: Result {
        set { self._result = newValue }
        get {
            /// This can't fail, since if a result isn't returned,
            /// the entire process is frozen until `done(Result)`
            /// is invoked
            return _result!
        }
    }

    init(_ work: @escaping (@escaping (Result) -> Void) -> Void) {
        self.semaphore = DispatchSemaphore(value: 0)

        work { [weak self] result in
            self?.result = result
            self?.semaphore.signal()
        }

        semaphore.wait()
    }
}
