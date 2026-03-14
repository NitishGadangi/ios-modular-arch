import UIKit
import Combine
import CartInterface
import CheckoutInterface
import UIComponents

final class CheckoutViewController: BaseViewController {
    private let viewModel: CheckoutViewModel
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

    private let itemsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.Theme.text
        return label
    }()

    private lazy var placeOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Place Order", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.Theme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setSize(height: 48)
        button.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)
        return button
    }()

    private let orderSummaryView = OrderSummaryView()

    private lazy var goHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue Shopping", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.Theme.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.setSize(height: 48)
        button.addTarget(self, action: #selector(goHomeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var orderConfirmedStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [orderSummaryView, goHomeButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.isHidden = true
        return stack
    }()

    private lazy var checkoutStack: UIStackView = {
        let titleLabel = UILabel()
        titleLabel.text = "Order Summary"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)

        let stack = UIStackView(arrangedSubviews: [titleLabel, itemsStack, totalLabel, placeOrderButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    init(viewModel: CheckoutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
        setupUI()
        bindState()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.pinToSafeArea(of: view)

        scrollView.addSubview(contentStack)
        contentStack.pinToEdges(of: scrollView, insets: UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16))
        contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true

        contentStack.addArrangedSubview(checkoutStack)
        contentStack.addArrangedSubview(orderConfirmedStack)
    }

    private func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: CheckoutViewModel.State) {
        switch state {
        case .idle:
            break
        case .cartLoaded(let items, let totalPrice):
            updateItemsList(items)
            totalLabel.text = String(format: "Total: $%.2f", totalPrice)
            showLoading(false)
            placeOrderButton.isEnabled = true
        case .placingOrder(let items, let totalPrice):
            updateItemsList(items)
            totalLabel.text = String(format: "Total: $%.2f", totalPrice)
            showLoading(true)
            placeOrderButton.isEnabled = false
        case .orderPlaced(let summary):
            showLoading(false)
            showOrderConfirmation(summary)
        case .error(let message, let items, let totalPrice):
            updateItemsList(items)
            totalLabel.text = String(format: "Total: $%.2f", totalPrice)
            showLoading(false)
            placeOrderButton.isEnabled = true
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func updateItemsList(_ items: [CartItem]) {
        itemsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            let label = UILabel()
            label.text = "\(item.name) x\(item.quantity) - \(String(format: "$%.2f", item.price * Double(item.quantity)))"
            label.font = .systemFont(ofSize: 15)
            label.textColor = UIColor.Theme.text
            itemsStack.addArrangedSubview(label)
        }
    }

    private func showOrderConfirmation(_ summary: OrderSummary) {
        checkoutStack.isHidden = true
        orderConfirmedStack.isHidden = false
        orderSummaryView.configure(with: summary)
        navigationItem.hidesBackButton = true
    }

    @objc private func placeOrderTapped() {
        viewModel.actionHandler.send(.placeOrder)
    }

    @objc private func goHomeTapped() {
        viewModel.actionHandler.send(.goHome)
    }
}
