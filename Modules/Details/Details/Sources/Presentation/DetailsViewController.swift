import UIKit
import Combine
import DetailsInterface
import UIComponents

final class DetailsViewController: BaseViewController {
    private let viewModel: DetailsViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    private let productInfoView = ProductInfoView()

    private lazy var addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.Theme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setSize(height: 48)
        button.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return button
    }()

    private lazy var buyNowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Buy Now", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.Theme.accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setSize(height: 48)
        button.addTarget(self, action: #selector(buyNowTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product Details"
        setupUI()
        setupNavBar()
        bindOutput()
        viewModel.input.loadProduct.send()
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.pinToSafeArea(of: view)

        scrollView.addSubview(contentStack)
        contentStack.pinToEdges(of: scrollView, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true

        let buttonStack = UIStackView(arrangedSubviews: [addToCartButton, buyNowButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        contentStack.addArrangedSubview(productInfoView)
        contentStack.addArrangedSubview(buttonStack)
    }

    private func bindOutput() {
        viewModel.output.product
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.productInfoView.configure(with: product)
                self?.title = product.name
            }
            .store(in: &cancellables)

        viewModel.output.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.showLoading(loading)
            }
            .store(in: &cancellables)

        viewModel.output.addedToCart
            .receive(on: DispatchQueue.main)
            .sink { [weak self] added in
                self?.addToCartButton.setTitle(added ? "Added!" : "Add to Cart", for: .normal)
                self?.addToCartButton.backgroundColor = added ? UIColor.Theme.success : UIColor.Theme.primary
            }
            .store(in: &cancellables)

        viewModel.output.errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }

    @objc private func addToCartTapped() {
        viewModel.input.addToCart.send()
    }

    @objc private func buyNowTapped() {
        viewModel.input.buyNow.send()
    }

    @objc private func cartTapped() {
        viewModel.input.tapCart.send()
    }
}
