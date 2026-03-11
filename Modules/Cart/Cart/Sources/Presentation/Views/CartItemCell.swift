import UIKit
import CartInterface
import UIComponents

final class CartItemCell: UITableViewCell {
    static let reuseIdentifier = "CartItemCell"

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.Theme.text
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.Theme.primary
        return label
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.Theme.secondaryText
        return label
    }()

    private let stepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = 99
        return stepper
    }()

    var onQuantityChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4

        let quantityStack = UIStackView(arrangedSubviews: [quantityLabel, stepper])
        quantityStack.axis = .horizontal
        quantityStack.spacing = 8
        quantityStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [infoStack, quantityStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing

        contentView.addSubview(mainStack)
        mainStack.pinToEdges(of: contentView, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))

        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
    }

    @objc private func stepperChanged() {
        let quantity = Int(stepper.value)
        quantityLabel.text = "Qty: \(quantity)"
        onQuantityChanged?(quantity)
    }

    func configure(with item: CartItem) {
        nameLabel.text = item.name
        priceLabel.text = String(format: "$%.2f", item.price * Double(item.quantity))
        quantityLabel.text = "Qty: \(item.quantity)"
        stepper.value = Double(item.quantity)
    }
}
