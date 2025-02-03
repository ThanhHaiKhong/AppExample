//
//  LoadingSpinner.swift
//  UIComponents
//
//  Created by Thanh Hai Khong on 6/12/24.
//

import SwiftUI

public struct LoadingSpinner: View {
    
    private let rotationTime: Double = 0.75
    private let animationTime: Double = 1.9
    private let fullRotation: Angle = .degrees(360)
    private static let initialDegree: Angle = .degrees(270)
    
    @State private var spinnerStart: CGFloat = 0.0
    @State private var spinnerEndS1: CGFloat = 0.03
    @State private var spinnerEndS2S3: CGFloat = 0.03
    
    @State private var rotationDegreeS1 = initialDegree
    @State private var rotationDegreeS2 = initialDegree
    @State private var rotationDegreeS3 = initialDegree
    
    public init() {
        
    }
    
    public var body: some View {
        ZStack {
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS3, color: .darkViolet)
            
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS2, color: .darkPink)
            
            SpinnerCircle(start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, color: .darkBlue)
        }
        .onAppear {
            animateSpinner()
            
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { mainTimer in
                DispatchQueue.main.async {
                    animateSpinner()
                }
            }
        }
    }
    
    // MARK: - Animation methods
    
    @MainActor
    private func animateSpinner(with duration: Double, completion: @escaping @MainActor () -> Void) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(.easeInOut(duration: rotationTime)) {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    private func animateSpinner() {
        animateSpinner(with: rotationTime) {
            spinnerEndS1 = 1.0
        }
        
        animateSpinner(with: rotationTime * 2 - 0.025) {
            rotationDegreeS1 += fullRotation
            spinnerEndS2S3 = 0.8
        }
        
        animateSpinner(with: rotationTime * 2) {
            spinnerEndS1 = 0.03
            spinnerEndS2S3 = 0.03
        }
        
        animateSpinner(with: rotationTime * 2 + 0.0525) {
            rotationDegreeS2 += fullRotation
        }
        
        animateSpinner(with: rotationTime * 2 + 0.225) {
            rotationDegreeS3 += fullRotation
        }
    }
}

// MARK: - SpinnerCircle

public struct SpinnerCircle: View {
    public var start: CGFloat
    public var end: CGFloat
    public var rotation: Angle
    public var color: Color
    
    public var body: some View {
        GeometryReader { proxy in
            let lineWidth = proxy.size.width / 7
            Circle()
                .trim(from: start, to: end)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .fill(color)
                .rotationEffect(rotation)
        }
    }
}
