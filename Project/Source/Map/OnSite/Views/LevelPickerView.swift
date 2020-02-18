/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This view displays IMDF level names as vertically-stacked buttons.
*/

import UIKit

@objc protocol LevelPickerDelegate: class {
    func selectedLevelDidChange(selectedIndex: Int)
}

@available(iOS 13.0, *)
class LevelPickerView: UIView {
    @IBOutlet weak var delegate: LevelPickerDelegate?
    @IBOutlet var backgroundView: UIVisualEffectView!
    @IBOutlet var stackView: UIStackView!

    var levelNames: [String] = [] {
        didSet {
            self.generateStackViewButtons()
        }
    }

    private var isExpanded = false
    private var buttons: [UIButton] = []
    private var separators: [UIView] = []
    var selectedIndex: Int? {
        didSet {
            if let oldIndex = oldValue {
                buttons[oldIndex].backgroundColor = nil
            }

            if let index = selectedIndex {
                buttons[index].backgroundColor = UIColor(named: "LevelPickerSelected")
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        backgroundView.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0

        super.awakeFromNib()
    }

    private func generateStackViewButtons() {
        // Remove the existing stack view items, as we will re-create things from scratch.
        let existingViews = stackView.arrangedSubviews
        for view in existingViews {
            stackView.removeArrangedSubview(view)
        }
        buttons.removeAll()
        separators.removeAll()

        for (index, levelName) in levelNames.enumerated() {
            let levelButton = UIButton(type: .custom)
            levelButton.setTitle(levelName, for: .normal)
            levelButton.setTitleColor(.label, for: .normal)
            levelButton.widthAnchor.constraint(equalToConstant: 45.0).isActive = true
            levelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            // Associate the button with the index in the input list so we can reference it later.
            // Using 'tag' because all the buttons are private and controlled entirely by this control, and because the tag
            // property is only used for one purpose, to associate the index of a level with a button when it's been tapped.
            levelButton.tag = index

            stackView.addArrangedSubview(levelButton)
            levelButton.addTarget(self, action: #selector(levelSelected(sender:)), for: .primaryActionTriggered)
            
            levelButton.isHidden = index != 0

            // Add a separator view between each button.
            if index < levelNames.count - 1 {
                let separator = UIView()
                separators.append(separator)
                separator.backgroundColor = UIColor.separator
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(separator)
                separator.isHidden = true
            }

            buttons.append(levelButton)
        }
    }
    
    @objc
    private func levelSelected(sender: UIButton) {
        if !isExpanded {
            UIView.animate(withDuration: 0.3) {
                self.buttons.forEach { $0.isHidden = false }
                self.separators.forEach { $0.isHidden = false }
                self.layoutIfNeeded()
            }
            isExpanded = true
            
            return
        }
        
        let selectedIndex = sender.tag
        showButtonForSelectedIndex(selectedIndex: selectedIndex, animated: true)
        delegate?.selectedLevelDidChange(selectedIndex: selectedIndex)
    }
    
    
    func showButtonForSelectedIndex(selectedIndex: Int, animated: Bool) {
        guard selectedIndex >= 0 && selectedIndex < levelNames.count else {
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.buttons.forEach { $0.isHidden = $0.tag != selectedIndex }
                self.separators.forEach { $0.isHidden = true }
                self.layoutIfNeeded()
            }
        } else {
            self.buttons.forEach { $0.isHidden = $0.tag != selectedIndex }
            self.separators.forEach { $0.isHidden = true }
        }
        
        isExpanded = false
        
        self.selectedIndex = selectedIndex
    }
    
    
    func userMovedToSelectedIndex(selectedIndex: Int) {
        showButtonForSelectedIndex(selectedIndex: selectedIndex, animated: false)
    }
}
