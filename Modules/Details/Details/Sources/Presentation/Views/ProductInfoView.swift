import UIKit
import DetailsInterface
import UIComponents

final class ProductInfoView: UIView {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.Theme.secondaryBackground
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor.Theme.text
        label.numberOfLines = 0
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor.Theme.primary
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.Theme.secondaryText
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = UIColor.Theme.text
        label.numberOfLines = 0
        return label
    }()

    private let specsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let mainStack = UIStackView(arrangedSubviews: [
            imageView, nameLabel, priceLabel, ratingLabel, descriptionLabel, specsStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.alignment = .fill

        addSubview(mainStack)
        mainStack.pinToEdges(of: self)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }

    func configure(with product: ProductDetail) {
        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)
        ratingLabel.text = "\(product.rating) stars (\(product.reviewCount) reviews)"
        descriptionLabel.text = product.description
        imageView.image = UIImage(systemName: product.imageUrl)

        specsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let specsTitle = UILabel()
        specsTitle.text = "Specifications"
        specsTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        specsStack.addArrangedSubview(specsTitle)

        for spec in product.specs {
            let specLabel = UILabel()
            specLabel.text = "  - \(spec)"
            specLabel.font = .systemFont(ofSize: 14)
            specLabel.textColor = UIColor.Theme.secondaryText
            specsStack.addArrangedSubview(specLabel)
        }
    }
}
