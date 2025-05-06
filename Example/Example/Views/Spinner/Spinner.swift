//
//  Spinner.swift
//  Example
//
//  Created by Thanh Hai Khong on 6/12/24.
//

import SwiftUI
import LoadingSpinner

struct Spinner: View {
    
    let rotationTime: Double = 0.75
    let animationTime: Double = 1.9
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)
    
    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var spinnerEndS2S3: CGFloat = 0.03
    
    @State var rotationDegreeS1 = initialDegree
    @State var rotationDegreeS2 = initialDegree
    @State var rotationDegreeS3 = initialDegree
    
    var body: some View {
        ZStack {
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS3, color: .darkViolet)
            
            SpinnerCircle(start: spinnerStart, end: spinnerEndS2S3, rotation: rotationDegreeS2, color: .darkPink)
            
            SpinnerCircle(start: spinnerStart, end: spinnerEndS1, rotation: rotationDegreeS1, color: .darkBlue)
        }
        .onAppear {
            animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { mainTimer in
                self.animateSpinner()
            }
        }
    }
    
    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
            print("Animating spinner: \(timer.fireDate)")
            withAnimation(.easeInOut(duration: rotationTime)) {
                completion()
            }
        }
    }
    
    func animateSpinner() {
        animateSpinner(with: rotationTime) {
            spinnerEndS1 = 1.0
        }
        
        animateSpinner(with: (rotationTime * 2) - 0.025) {
            rotationDegreeS1 += fullRotation
            spinnerEndS2S3 = 0.8
        }
        
        animateSpinner(with: (rotationTime * 2)) {
            spinnerEndS1 = 0.03
            spinnerEndS2S3 = 0.03
        }
        
        animateSpinner(with: (rotationTime * 2) + 0.0525) {
            rotationDegreeS2 += fullRotation
        }
        
        animateSpinner(with: (rotationTime * 2) + 0.225) {
            rotationDegreeS3 += fullRotation
        }
    }
}

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color
    
    var body: some View {
        GeometryReader { proxy in
            let lineWidth = proxy.size.width * 0.175
            Circle()
                .trim(from: start, to: end)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .fill(color)
                .rotationEffect(rotation)
        }
    }
}
