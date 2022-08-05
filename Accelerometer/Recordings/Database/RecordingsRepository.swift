//
//  RecordingsRepository.swift
//  Accelerometer
//
//  Created by Andrey on 29.07.2022.
//

import RealmSwift

class RecordingsRepository: ObservableObject {
    
    private let databaseManager = DatabaseManagerImpl(configuration: .defaultConfiguration)
    
    var recordings: [Recording] {
        let realmRecordings: Results<RecordingRealm> = databaseManager.read()
        return Array(realmRecordings).map { $0.recording }
    }
    
    func save(_ recordings: [Recording]) {
        print("save \(String(recordings[0].entries.count))")
        databaseManager.write(
            recordings.map { RecordingRealm(recording: $0) }
        )
    }
    
    func delete(recordings: [Recording]) {
        databaseManager.delete(recordings.map({ RecordingRealm(recording: $0) }))
    }
    
    func delete(recordingID: String) {
        let recordings: [RecordingRealm] = Array(databaseManager.read())
        guard let recording = recordings.first(where: { $0.id == recordingID }) else {
            return
        }
        databaseManager.delete([recording])
    }
}
