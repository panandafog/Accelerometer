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
    private var recordings: [String: Recording] = [:]
    
    func save(_ items: [Recording]) {
        let realms = items.map { RecordingRealm(recording: $0) }
        databaseManager.write(realms)
        
        items.forEach {
            recordings.removeValue(forKey: $0.id)
        }
    }
    
    func delete(recordingID: String) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        if let recording = all.first(where: { $0.id == recordingID }) {
            databaseManager.delete([recording])
        }
        
        recordings.removeValue(forKey: recordingID)
    }
    
    func delete(recordingIDs: [String]) {
        let all: [RecordingRealm] = Array(databaseManager.read() as Results<RecordingRealm>)
        let toDelete = all.filter { recordingIDs.contains($0.id) }
        databaseManager.delete(toDelete)
        
        recordingIDs.forEach {
            recordings.removeValue(forKey: $0)
        }
    }
    
    func updateMetadata() {
        let realmRecs: Results<RecordingRealm> = databaseManager.read()
        let metas = realmRecs
            .map(\.recordingMetadata)
            .reversed()
        recordingsMetadata = Array(metas)
    }
    
    func loadFullRecording(id: String) -> Recording? {
        if let cached = recordings[id] {
            return cached
        }
        
        let results: Results<RecordingRealm> = databaseManager.read()
        guard let realm = results.first(where: { $0.id == id }) else {
            return nil
        }
        
        let recording = realm.recording
        recordings[id] = recording
        
        return recording
    }
    
    func clearCache(for id: String) {
        recordings.removeValue(forKey: id)
    }
    
    func clearAllCache() {
        recordings.removeAll()
    }
    
    var cacheSize: Int {
        recordings.count
    }
}
