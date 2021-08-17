//  Created by Axel Ancona Esselmann on 8/17/21.
//

import Foundation
import Combine

class Socket: NSObject {

    enum Event {
        case openCompleted
        case data(Data)
        case bytesWritten(Int)
        case hasSpaceAvailable
        case error(Error)
        case endEncountered
        case other(Stream.Event)
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

    var event: AnyPublisher<Event, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private let eventSubject = PassthroughSubject<Event, Never>()

    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    func open(url: URL, socket: UInt32) {
        inputStream?.close()
        outputStream?.close()
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
        inputStream?.delegate = self
        let outputStream: OutputStream? = writeStream?.takeRetainedValue()
        inputStream?.delegate = self

        inputStream?.schedule(in: .current, forMode: .common)
        outputStream?.schedule(in: .current, forMode: .common)

        inputStream?.open()
        outputStream?.open()

        self.inputStream = inputStream
        self.outputStream = outputStream
    }

    func close() {
        inputStream?.close()
        outputStream?.close()
    }

    func write(data: Data) {
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
            eventSubject.send(.bytesWritten(bytesWritten))
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
        case .endEncountered:
            eventSubject.send(.endEncountered)
        case .errorOccurred:
            if let error = aStream.streamError {
                eventSubject.send(.error(error))
            }
        case .hasSpaceAvailable:
            eventSubject.send(.hasSpaceAvailable)
        default:
            eventSubject.send(.other(eventCode))
        }
    }
}
