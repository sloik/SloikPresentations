
/*:

 Hack stolen from:
 https://github.com/pointfreeco/episode-code-samples/blob/main/0240-reliably-testing-async-pt3/ReliablyTestingAsync/ReliablyTestingAsync/ConcurrencyExtras.swift

 "swift_task_enqueueGlobal_hook" is referenced in apple code here:
 https://github.com/search?q=repo%3Aapple/swift%20swift_task_enqueueGlobal_hook&type=code

 # How it works

 Gets a reference to not exposed C++ symbols that is a hook used by swift concurrency
 to enqueue jobs. Thru this magic we can now control how those are enqueued.

 To run everything on a serial global executor use this snippet:
 ```
 swift_task_enqueueGlobal_hook = { job, _ in
      MainActor.shared.enqueue(job)
 }
 ```

 */

import Darwin
import Foundation

public typealias Original = @convention(thin) (UnownedJob) -> Void
public typealias Hook = @convention(thin) (UnownedJob, Original) -> Void

public var swift_task_enqueueGlobal_hook: Hook? {
  get { _swift_task_enqueueGlobal_hook.pointee }
  set { _swift_task_enqueueGlobal_hook.pointee = newValue }
}

private let _swift_task_enqueueGlobal_hook: UnsafeMutablePointer<Hook?> =
  dlsym(dlopen(nil, RTLD_LAZY), "swift_task_enqueueGlobal_hook")
    .assumingMemoryBound(to: Hook?.self)
