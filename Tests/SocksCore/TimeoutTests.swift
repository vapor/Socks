//
//  TimeoutTests.swift
//  Socks
//
//  Created by Honza Dvorsky on 6/9/16.
//
//

import Foundation
import XCTest
@testable import SocksCore

class TimeoutTests: XCTestCase {
    
    func time(_ block: () throws -> ()) rethrows -> Double {
        let start = NSDate()
        try block()
        let duration = -start.timeIntervalSinceNow
        return duration
    }
    
    func testReceiveTimeoutSmall() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        read.receivingTimeout = timeval(seconds: 1)
        XCTAssertEqual(read.receivingTimeout, timeval(seconds: 1))
        let duration = time {
            do {
                _ = try read.recv()
                XCTFail()
            } catch {
                guard let err = error as? SocksCore.Error, case .readFailed = err.type else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(err.number, 35)
            }
        }
        XCTAssertEqualWithAccuracy(duration, 1.0, accuracy: 0.1)
    }
    
    func testSendTimeoutSmall() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close(); try! write.close() }
        write.sendingTimeout = timeval(seconds: 1)
        XCTAssertEqual(write.sendingTimeout, timeval(seconds: 1))

        // HELP: how can we test a hanging send?
    }
    
    func testReceiveDeliverAfterHalf() throws {
        let (read, write) = try TCPEstablishedSocket.pipe()
        defer { try! read.close() }
        read.receivingTimeout = timeval(seconds: 2)
        let _ = try Strand {
            sleep(1)
            try! write.send(data: "Hello".toBytes())
            try! write.close()
        }
        let duration = try time {
            let response = try read.recv().toString()
            XCTAssertEqual(response, "Hello")
        }
        XCTAssertEqualWithAccuracy(duration, 1.0, accuracy: 0.1)
    }
}