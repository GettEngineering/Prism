//
//  Wait.swift
//  PrismCore
//
//  Created by Shai Mishali on 23/05/2019.
//

import Foundation

/// A helper to Wait for a specific asynchronous piece of work to
/// be done and provider a specific result.
///
/// The caller should invoke the `done()` closure argument with the
/// result when the asynchronous work is done.
class WaitForResult<Result> {
    private let semaphore: DispatchSemaphore
    private var _result: Result?

    var result: Result {
        set { self._result = newValue }
        get {
            guard let result = _result else {
                preconditionFailure("Result is nil!")
            }

            return result
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
