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
        bindState()
        viewModel.actionHandler.send(.loadProduct)
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

    private func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: DetailsViewModel.State) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoading(true)
        case .loaded(let product):
            showLoading(false)
            productInfoView.configure(with: product)
            title = product.title
            addToCartButton.setTitle("Add to Cart", for: .normal)
            addToCartButton.backgroundColor = UIColor.Theme.primary
        case .addedToCart:
            addToCartButton.setTitle("Added!", for: .normal)
            addToCartButton.backgroundColor = UIColor.Theme.success
        case .error(let message):
            showLoading(false)
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func addToCartTapped() {
        viewModel.actionHandler.send(.addToCart)
    }

    @objc private func buyNowTapped() {
        viewModel.actionHandler.send(.buyNow)
    }

    @objc private func cartTapped() {
        viewModel.actionHandler.send(.tapCart)
    }
}
