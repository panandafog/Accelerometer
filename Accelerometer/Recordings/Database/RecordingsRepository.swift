//
//  RecordingsRepository.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import RealmSwift

actor RecordingsRepository {
    
    private let databaseManager = DatabaseManagerImpl(
        configuration: .defaultConfiguration
    )

    private(set) var recordingsMetadata: [Recording] = []

    func save(_ items: [Recording]) {
        let realms = items.map { RecordingRealm(recording: $0) }
        databaseManager.write(realms)
    }
    
    func delete(recordingID: String) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        if let recording = all.first(where: { $0.id == recordingID }) {
            databaseManager.delete([recording])
        }
    }
    
    func delete(recordingIDs: [String]) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        let toDelete = all.filter { recordingIDs.contains($0.id) }
        databaseManager.delete(toDelete)
    }
    
    func updateMetadata() {
        let realmRecs: Results<RecordingRealm> = databaseManager.read()
        let metas = realmRecs
            .map(\.recordingMetadata)
            .reversed()
        recordingsMetadata = Array(metas)
    }
}
