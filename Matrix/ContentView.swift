import SwiftUI

struct CaptchaView: View {
    // Target vector (x, y) for comparison
    @State private var targetX: CGFloat
    @State private var targetY: CGFloat
    @State private var currentX: CGFloat = 1.0 // Start at (1, 0) direction
    @State private var currentY: CGFloat = 0.0
    @State private var isMatched: Bool = false
    
    // Predefined directions as x,y pairs (for matching purposes)
    private let directions: [(x: CGFloat, y: CGFloat)] = {
        let angles: [CGFloat] = [0, .pi/4, .pi/2, 3 * .pi/4, .pi, 5 * .pi/4, 3 * .pi/2, 7 * .pi/4]
        return angles.map { angle in
            let cosValue = cos(angle)
            let sinValue = sin(angle)
            return (x: cosValue, y: sinValue)
        }
    }()
    
    init() {
        // Random target vector from predefined directions
        let randomDirection = Int.random(in: 0..<directions.count)
        _targetX = State(initialValue: directions[randomDirection].x)
        _targetY = State(initialValue: directions[randomDirection].y)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 40) {
                // Target Direction
                VStack {
                    Text("Target Direction")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(radians: Double(atan2(targetY, targetX))))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 5)
                                .frame(width: 100, height: 100)
                        )
                }
                
                // Rotatable Direction
                VStack {
                    Text("Rotate to Match")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .rotationEffect(Angle(radians: Double(atan2(currentY, currentX))))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 5)
                                .frame(width: 100, height: 100)
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    rotateWithMatrix(from: value)
                                }
                                .onEnded { _ in
                                    checkMatch()
                                }
                        )
                }
            }
            .padding()
            
            if isMatched {
                Text("Images matched! CAPTCHA solved.")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
                    .transition(.opacity)
            }
        }
    }
    
    private func rotateWithMatrix(from value: DragGesture.Value) {
        // Calculate the angle of rotation based on drag distance (arbitrary rotation speed factor)
        let dragAngle = CGFloat(value.translation.width / 100)
        let cosTheta = cos(dragAngle)
        let sinTheta = sin(dragAngle)
        
        // Apply rotation matrix to (currentX, currentY)
        let newX = currentX * cosTheta - currentY * sinTheta
        let newY = currentX * sinTheta + currentY * cosTheta
        
        // Update current vector
        currentX = newX
        currentY = newY
    }
    
    private func checkMatch() {
        let epsilon: CGFloat = 0.05 // Small tolerance for comparison
        isMatched = directions.contains { abs($0.x - currentX) < epsilon && abs($0.y - currentY) < epsilon }
    }
}
