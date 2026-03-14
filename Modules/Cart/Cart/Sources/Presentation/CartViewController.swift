import UIKit
import Combine
import CartInterface
import UIComponents

final class CartViewController: BaseViewController {
    private let viewModel: CartViewModel
    private var cancellables = Set<AnyCancellable>()
    private var cartItems: [CartItem] = []

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Your cart is empty"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = UIColor.Theme.secondaryText
        label.isHidden = true
        return label
    }()

    private lazy var footerView: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.Theme.secondaryBackground

        let totalLabel = UILabel()
        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.tag = 100

        let checkoutButton = UIButton(type: .system)
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        checkoutButton.backgroundColor = UIColor.Theme.primary
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)

        container.addSubview(totalLabel)
        container.addSubview(checkoutButton)

        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            totalLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            totalLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            checkoutButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            checkoutButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 120),
            checkoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        return container
    }()

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        setupUI()
        bindState()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(footerView)

        tableView.pinToSafeArea(of: view, insets: UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0))
        emptyLabel.centerInSuperview()

        footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: CartViewModel.State) {
        switch state {
        case .idle:
            break
        case .updated(let items, let totalPrice):
            cartItems = items
            tableView.reloadData()
            emptyLabel.isHidden = !items.isEmpty
            footerView.isHidden = items.isEmpty
            if let totalLabel = footerView.viewWithTag(100) as? UILabel {
                totalLabel.text = String(format: "Total: $%.2f", totalPrice)
            }
        }
    }

    @objc private func checkoutTapped() {
        viewModel.actionHandler.send(.tapCheckout)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        let item = cartItems[indexPath.row]
        cell.configure(with: item)
        cell.onQuantityChanged = { [weak self] quantity in
            self?.viewModel.actionHandler.send(.updateQuantity(productId: item.productId, quantity: quantity))
        }
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = cartItems[indexPath.row]
        viewModel.actionHandler.send(.selectItem(productId: item.productId))
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = cartItems[indexPath.row]
            viewModel.actionHandler.send(.removeItem(productId: item.productId))
        }
    }
}
