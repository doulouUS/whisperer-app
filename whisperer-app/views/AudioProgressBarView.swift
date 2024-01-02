//
//  AudioProgressBarView.swift
//  whisperer-app
//
//  Created by Louis DOUGE on 28/11/23.
//

import SwiftUI

struct AudioProgressBarView: View {
    @Binding var elapsedTime: TimeInterval
    @Binding var remainingTime: TimeInterval

    var body: some View {
        VStack {
            HStack {
                // Display elapsed time
                Text(formatTime(elapsedTime))
                    .padding(.bottom, 4)
                Spacer()
                // Display remaining time
                Text("-\(formatTime(remainingTime))")
                    .padding(.top, 4)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: geometry.size.width, height: 8)

                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: calculateProgressBarWidth(geometry), height: 8)
                }
            }
        }
        .padding()
    }

    private func calculateProgressBarWidth(_ geometry: GeometryProxy) -> CGFloat {
        let totalDuration = elapsedTime + remainingTime
        // Check if totalDuration is not zero to avoid division by zero
        guard totalDuration > 0 else {
            return 0
        }
        let width = CGFloat(elapsedTime / totalDuration) * geometry.size.width
        return ceil(width)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: time) ?? "0:00"
    }
}
