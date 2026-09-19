import Combine
import XCTest
@testable import Acc_elerometer

final class ObservableAxesTests: XCTestCase {
    func testObjectWillChange() throws {
        let observableAxes = ObservableAxes(axes: TriangleAxes.zero)
        var updateCount = 0
        let subscription = observableAxes.objectWillChange.sink { _ in
            updateCount += 1
        }

        withExtendedLifetime(subscription) {
            var axes = TriangleAxes.zero
            axes.set(values: [.x: 0.5, .y: 0.5, .z: 0.5])
            observableAxes.axes = axes
            axes.set(values: [.x: 0.4, .y: 0.4, .z: 0.4])
            observableAxes.axes = axes
        }

        XCTAssertEqual(updateCount, 2)
        let axes = try XCTUnwrap(observableAxes.axes as? TriangleAxes)
        XCTAssertEqual(axes.values[.x]?.value, 0.4)
        XCTAssertEqual(axes.values[.y]?.value, 0.4)
        XCTAssertEqual(axes.values[.z]?.value, 0.4)
        XCTAssertEqual(axes.magnitude.value, sqrt(0.48), accuracy: 0.000001)
    }
}
