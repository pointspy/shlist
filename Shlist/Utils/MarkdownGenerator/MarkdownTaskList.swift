//
//  MarkdownList.swift
//  MarkdownGenerator
//
//  Created by Eneko Alonso on 10/9/17.
//

import Foundation

public struct MarkdownTaskList: MarkdownConvertible {
    /// List of items to be converted to a list.
    public var items: [MarkdownConvertible]

    /// MarkdownList initializer
    ///
    /// - Parameter items: List of items to be converted to a list.
    public init(items: [MarkdownConvertible]) {
        self.items = items
    }

    /// Generated Markdown output
    public var markdown: String {
        return items.map { formatted(item: $0) }.joined(separator: String.newLine)
    }

    // Per Markdown documentation, indent all lines using 4 spaces.
    private func formatted(item: MarkdownConvertible) -> String {
        guard let item = item as? MarkdownTaskCompletable else { return "" }

        let symbol = item.checked ? "- [x] " : "- [ ] "
        var lines = item.markdown.components(separatedBy: String.newLine)
        let first = lines.removeFirst()

        let oldItem = item as MarkdownConvertible
        let firstLine: String
        if oldItem is MarkdownTaskList || oldItem is MarkdownList {
            firstLine = "    \(first)"
        } else {
            firstLine = "\(symbol)\(first)"
        }

        if lines.isEmpty {
            return firstLine
        }

        let blankLine: String
        if oldItem is MarkdownTaskList || oldItem is MarkdownList {
            blankLine = ""
        } else {
            blankLine = String.newLine
        }

        let indentedLines = lines.map { $0.isEmpty ? "" : "    \($0)" }.joined(separator: String.newLine) + blankLine
        return """
        \(firstLine)
        \(indentedLines)
        """
    }
}
