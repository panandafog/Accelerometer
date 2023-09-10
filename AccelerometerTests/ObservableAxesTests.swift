//
//  ObservableAxesTests.swift
//  AccelerometerTests
//
//  Created by Andrey on 10.09.2023.
//

import Combine
import XCTest
@testable import Acc_elerometer

class ObservableAxesTests: XCTestCase {
    
    var observableAxes: ObservableAxes<TriangleAxes>!
    @objc dynamic var subscriptionUpdateCounter = 0
    
    let axesZero = TriangleAxes.zero
    let axes1 = TriangleAxes(
        axes: [
            .x: .init(type_: .x, value: 1.0),
            .y: .init(type_: .y, value: 1.0),
            .z: .init(type_: .z, value: 1.0)
        ],
        displayableAbsMax: 1.0,
        vector: .init(type_: .vector, value: 1.0)
    )

    override func setUpWithError() throws {
        observableAxes = .init(axes: axesZero)
    }

    override func tearDownWithError() throws {
        observableAxes = nil
    }

    func testObjectWillChange() throws {
        let axesUpdateExpectation = expectation(that: \.subscriptionUpdateCounter, on: self, willEqual: 2)
        let accelerationSubscription = observableAxes!.objectWillChange.sink { [weak self] _ in
            self?.subscriptionUpdateCounter += 1
        }
        observableAxes!.properties.set(values: [
            .x: 0.5, .y: 0.5, .z: 0.5
        ])
        observableAxes!.properties.set(values: [
            .x: 0.4, .y: 0.4, .z: 0.4
        ])
        wait(for: [axesUpdateExpectation], timeout: 2)
    }
}
