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

    private(set) var recordingsMetadata: [String: Recording] = [:]
    
    func save(_ items: [Recording]) {
        let realms = items.map { RecordingRealm(recording: $0) }
        databaseManager.write(realms)
        
        updateMetadata()
    }
    
    func delete(recordingID: String) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        if let recording = all.first(where: { $0.id == recordingID }) {
            databaseManager.delete([recording])
        }
        
        recordingsMetadata.removeValue(forKey: recordingID)
    }
    
    func delete(recordingIDs: [String]) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        let toDelete = all.filter { recordingIDs.contains($0.id) }
        databaseManager.delete(toDelete)
        
        recordingIDs.forEach {
            recordingsMetadata.removeValue(forKey: $0)
        }
    }
    
    func updateMetadata() {
        let realmRecs: Results<RecordingRealm> = databaseManager.read()
        let metas = realmRecs
            .map(\.recordingMetadata)
            .reversed()
        
        recordingsMetadata = Dictionary(
            uniqueKeysWithValues: metas.map { metadata in
                (metadata.id, metadata)
            }
        )
    }
    
    func loadFullRecording(id: String) -> Recording? {
        let results: Results<RecordingRealm> = databaseManager.read()
        guard let realm = results.first(where: { $0.id == id }) else {
            return nil
        }
        
        return realm.recording
    }
}
