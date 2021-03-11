//
//  HowToSnapshotCellTests.swift
//  HowToSnapshotCellTests
//
//  Created by Paul Lee on 2021/3/11.
//

import XCTest
@testable import HowToSnapshotCell

class MySnapShotTests: XCTestCase {
    func test__snapShot() throws {
        let window = UIWindow(frame: .zero)
    
        let sut = ViewController()
        
        window.rootViewController = sut
        
        window.isHidden = false
        
        window.makeKeyAndVisible()
        
        sut.loadViewIfNeeded() // simulate view did load
        
        //sut.tableView.reloadData() // simulate data source get called
        
        RunLoop.main.run(until: Date())
        
        sut.switchBtn.setOn(true, animated: false) //simulate user toggle a `UISwitch` instance which is a subview of sut.view as ON
        
        let cell = try XCTUnwrap(sut.tableView
                                    .cellForRow(at: IndexPath(row: 0, section: 0)))
        
        let switchCell = try XCTUnwrap(cell as? SwitchCell)
        
        //switchCell.switchBtn.setOn(true, animated: false)
        switchCell.switchBtn.isOn = true
        
        RunLoop.main.run(until: Date())
        
        print("!!!! cell in test case: \(cell)")
        
        XCTAssertTrue(switchCell.switchBtn.isOn)
        
        // only the first `UISwitch` instance is ON, but I expect both of them is ON
        recordSnapShot(
            sut.snapshot(for: .iPhone8(style: .light)),
            named: "switch"
        )
        
    }
}

extension XCTestCase {
    
    func assertSnapshot(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
            return
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func recordSnapShot(_ snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
    
}

extension UIViewController {
    @available(iOS 12.0, *)
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    init(size: CGSize = .zero,
         safeAreaInsets: UIEdgeInsets = .zero,
         layoutMargins: UIEdgeInsets = .zero,
         traitCollection: UITraitCollection = UITraitCollection(traitsFrom: [])
    ) {
        self.size = size
        self.safeAreaInsets = safeAreaInsets
        self.layoutMargins = layoutMargins
        self.traitCollection = traitCollection
    }
    
    @available(iOS 12.0, *)
    static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(traitsFrom: [
                .init(forceTouchCapability: .available),
                .init(layoutDirection: .leftToRight),
                .init(preferredContentSizeCategory: .medium),
                .init(userInterfaceIdiom: .phone),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(displayScale: 2),
                .init(displayGamut: .P3),
                .init(userInterfaceStyle: style)
            ]))
    }
}

@available(iOS 12.0, *)
final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
