//
//  ViewController.swift
//  Example
//
//  Created by Thanh Hai Khong on 26/6/25.
//

import UIKitPreviews
import UIKit
import SwiftUI

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
	}
	
	// MARK: - SetupViews
	
	private lazy var textView: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.text = """
			this is a UITextView. 
		it 
		supports ♪♪ multiple lines of text and can be used for displaying larger blocks of text. You can also interact with it, ♪♪♪ such as selecting and copying text ♪.
		"""
		textView.font = UIFont.systemFont(ofSize: 18)
		textView.textColor = .label
		textView.backgroundColor = .systemGray5
		textView.isScrollEnabled = true
		textView.layer.cornerRadius = 5
		textView.layer.masksToBounds = true
		textView.contentInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
		return textView
	}()
	
	private lazy var titleLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.text = "UITextView"
		textLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		textLabel.textColor = .label
		return textLabel
	}()
	
	private lazy var textLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		textLabel.textColor = .secondaryLabel
		textLabel.numberOfLines = 0
		return textLabel
	}()
	
	private func setupViews() {
		view.backgroundColor = .systemBackground
		
		let stackView: UIStackView = {
			let stackView = UIStackView(arrangedSubviews: [textView, titleLabel, textLabel])
			stackView.translatesAutoresizingMaskIntoConstraints = false
			stackView.axis = .vertical
			stackView.spacing = 20
			return stackView
		}()
		
		view.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
		
		textLabel.text = textView.text
			.normalizeWhitespace()
			.removingIsolatedSymbols(symbol: "♪", groupSize: 3)
			.capitalizingFirstLetterOfEachSentence()
	}
}

struct ViewController_Previews: PreviewProvider {
	static var previews: some View {
		UIViewControllerPreview {
			ViewController()
		}
	}
}

extension String {
	
	/// Trim khoảng trắng đầu/cuối từng dòng
	func trimLines() -> [String] {
		self.components(separatedBy: .newlines)
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
	}
	
	public var capitalizedSentence: String {
		let firstLetter = self.prefix(1).capitalized
		let remainingLetters = self.dropFirst().lowercased()
		return firstLetter + remainingLetters
	}
}

extension Array where Element == String {
	
	/// Loại bỏ các dòng trống
	func removeEmptyLines() -> [String] {
		self.filter { !$0.isEmpty }
	}
	
	/// Ghép các dòng thành một chuỗi duy nhất
	func flattenLines(separator: String = " ") -> String {
		self.joined(separator: separator)
	}
}

extension String {
	
	/// Thu gọn nhiều khoảng trắng liên tiếp thành một
	func collapseWhitespace() -> String {
		self.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
	}
	
	/// Kết hợp toàn bộ các bước xử lý văn bản từ UITextView
	func normalizeWhitespace() -> String {
		return self
			.trimLines()
			.removeEmptyLines()
			.flattenLines(separator: " ")
			.collapseWhitespace()
			.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	/// Xoá các chuỗi symbol có số lượng nhỏ hơn groupSize
	func removingIsolatedSymbols(symbol: Character, groupSize: Int) -> String {
		guard groupSize > 0 else { return self }
		
		// Regex pattern:
		// - symbol xuất hiện từ 1 đến groupSize - 1
		// - không kèm thêm symbol liền kề phía trước và sau
		let pattern = "(?<!\(symbol))\(String(repeating: symbol, count: 1)){\(1),\(groupSize - 1)}(?!\(symbol))"
		
		guard let regex = try? NSRegularExpression(pattern: pattern) else {
			return self
		}
		
		let range = NSRange(self.startIndex..., in: self)
		return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
	}
	
	/// Viết hoa chữ cái đầu tiên của mỗi câu (phân cách bởi ., !, ?)
	func capitalizingFirstLetterOfEachSentence() -> String {
		// Regex để chia câu dựa theo dấu câu kết thúc (. ! ?), giữ lại dấu
		let pattern = #"([^.!?]*[.!?])"#
		
		guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
			return self
		}
		
		let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)
		var result = ""
		var lastRangeEnd = self.startIndex
		
		regex.enumerateMatches(in: self, options: [], range: nsrange) { match, _, _ in
			guard let match = match,
				  let range = Range(match.range, in: self) else { return }
			
			// Phần câu hiện tại
			var sentence = self[range].trimmingCharacters(in: .whitespacesAndNewlines)
			
			// Viết hoa chữ cái đầu tiên
			if let first = sentence.first {
				sentence.replaceSubrange(
					sentence.startIndex...sentence.startIndex,
					with: String(first).uppercased()
				)
			}
			
			result += sentence + " "
			lastRangeEnd = range.upperBound
		}
		
		// Thêm phần còn lại nếu có (nếu không kết thúc bằng dấu câu)
		if lastRangeEnd < self.endIndex {
			let remaining = self[lastRangeEnd...].trimmingCharacters(in: .whitespacesAndNewlines)
			if !remaining.isEmpty {
				result += remaining.prefix(1).uppercased() + remaining.dropFirst()
			}
		}
		
		return result.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
