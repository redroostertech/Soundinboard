import Foundation

extension Int {
    static func random(range: Range<Int>) -> Int {
        var offset = 0
        if range.startIndex < 0 {
            offset = abs(range.startIndex)
        }
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }

    var rounded:String {
      let abbrev = "KMBTPE"
      return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
        let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
        let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
        return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
        } ?? String(self)
    }
}
