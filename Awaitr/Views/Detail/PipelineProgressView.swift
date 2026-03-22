//
//  PipelineProgressView.swift
//  Awaitr
//

import SwiftUI

struct PipelineProgressView: View {
    let status: WaitStatus

    private let steps: [(label: String, index: Int)] = [
        ("Sub.", 0),
        ("Review", 1),
        ("Await", 2),
        ("Decision", 3)
    ]

    private var completedCount: Int {
        switch status {
        case .submitted: 1
        case .inReview: 2
        case .awaiting: 3
        case .accepted, .rejected: 4
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { offset, step in
                if offset > 0 {
                    connector(completed: offset < completedCount)
                        .padding(.bottom, 18)
                }
                stepView(number: offset + 1, label: step.label, completed: offset < completedCount, isLast: offset == 3)
            }
        }
    }

    // MARK: - Step Circle

    private func stepView(number: Int, label: String, completed: Bool, isLast: Bool) -> some View {
        VStack(spacing: 4) {
            circleContent(number: number, completed: completed, isLast: isLast)
                .frame(width: 28, height: 28)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(completed ? Color(hex: "6C63FF") : Color(hex: "999999"))
        }
    }

    @ViewBuilder
    private func circleContent(number: Int, completed: Bool, isLast: Bool) -> some View {
        if isLast && status == .accepted {
            Circle()
                .fill(Color(hex: "3B6D11").opacity(0.15))
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "3B6D11"))
                )
        } else if isLast && status == .rejected {
            Circle()
                .fill(Color(hex: "E24B4A").opacity(0.15))
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: "E24B4A"))
                )
        } else {
            Circle()
                .fill(completed ? Color(hex: "6C63FF").opacity(0.15) : Color.black.opacity(0.05))
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(completed ? Color(hex: "6C63FF") : Color(hex: "999999"))
                )
        }
    }

    // MARK: - Connector

    private func connector(completed: Bool) -> some View {
        Rectangle()
            .fill(completed ? Color(hex: "6C63FF").opacity(0.3) : Color.black.opacity(0.06))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(WaitStatus.allCases) { status in
            VStack(spacing: 4) {
                Text(status.label)
                    .font(.caption)
                PipelineProgressView(status: status)
            }
        }
    }
    .padding()
}
