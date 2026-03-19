import UIKit
import HomeInterface
import UIComponents
import CacheLib

final class ProductCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductCell"

    private let remoteImageView: RemoteImageView = {
        let iv = RemoteImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 8
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.Theme.text
        label.numberOfLines = 2
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor.Theme.secondaryText
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.Theme.primary
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = UIColor.Theme.secondaryText
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
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.08
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4

        let stack = UIStackView(arrangedSubviews: [remoteImageView, titleLabel, categoryLabel, priceLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill

        contentView.addSubview(stack)
        stack.pinToEdges(of: contentView, insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))

        remoteImageView.heightAnchor.constraint(equalTo: remoteImageView.widthAnchor, multiplier: 0.9).isActive = true
        remoteImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(with product: ProductSummary) {
        titleLabel.text = product.title
        categoryLabel.text = product.category.capitalized
        priceLabel.text = String(format: "$%.2f", product.price)
        ratingLabel.text = "\u{2605} \(product.rating.rate) (\(product.rating.count))"
        remoteImageView.loadImage(from: product.image)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        remoteImageView.cancelLoad()
        remoteImageView.image = nil
        titleLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil
    }
}
