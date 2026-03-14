import UIKit
import Combine
import HomeInterface
import UIComponents

final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    private var products: [ProductSummary] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .clear
        return cv
    }()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ModularShop"
        setupUI()
        setupNavBar()
        bindState()
        viewModel.actionHandler.send(.loadProducts)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        collectionView.pinToSafeArea(of: view)
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
    }

    private func bindState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)
    }

    private func render(_ state: HomeViewModel.State) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoading(true)
        case .loaded(let products):
            showLoading(false)
            self.products = products
            collectionView.reloadData()
        case .error(let message):
            showLoading(false)
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func cartTapped() {
        viewModel.actionHandler.send(.tapCart)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.reuseIdentifier, for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: products[indexPath.item])
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        viewModel.actionHandler.send(.selectProduct(id: product.id))
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2 + 12
        let width = (collectionView.bounds.width - padding) / 2
        return CGSize(width: width, height: width + 50)
    }
}
