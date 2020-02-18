//
//  RichTextCell.swift
//  Rekall
//
//  Created by Ray Hunter on 04/12/2019.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit
import Contentful
import ContentfulRichTextRenderer

class RichTextCell: UITableViewCell, NSLayoutManagerDelegate {

    static let identifier = "RichTextCell"
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let app = UIApplication.shared.delegate as? AppDelegate,
        let window = app.window {
            frame.size.width = window.frame.size.width
        }
        
        textStorage.addLayoutManager(layoutManager)

        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        textContainer.lineBreakMode = .byWordWrapping

        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
        textView = IntrinsicControlledTextView(frame: bounds, textContainer: textContainer)
        textView.contentMode = .topLeft
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textView.setContentHuggingPriority(.required, for: .vertical)
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leftAnchor.constraint(equalTo: leftAnchor),
            textView.rightAnchor.constraint(equalTo: rightAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        textView.isScrollEnabled = false
        textView.contentSize.height = .greatestFiniteMagnitude
        textView.isEditable = false

        textContainer.size.width = frame.size.width
        textContainer.size.height = .greatestFiniteMagnitude
        
        //
        //  Replace any renderer subitems
        //
        renderer.textRenderer = ADTextRenderer()
        renderer.horizontalRuleRenderer = ADHorizontalRuleRenderer()
        renderer.paragraphRenderer = ADParagraphRenderer()
    }
        
    public var richText: RichTextDocument? {
        didSet {
            guard let richText = richText else { return }
            let output = self.renderer.render(document: richText)
                self.textStorage.beginEditing()
                self.textStorage.setAttributedString(output)
                self.textStorage.endEditing()
        }
    }
        
    private var textView: IntrinsicControlledTextView!
    private var renderer = DefaultRichTextRenderer()
    private let textStorage = NSTextStorage()
    private let layoutManager = RichTextLayoutManager()
    private let textContainer = RichTextContainer(size: CGSize(width: 300, // This gets reset in awakeFromNib
                                                               height: CGFloat.greatestFiniteMagnitude))
    
    // Inspired by: https://github.com/vlas-voloshin/SubviewAttachingTextView/blob/master/SubviewAttachingTextView/SubviewAttachingTextViewBehavior.swift
    public func layoutManager(_ layoutManager: NSLayoutManager,
                              didCompleteLayoutFor textContainer: NSTextContainer?,
                              atEnd layoutFinishedFlag: Bool) {

        guard layoutFinishedFlag == true else { return }

        textView.intrinsicHeight = self.textContainer.largestHeight
    }
}

class IntrinsicControlledTextView: UITextView {
    
    var intrinsicHeight: CGFloat?
    
    override var intrinsicContentSize: CGSize {
        let margins: CGFloat = layoutMargins.top + layoutMargins.bottom + 30
        let size = CGSize(width: frame.width, height: (intrinsicHeight ?? frame.height) + margins)
        return size
    }
    
}

