import UIKit
import CheckoutInterface
import UIComponents

final class OrderSummaryView: UIView {
    private let checkmarkImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = UIColor.Theme.success
        iv.contentMode = .scaleAspectFit
        iv.setSize(width: 80, height: 80)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Confirmed!"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.Theme.text
        label.textAlignment = .center
        return label
    }()

    private let orderIdLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.Theme.secondaryText
        label.textAlignment = .center
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor.Theme.primary
        label.textAlignment = .center
        return label
    }()

    private let deliveryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.Theme.secondaryText
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            checkmarkImage, titleLabel, orderIdLabel, totalLabel, deliveryLabel
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        addSubview(stack)
        stack.pinToEdges(of: self)
    }

    func configure(with summary: OrderSummary) {
        orderIdLabel.text = "Order: \(summary.orderId)"
        totalLabel.text = String(format: "Total: $%.2f", summary.total)
        deliveryLabel.text = "Estimated delivery: \(summary.estimatedDelivery)"
    }
}
