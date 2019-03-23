import UIKit
import RxSwift

class ViewController<ViewModel>: UIViewController, StoryboardInstantiable {

  var themedStatusBarStyle: UIStatusBarStyle?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return themedStatusBarStyle ?? super.preferredStatusBarStyle
  }

  var viewModel: ViewModel!

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    themes.rx
      .bind({ $0.backgroundColor }, to: view.rx.backgroundColor)
      .disposed(by: disposeBag)

    themes.attrsStream
      .subscribe(onNext: { [weak self] theme in
        self?.themedStatusBarStyle = theme.statusBarStyle
        self?.setNeedsStatusBarAppearanceUpdate()
      })
      .disposed(by: disposeBag)
  }

}
