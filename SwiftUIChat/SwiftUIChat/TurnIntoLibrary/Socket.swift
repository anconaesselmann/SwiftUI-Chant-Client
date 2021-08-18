//  Created by Axel Ancona Esselmann on 8/17/21.
//

import Foundation
import Combine

class Socket: NSObject {

    enum Event {
        case data(Data)
        case bytesWritten(Int)
        case error(Error)
    }

    enum Status {
        case notInitialized
        case connected
        case disconnected
        case notConnectedWithError(Error)
    }

    enum SocketError: Error {
        case invalidDataReceived
        case couldNotWriteData
        case notConnected
    }

    private let maxReadLength: Int

    init(maxReadLength: Int = 4096) {
        self.maxReadLength = maxReadLength
    }

    private let eventSubject = PassthroughSubject<Event, Never>()
    private let statusSubject = CurrentValueSubject<Status, Never>(.notInitialized)

    var status: AnyPublisher<Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    var event: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var inputStream: InputStream? {
        didSet {
            inputStream?.delegate = self
        }
    }
    private var outputStream: OutputStream? {
        didSet {
            outputStream?.delegate = self
        }
    }

    var socketAccesQueue = DispatchQueue.global()

    func open(url: URL, socket: UInt32) {
        close()
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            url.absoluteString as CFString,
            socket,
            &readStream,
            &writeStream
        )
        let inputStream: InputStream? = readStream?.takeRetainedValue()
        let outputStream: OutputStream? = writeStream?.takeRetainedValue()

        self.inputStream = inputStream
        self.outputStream = outputStream

        inputStream?.schedule(in: .current, forMode: .common)
        outputStream?.schedule(in: .current, forMode: .common)

        inputStream?.open()
        outputStream?.open()
        if let error = inputStream?.streamError {
            statusSubject.send(.notConnectedWithError(error))
        } else {
            statusSubject.send(.connected)
        }
    }

    func close() {
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
        statusSubject.send(.disconnected)
    }

    func write(data: Data, onSuccess: (() -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) {
        guard let outputStream = outputStream else {
            eventSubject.send(.error(SocketError.notConnected))
            return
        }
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                eventSubject.send(.error(SocketError.couldNotWriteData))
                return
            }
            let bytesWritten = outputStream.write(pointer, maxLength: data.count)
            if bytesWritten > 0 {
                eventSubject.send(.bytesWritten(bytesWritten))
                onSuccess?()
            } else {
                let error = outputStream.streamError ?? SocketError.couldNotWriteData
                eventSubject.send(.error(error))
                onFailure?(error)
            }
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

        while stream.hasBytesAvailable {
            guard let numberOfBytesRead = inputStream?.read(buffer, maxLength: maxReadLength) else {
                continue
            }

            if numberOfBytesRead < 0, let error = stream.streamError {
                eventSubject.send(.error(error))
                break
            }
            guard
                let string = String(
                    bytesNoCopy: buffer,
                    length: numberOfBytesRead,
                    encoding: .utf8,
                    freeWhenDone: true
                ),
                let data = string.data(using: .utf8)
            else {
                eventSubject.send(.error(SocketError.invalidDataReceived))
                continue
            }
            eventSubject.send(.data(data))
        }
    }
}

extension Socket: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                readAvailableBytes(stream: inputStream)
            }
        case .errorOccurred:
            if let error = aStream.streamError {
                eventSubject.send(.error(error))
                statusSubject.send(.notConnectedWithError(error))
            }
        default: ()
        }
    }
}
