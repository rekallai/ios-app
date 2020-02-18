//
//  RichTextCustomizations.swift
//  Rekall
//
//  Created by Ray Hunter on 09/12/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import Foundation
import Contentful
import ContentfulRichTextRenderer


//
//
// All the modifcations required to Contentful Rich Text Renderer.
// We have to completely replace each renderer if we want to change just one line
// as they are structs.
//
//


//
// Keep it simple in here
//
public class RichTextLayoutManager: NSLayoutManager {

    public override init() {
        super.init()
        allowsNonContiguousLayout = true
    }

    public override var hasNonContiguousLayout: Bool {
        return true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public class RichTextContainer: NSTextContainer {

    var largestHeight: CGFloat = 0.0

    public override func lineFragmentRect(forProposedRect proposedRect: CGRect,
                                          at characterIndex: Int,
                                          writingDirection baseWritingDirection: NSWritingDirection,
                                          remaining remainingRect: UnsafeMutablePointer<CGRect>?) -> CGRect {
        let output = super.lineFragmentRect(forProposedRect: proposedRect,
                                            at: characterIndex,
                                            writingDirection: baseWritingDirection,
                                            remaining: remainingRect)

        if output.origin.y + output.size.height > 0.0 {
            largestHeight = output.origin.y + output.size.height
        }
        return output
    }
}

//
//  Required duplication from Contentful as this was marked internal
//
extension Dictionary where Key == CodingUserInfoKey {
    var styleConfig: RenderingConfiguration {
        return self[.renderingConfig] as! RenderingConfiguration
    }
}

//
//  Added support for our dark mode colors
//
struct ADTextRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let text = node as! Text
        let renderingConfig = context.styleConfig

        let font = DefaultRichTextRenderer.font(for: text, config: renderingConfig)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = renderingConfig.lineSpacing
        paragraphStyle.paragraphSpacing = renderingConfig.paragraphSpacing

        let textColor = UIColor(named: "BlackWhite") ?? UIColor.black
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor
        ]
        let attributedString = NSMutableAttributedString(string: text.value, attributes: attributes)
        return [attributedString]
    }
}

//
//  Required duplication from Contentful as this was marked internal
//
extension Swift.Array where Element == NSMutableAttributedString {
    mutating func appendNewlineIfNecessary(node: Node) {
        guard node is BlockNode else { return }
        append(NSMutableAttributedString(string: "\n"))
    }

    mutating func applyListItemStylingIfNecessary(node: Node, context: [CodingUserInfoKey: Any]) {

        // check the current node and if it has children,
        // if any of children are blocks, mutate and pass down context.
        // if it doesn’t have children, apply styles, clear conte
        guard node is Text || (node as? BlockNode)?.content.filter({ $0 is BlockNode }).count == 0 else {
            return
        }

        let listContext = context[.listContext] as! ListContext
        guard listContext.level > 0 else { return }

        // Get the character for the index.
        let listIndex = listContext.itemIndex
        let listChar = listContext.listChar(at: listIndex) ?? ""

        let textColor = UIColor(named: "BlackWhite") ?? UIColor.black
        let textColorAttrs = [NSAttributedString.Key.foregroundColor : textColor]

        if listContext.isFirstListItemChild {
            insert(NSMutableAttributedString(string: "\t" + listChar + "\t", attributes: textColorAttrs), at: 0)
        } else if node is BlockNode {
            for _ in 0...listContext.indentationLevel {
                insert(NSMutableAttributedString(string: "\t", attributes: textColorAttrs), at: 0)
            }
        }

        forEach { string in
            string.applyListItemStyling(node: node, context: context)
        }
    }
}

//
//  Required duplication from Contentful as this was marked internal
//
extension NSMutableAttributedString {

    /// This method uses all the state passed-in via the `context` to apply the proper paragraph styling
    /// to the characters contained in the passed-in node.
    func applyListItemStyling(node: Node, context: [CodingUserInfoKey: Any]) {
        let listContext = context[.listContext] as! ListContext

        // At level 0, we're not rendering a list.
        guard listContext.level > 0 else { return }

        let renderingConfig = context.styleConfig
        let paragraphStyle = NSMutableParagraphStyle()
        let indentation = CGFloat(listContext.indentationLevel) * renderingConfig.indentationMultiplier

        // The first tab stop defines the x-position where the bullet or index is drawn.
        // The second tab stop defines the x-position where the list content begins.
        let tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: [:]),
            NSTextTab(textAlignment: .left, location: indentation + renderingConfig.distanceFromBulletMinXToCharMinX, options: [:])
        ]

        paragraphStyle.tabStops = tabStops

        // Indent subsequent lines to line up with first tab stop after bullet.
        paragraphStyle.headIndent = indentation + renderingConfig.distanceFromBulletMinXToCharMinX

        paragraphStyle.paragraphSpacing = renderingConfig.paragraphSpacing
        paragraphStyle.lineSpacing = renderingConfig.lineSpacing

        addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: length))
    }
}


//
//  This had a default implementation that signalled and waited for a semaphonre on the main thread.
//  This caused a crash in original version if someone added a HR.
//
public struct ADHorizontalRuleRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey : Any]) -> [NSMutableAttributedString] {
        let provider = context.styleConfig.horizontalRuleProvider

        let hrView = provider.horizontalRule(context: context)

        var rendered = [NSMutableAttributedString(string: "\0", attributes: [.horizontalRule: hrView])]
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}


public struct ADParagraphRenderer: NodeRenderer {

    public func render(node: Node, renderer: RichTextRenderer, context: [CodingUserInfoKey: Any]) -> [NSMutableAttributedString] {
        let paragraph = node as! Paragraph
        var rendered = paragraph.content.reduce(into: [NSMutableAttributedString]()) { (rendered, node) in
            let nodeRenderer = renderer.renderer(for: node)

            let renderedChildren = nodeRenderer.render(node: node, renderer: renderer, context: context)
            rendered.append(contentsOf: renderedChildren)
        }
        rendered.applyListItemStylingIfNecessary(node: node, context: context)
        rendered.appendNewlineIfNecessary(node: node)
        return rendered
    }
}
