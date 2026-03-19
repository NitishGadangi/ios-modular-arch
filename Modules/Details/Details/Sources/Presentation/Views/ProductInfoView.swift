import UIKit
import DetailsInterface
import UIComponents
import CacheLib

final class ProductInfoView: UIView {
    private let remoteImageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor.Theme.text
        label.numberOfLines = 0
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.backgroundColor = UIColor.Theme.primary.withAlphaComponent(0.8)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let mainStack = UIStackView(arrangedSubviews: [
            remoteImageView, categoryLabel, titleLabel, priceLabel, ratingLabel, descriptionLabel
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.alignment = .leading

        addSubview(mainStack)
        mainStack.pinToEdges(of: self)

        remoteImageView.translatesAutoresizingMaskIntoConstraints = false
        remoteImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        remoteImageView.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    func configure(with product: ProductDetail) {
        titleLabel.text = product.title
        priceLabel.text = String(format: "$%.2f", product.price)
        ratingLabel.text = "\u{2605} \(product.rating.rate) (\(product.rating.count) reviews)"
        descriptionLabel.text = product.description
        categoryLabel.text = "  \(product.category.capitalized)  "
        remoteImageView.loadImage(from: product.image)
    }
}
