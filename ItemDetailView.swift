import UIKit

class ItemDetailView: UIViewController {
    
    var item: Item?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comments here"
        textField.borderStyle = .roundedRect
        textField.text = "Good" // Default text set to "Good"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        if let item = item {
            titleLabel.text = item.name
            
            // Simplified logic for comments
            let comments = item.comments
            commentTextField.text = comments.isEmpty ? "Good" : comments
        }
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(commentTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            commentTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func saveTapped() {
        guard var item = item else { return }
        item.comments = commentTextField.text ?? "。好" // Changed to "Good" instead of Chinese characters
        self.item = item
        navigationController?.popViewController(animated: true)
    }
}
