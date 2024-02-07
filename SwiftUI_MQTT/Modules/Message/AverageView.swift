import SwiftUI

struct AverageView: View {
    let values: [Int] // 구독한 값이 저장된 배열

    init(values: [Int]) {
        self.values = values
    }

    var body: some View {
        VStack {
            // ForEach를 사용하여 각 평균값을 별도의 텍스트 뷰로 표시
            ForEach(averageValues, id: \.self) { averageValue in
                Text("평균 값: \(averageValue)")
            }
        }
        .onAppear {
            calculateAverageValues() // 평균 값 계산
        }
    }

    @State private var averageValues: [Int] = [] // 평균 값이 저장될 배열

    // 평균 값 계산 및 저장
    private func calculateAverageValues() {
        guard values.count >= 60 else {
            return // 값이 60개 미만이면 계산하지 않음
        }

        // 60개씩 묶어서 평균 계산하여 저장
        var index = 0
        while index + 60 <= values.count {
            let chunk = Array(values[index..<index+60])
            let average = chunk.reduce(0, +) / 60
            averageValues.append(average)
            index += 60
        }
    }
}

#Preview {
    AverageView(values: [1, 2, 3, 4, 5]) // 구독한 값의 예시로 임의의 배열 전달
}
