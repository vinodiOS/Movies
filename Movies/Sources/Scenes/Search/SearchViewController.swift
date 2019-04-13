import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: ViewController<SearchViewModel> {

  typealias SearchCellViewModelFactory = (Search.Result) -> SearchCellViewModel

  // MARK: - Views

  @IBOutlet private var tableView: UITableView!

  private let searchController = UISearchController(searchResultsController: nil)

  private var searchBar: UISearchBar {
    return searchController.searchBar
  }

  private var tableFooter: UIView!

  // MARK: - Properties

  var searchCellViewModelFactory: SearchCellViewModelFactory!

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    setupViews()
    setupThemes()
    setupBindings()
  }

}

// MARK: - Setup

extension SearchViewController {

  fileprivate func setupViews() {

    searchController.dimsBackgroundDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false

    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false

    definesPresentationContext = true

    tableFooter = UIView(frame: .init(x: 0, y: 0, width: tableView.frame.width, height: 0.5))

    tableView.tableFooterView = tableFooter

    tableView.register(SearchCell.self)
  }

  fileprivate func setupThemes() {

    themes.rx
      .bind({ $0.barStyle }, to: searchBar.rx.barStyle)
      .disposed(by: disposeBag)

    themes.rx
      .bind({ $0.cellSeparatorColor }, to: tableView.rx.separatorColor)
      .disposed(by: disposeBag)

    themes.rx
      .bind({ $0.cellSeparatorColor }, to: tableFooter.rx.backgroundColor)
      .disposed(by: disposeBag)

    themes.rx
      .bind({ $0.navigationBarForegroundColor }, to: (searchBar.value(forKey: "searchField") as! UITextField).rx.textColor)
      .disposed(by: disposeBag)
  }

  fileprivate func setupBindings() {

    let items = viewModel.search(query: searchBar.rx.text
      .filterNil()
      .throttle(1.5, scheduler: MainScheduler.instance)
      .distinctUntilChanged())

    items
      .drive(tableView.rx.items) { [weak self] table, index, item in
        let cell: SearchCell = table.dequeue()
        cell.viewModel = self?.searchCellViewModelFactory(item)
        return cell
      }
      .disposed(by: disposeBag)
  }

}
