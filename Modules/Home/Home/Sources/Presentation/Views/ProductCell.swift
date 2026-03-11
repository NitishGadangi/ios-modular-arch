import UIKit
import HomeInterface
import UIComponents

final class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.Theme.secondaryBackground
        iv.layer.cornerRadius = 8
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.Theme.text
        label.numberOfLines = 2
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.Theme.primary
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
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill

        contentView.addSubview(stack)
        stack.pinToEdges(of: contentView, insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))

        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(with product: ProductSummary) {
        nameLabel.text = product.name
        priceLabel.text = String(format: "$%.2f", product.price)
        imageView.image = UIImage(systemName: "photo")
    }
}
