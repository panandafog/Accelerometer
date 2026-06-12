//
//  PhoneRecordingTransferReceiver.swift
//  Accelerometer
//
//  Created by OpenAI on 07.06.2026.
//

import Foundation
import WatchConnectivity

final class PhoneRecordingTransferReceiver: NSObject, WCSessionDelegate, @unchecked Sendable {
    var onRecordingReceived: (@Sendable (Data) -> Void)?

    private let session: WCSession?

    override init() {
        if WCSession.isSupported() {
            session = .default
        } else {
            session = nil
        }

        super.init()
        session?.delegate = self
    }

    func activate() {
        session?.activate()
    }

    func acknowledge(recordingID: String) {
        session?.transferUserInfo([
            TransferKey.importedRecordingID: recordingID
        ])
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) { }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let data = try? Data(contentsOf: file.fileURL) else {
            return
        }

        onRecordingReceived?(data)
    }
}
