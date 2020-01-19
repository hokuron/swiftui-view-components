//
//  CircularSlider.swift
//  ViewSample
//
//  Created by hokuron on 2020/01/19.
//

import SwiftUI

// MARK: Constants

private let lineWidth: CGFloat = 8.0
private let handleRadius: CGFloat = 16.0

// MARK: - Special Aliment "CircularSliderCenter"

extension HorizontalAlignment {
    private enum CircularSliderCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[HorizontalAlignment.center]
        }
    }

    static let circularSliderCenter = HorizontalAlignment.init(CircularSliderCenter.self)
}

extension VerticalAlignment {
    private enum CircularSliderCenter: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[VerticalAlignment.center] + lineWidth / 2.0 + handleRadius
        }
    }

    static let circularSliderCenter = VerticalAlignment.init(CircularSliderCenter.self)
}

extension Alignment {
    static let circularSliderCenter = Alignment(horizontal: .circularSliderCenter, vertical: .circularSliderCenter)
}

// MARK: - Views

private struct CircularShape: Shape {

    let startAngle: Angle
    let endAngle: Angle
    let clockwise: Bool

    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.addArc(center: CGPoint(x: rect.width / 2.0, y: rect.width / 2.0),
                        radius: rect.width / 2.0,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: clockwise)
        }
    }
}

private struct SliderHandle: Shape {

    var radius: CGFloat
    var currentAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2.0 - radius, y: rect.width / 2.0 - radius)
        let containerRadius = rect.width / 2.0
        let angle = CGFloat(currentAngle.radians)
        let x = cos(angle) * containerRadius + center.x
        let y = sin(angle) * containerRadius + center.y
        return Path(ellipseIn: CGRect(x: x.rounded(), y: y.rounded(), width: radius * 2.0, height: radius * 2.0))
    }
}

struct CircularSlider<Value>: View where Value: BinaryFloatingPoint, Value.Stride: BinaryFloatingPoint {

    @Binding var value: Value
    var range: ClosedRange<Value>
    var step: Value.Stride = 0.0

    var startAngle = Angle(degrees: 45)
    var endAngle = Angle(degrees: 135)
    var clockwise = true

    // https://developer.apple.com/documentation/uikit/uifeedbackgenerator#2555399
    @State private var feedbackGenerator: UISelectionFeedbackGenerator?

    private var aspectRatio: CGFloat {
        let y = max(sin(startAngle.radians), sin(endAngle.radians))
        // TODO: Add `handleRadius` height transformed on the top left origin unit circle to height
        return 2.0 / CGFloat(y + 1.0)
    }

    private var circleDistance: Angle {
        return Angle(radians: 2.0 * .pi - (endAngle.radians - startAngle.radians))
    }

    private var handleAngle: Angle {
        let ratio = Double((value - range.lowerBound) / (range.upperBound - range.lowerBound))
        return Angle(radians: ratio * circleDistance.radians + endAngle.radians)
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                CircularShape(startAngle: self.startAngle, endAngle: self.endAngle, clockwise: self.clockwise)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color.accentColor)
                SliderHandle(radius: handleRadius, currentAngle: self.handleAngle)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .gesture(DragGesture()
                        .onChanged { gestureValue in
                            let oldValue = self.value
                            self.value = self.steppedValue(from: self.normalizedValue(with: gestureValue, in: geometry.size))
                            self.feedbackGenerator = self.makeSelectionFeedbackGenerator(
                                oldValue: oldValue,
                                action: self.triggerValueChangedFeedback(with:)
                            )
                        }
                        .onEnded { _ in
                            self.feedbackGenerator = nil
                        }
                    )
            }
        }
        .padding(lineWidth / 2.0 + handleRadius)
        .aspectRatio(aspectRatio, contentMode: .fit)
    }

    private func normalizedValue(with gestureValue: DragGesture.Value, in size: CGSize) -> Value {
        let location = gestureValue.location
        let origin = CGPoint(x: size.width / 2.0, y: size.width / 2.0)
        let radius = size.width / 2.0
        let x = (origin.x - location.x) / radius
        let y = (origin.y - location.y) / radius

        var angle = Double(atan2(y, x)) + .pi
        if angle < endAngle.radians {
            angle += 2.0 * .pi
        }

        let ratio = (angle - endAngle.radians) / circleDistance.radians
        let newValue = Value(ratio) * (range.upperBound - range.lowerBound) + range.lowerBound
        return range.contains(newValue) ? newValue : value
    }

    private func steppedValue(from value: Value) -> Value {
        if step.isZero {
            return value
        }

        let step = Value(self.step)
        return (value / step).rounded() * step
    }

    private func makeSelectionFeedbackGenerator(oldValue: Value,
                                                action: (UISelectionFeedbackGenerator) -> Void)
        -> UISelectionFeedbackGenerator?
    {
        guard oldValue != value else {
            return nil
        }

        let feedbackGenerator = self.feedbackGenerator ?? UISelectionFeedbackGenerator()
        action(feedbackGenerator)
        return feedbackGenerator
    }

    private func triggerValueChangedFeedback(with feedbackGenerator: UISelectionFeedbackGenerator) {
        feedbackGenerator.selectionChanged()
        // TODO: Call `prepare()` at just after DragGesture beginning (Before `onChange()`; Equivalent to
        //       `UIGestureRecognizer.State.began`)
        // https://developer.apple.com/documentation/swiftui/gestures/composing_swiftui_gestures#3314577
        feedbackGenerator.prepare()
    }
}

struct HalfCircleSlider_Previews: PreviewProvider {
    static var previews: some View {
        CircularSlider(value: .constant(0.0), range: 0...1, step: 0.2)
    }
}
