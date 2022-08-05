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
    
    //    var recordings: [Recording] {
    //        recordingEntities.map { Recording(from: $0) }
    //    }
    
    //    private var recordingEntities: [RecordingEntity] = []
    //    private let persistenceManager: PersistenceManager
    
    //    init() {
    //        persistenceManager = PersistenceManager()
    //        persistenceManager.loadPersistentStores() { [ weak self ] in
    //            self?.fetchSavedRecordings()
    //        }
    //    }
    
    //    private func fetchSavedRecordings() {
    //        let request = RecordingEntity.fetchRequest()
    //        let sort = NSSortDescriptor(key: "date", ascending: false)
    //        request.sortDescriptors = [sort]
    //
    //        do {
    //            recordingEntities = try persistenceManager.container.viewContext.fetch(request)
    //            print("Got \(recordingEntities.count) recordings")
    //        } catch {
    //            print("Fetch failed")
    //        }
    //    }
    
    //    func save(recording newRecording: Recording) {
    //        let newRecordingEntity = newRecording.entity
    //        if let index = recordingEntities.firstIndex(where: { $0.id == newRecordingEntity.id }) {
    //            recordingEntities[index] = newRecordingEntity
    //        } else {
    //            recordingEntities.insert(newRecordingEntity, at: 0)
    //        }
    //        persistenceManager.saveContext()
    //    }
    //
    //    func delete(recordingID: String) {
    //        recordings.removeAll { recording in
    //            recording.id == recordingID
    //        }
    //    }
}
