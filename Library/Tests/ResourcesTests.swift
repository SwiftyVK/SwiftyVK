import Foundation
import XCTest
@testable import SwiftyVK

#if os(iOS)
import UIKit
#endif

final class ResourcesTests: XCTestCase {

    func test_suffixForPlatform() {
        // When
        let path = Resources.withSuffix("test")
        // Then
        #if os(macOS)
            XCTAssertEqual(path, "test_macOS")
        #elseif os(iOS)
            XCTAssertEqual(path, "test_iOS")
        #elseif os(tvOS)
            XCTAssertEqual(path, "test_tvOS")
        #elseif os(watchOS)
            XCTAssertEqual(path, "test_watchOS")
        #endif
    }

    #if os(iOS)
    func test_extendedInsetsButton_containsPointOutsideBounds() {
        // Given
        let button = ExtendedInsetsButtonIOS(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        button.extendedInsets = 50
        // When
        let result = button.point(inside: CGPoint(x: -8, y: -8), with: nil)
        // Then
        XCTAssertTrue(result)
    }

    func test_extendedInsetsButton_doesNotContainPointOutsideBounds_whenInsetsAreZero() {
        // Given
        let button = ExtendedInsetsButtonIOS(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        // When
        let result = button.point(inside: CGPoint(x: -8, y: -8), with: nil)
        // Then
        XCTAssertFalse(result)
    }

    func test_captchaStoryboard_configuresExtendedInsetsButton() {
        // Given
        let storyboard = UIStoryboard(name: Resources.withSuffix("Storyboard"), bundle: Resources.bundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "Captcha")
        controller.loadViewIfNeeded()
        // When
        let button = buttons(in: controller.view).first as? ExtendedInsetsButtonIOS
        // Then
        XCTAssertEqual(button?.extendedInsets, 50)
    }

    private func buttons(in view: UIView) -> [UIButton] {
        let button = (view as? UIButton).map { [$0] } ?? []
        return button + view.subviews.flatMap(buttons(in:))
    }
    #endif
}
