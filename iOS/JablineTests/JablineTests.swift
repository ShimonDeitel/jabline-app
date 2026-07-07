import XCTest
@testable import Jabline

final class JablineTests: XCTestCase {
    var store: JablineStore!

    override func setUp() {
        super.setUp()
        store = JablineStore()
    }

    func testSeedDataIsBelowFreeLimit() {
        XCTAssertLessThan(store.vaccines.count, JablineStore.freeTierLimit)
    }

    func testAddIncreasesCount() {
        let before = store.vaccines.count
        let added = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.vaccines.count, before + 1)
    }

    func testAddRespectsFreeLimitWhenNotPro() {
        while store.vaccines.count < JablineStore.freeTierLimit {
            _ = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        }
        let blocked = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        XCTAssertFalse(blocked)
    }

    func testProBypassesFreeLimit() {
        while store.vaccines.count < JablineStore.freeTierLimit {
            _ = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        }
        let allowed = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: true)
        XCTAssertTrue(allowed)
    }

    func testCanAddReflectsLimit() {
        while store.vaccines.count < JablineStore.freeTierLimit {
            _ = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        }
        XCTAssertFalse(store.canAdd(isPro: false))
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testRemoveDecreasesCount() {
        _ = store.add(Vaccine(petName: "P", vaccineName: "V"), isPro: false)
        let before = store.vaccines.count
        store.remove(at: IndexSet(integer: 0))
        XCTAssertEqual(store.vaccines.count, before - 1)
    }

    func testIsAtFreeLimitFalseInitially() {
        XCTAssertFalse(store.isAtFreeLimit)
    }

    func testPersistedStateRoundTrips() {
        let count = store.vaccines.count
        let reloaded = JablineStore()
        XCTAssertEqual(reloaded.vaccines.count, count)
    }
}
