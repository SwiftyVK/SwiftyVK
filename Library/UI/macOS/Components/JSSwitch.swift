#if os(macOS)
//
//  JSSwitch.swift
//  JSSwitch
//
//  Created by Julien Sagot on 29/05/16.
//  Copyright © 2016 Julien Sagot. All rights reserved.
//

import AppKit

public class JSSwitch: NSControl {
	// MARK: - Properties
	private var pressed = false
	private let backgroundLayer = CALayer()
	private let knobContainer = CALayer()
	private let knobLayer = CALayer()
	private let knobShadows = (smallStroke: CALayer(), smallShadow: CALayer(), mediumShadow: CALayer(), bigShadow: CALayer())

	// MARK: Computed
	public override var wantsUpdateLayer: Bool { return true }
	public override var intrinsicContentSize: NSSize {
		return CGSize(width: 52, height: 32)
	}

	private var scaleFactor: CGFloat {
		return ceil(frame.size.height / 62) // Hardcoded base height
	}

    public var tintColor = NSColor(calibratedRed: 0.314, green: 0.448, blue: 0.6, alpha: 1) {
		didSet { needsDisplay = true }
	}
	public var on = false {
		didSet { needsDisplay = true }
	}

	// MARK: - Initializers
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupLayers()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setupLayers()
	}

	// MARK: - Layers Setup
	private func setupLayers() {
		wantsLayer = true
		layer?.masksToBounds = false
		layerContentsRedrawPolicy = .onSetNeedsDisplay

		// Background
		setupBackgroundLayer()
		layer?.addSublayer(backgroundLayer)

		// Knob
		setupKnobLayers()
		layer?.addSublayer(knobContainer)
	}

	// MARK: Background Layer
	private func setupBackgroundLayer() {
		backgroundLayer.frame = bounds
		backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
	}

	// MARK: Knob
	private func setupKnobLayers() {
		setupKnobContainerLayer()
		setupKnobLayer()
		setupKnobLayerShadows()
		knobContainer.addSublayer(knobLayer)
		knobContainer.insertSublayer(knobShadows.smallStroke, below: knobLayer)
		knobContainer.insertSublayer(knobShadows.smallShadow, below: knobShadows.smallStroke)
		knobContainer.insertSublayer(knobShadows.mediumShadow, below: knobShadows.smallShadow)
		knobContainer.insertSublayer(knobShadows.bigShadow, below: knobShadows.mediumShadow)
	}

	private func setupKnobContainerLayer() {
		knobContainer.frame = knobFrameForState(on: false, pressed: false)
	}

	private func setupKnobLayer() {
		knobLayer.autoresizingMask = [.layerWidthSizable]
		knobLayer.backgroundColor = NSColor.white.cgColor
		knobLayer.frame = knobContainer.bounds
		knobLayer.cornerRadius = ceil(knobContainer.bounds.height / 2)
	}

	private func setupKnobLayerShadows() {
		let effectScale = scaleFactor
		// Small Stroke
		let smallStroke = knobShadows.smallStroke
		smallStroke.frame = knobLayer.frame.insetBy(dx: -1, dy: -1)
		smallStroke.autoresizingMask = [.layerWidthSizable]
		smallStroke.backgroundColor = NSColor.black.withAlphaComponent(0.06).cgColor
		smallStroke.cornerRadius = ceil(smallStroke.bounds.height / 2)

		let smallShadow = knobShadows.smallShadow
		smallShadow.frame = knobLayer.frame.insetBy(dx: 2, dy: 2)
		smallShadow.autoresizingMask = [.layerWidthSizable]
		smallShadow.cornerRadius = ceil(smallShadow.bounds.height / 2)
		smallShadow.backgroundColor = NSColor.red.cgColor
		smallShadow.shadowColor = NSColor.black.cgColor
		smallShadow.shadowOffset = CGSize(width: 0, height: -3 * effectScale)
		smallShadow.shadowOpacity = 0.12
		smallShadow.shadowRadius = 2.0 * effectScale

		let mediumShadow = knobShadows.mediumShadow
		mediumShadow.frame = smallShadow.frame
		mediumShadow.autoresizingMask = [.layerWidthSizable]
		mediumShadow.cornerRadius = smallShadow.cornerRadius
		mediumShadow.backgroundColor = NSColor.red.cgColor
		mediumShadow.shadowColor = NSColor.black.cgColor
		mediumShadow.shadowOffset = CGSize(width: 0, height: -9 * effectScale)
		mediumShadow.shadowOpacity = 0.16
		mediumShadow.shadowRadius = 6.0 * effectScale

		let bigShadow = knobShadows.bigShadow
		bigShadow.frame = smallShadow.frame
		bigShadow.autoresizingMask = [.layerWidthSizable]
		bigShadow.cornerRadius = smallShadow.cornerRadius
		bigShadow.backgroundColor = NSColor.red.cgColor
		bigShadow.shadowColor = NSColor.black.cgColor
		bigShadow.shadowOffset = CGSize(width: 0, height: -9 * effectScale)
		bigShadow.shadowOpacity = 0.06
		bigShadow.shadowRadius = 0.5 * effectScale
	}

	// MARK: - Drawing
	public override func updateLayer() {
		// Background
		backgroundLayer.cornerRadius = ceil(bounds.height / 2)
		backgroundLayer.borderWidth = on ? ceil(bounds.height) : 3.0 * scaleFactor
		backgroundLayer.borderColor = on ? tintColor.cgColor : NSColor.black.withAlphaComponent(0.09).cgColor

		// Knob
		knobContainer.frame = knobFrameForState(on: on, pressed: pressed)
		knobLayer.cornerRadius = ceil(knobContainer.bounds.height / 2)
	}

	// MARK: - Helpers
	private func knobFrameForState(on: Bool, pressed: Bool) -> CGRect {
		let borderWidth = 3.0 * scaleFactor
		var origin: CGPoint
		var size: CGSize {
			if pressed {
				return CGSize(
					width: ceil(bounds.width * 0.69) - (2 * borderWidth),
					height: bounds.height - (2 * borderWidth)
				)
			}
			return CGSize(width: bounds.height - (2 * borderWidth), height: bounds.height - (2 * borderWidth))
		}
		
		if on {
			origin = CGPoint(x: bounds.width - size.width - borderWidth, y: borderWidth)
		} else {
			origin = CGPoint(x: borderWidth, y: borderWidth)
		}
		return CGRect(origin: origin, size: size)
	}

	// MARK: - Events
	public override func mouseDown(with theEvent: NSEvent) {
        pressed = true
		needsDisplay = true
	}

	public override func mouseUp(with theEvent: NSEvent) {
		pressed = false
		on = !on
        sendAction(action, to: target)
	}
}

#endif
