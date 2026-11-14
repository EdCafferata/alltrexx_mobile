import XCTest
@testable import AlltrexxMobile

/// Unit-tests voor `TrackerType`. De rauwe waarden moeten exact de set zijn die
/// de webkaart (alltrexx.live) kent — als die uit elkaar lopen, stuurt de app een
/// type dat het platform niet herkent. Deze test bewaakt dat contract.
final class TrackerTypeTests: XCTestCase {

    func testRawValuesMatchWebMap() {
        let expected: Set<String> = ["PERSON", "BOAT", "BIKE", "CAR", "TRAIN", "PLANE"]
        let actual = Set(TrackerType.allCases.map(\.rawValue))
        XCTAssertEqual(actual, expected, "Tracker-typen lopen uit de pas met de webkaart")
    }

    func testEveryCaseHasLabelAndEmoji() {
        for type in TrackerType.allCases {
            XCTAssertFalse(type.label.trimmingCharacters(in: .whitespaces).isEmpty,
                           "\(type) mist een label")
            XCTAssertFalse(type.emoji.trimmingCharacters(in: .whitespaces).isEmpty,
                           "\(type) mist een emoji")
        }
    }

    func testLabelsAreUnique() {
        let labels = TrackerType.allCases.map(\.label)
        XCTAssertEqual(labels.count, Set(labels).count, "Labels moeten uniek zijn")
    }

    func testRoundTripFromRawValue() {
        for type in TrackerType.allCases {
            XCTAssertEqual(TrackerType(rawValue: type.rawValue), type)
        }
    }
}
