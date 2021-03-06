
import Foundation
import UIKit
import CoreLocation
import SnapKit

class HomeViewController: UIViewController {
    
    enum CurrentScreen {
        case prompts
        case categories
        case profile
    }
    
    fileprivate var currentViewController: UIViewController!
    fileprivate var currentScreen: CurrentScreen
    
    fileprivate var backgroundViewForStatusBar: UIView!
    fileprivate var customNavBar: CustomNavigationBar!
    fileprivate var createPromptButton: UIButton!
    
    fileprivate lazy var promptsViewController: PromptsListViewController = { [unowned self] in
        let vc = PromptsListViewController()
//        vc.collectionViewTopInset = self.customNavBar.height + self.tabBarView.height + 20
        return vc
    }()
    
    var engine: HomeBusinessLogic?
    var router: (HomeRoutingLogic & NSObjectProtocol)?
    
    init(currentScreen: HomeViewController.CurrentScreen) {
        self.currentScreen = currentScreen
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let viewController = self
        let engine = HomeEngine()
        let router = HomeRouter()
        viewController.engine = engine
        viewController.router = router
        router.viewController = viewController
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setupBackgroundViewForStatusBar()
        setupCustomNavigationBar()
        setupCreatePromptButton()
        setCurrentViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    fileprivate func setCurrentViewController() {
        switch currentScreen {
        case .prompts:
            currentViewController = promptsViewController
        case .categories:
            break
        case .profile:
            break
        }
        self.add(asChildViewController: currentViewController)
    }
 
}

//MARK: - Tab Bar Item Selected Functions

extension HomeViewController {
    
//    @objc fileprivate func didSelectLeftButton(_ sender: UIButton) {
//        guard currentTabButton != .categories else { return }
//        self.currentTabButton = .categories
//        self.switchViewController(for: self.currentTabButton)
//    }
//
//    @objc fileprivate func didSelectRightButton(_ sender: UIButton) {
//        guard currentTabButton != .profile else { return }
//        self.currentTabButton = .profile
//        self.switchViewController(for: self.currentTabButton)
//    }
    
    func didSelectProfileButton(_ sender: UIButton) {
        router?.routeToProfile()
    }
    
    func didSelectCreatePromptButton(_ sender: UIButton) {
        router?.routeToCreatePrompt()
    }
    
}

//MARK: - Switch View Controller Functions

extension HomeViewController {
    
    fileprivate func switchViewController(for tabBarItem: CurrentScreen) {
        switch currentScreen {
        case .prompts:
            switchTo(promptsViewController)
        case .categories:
            break
        case .profile:
            break
        }
    }
    
    fileprivate func switchTo(_ viewController: UIViewController) {
        guard let currentViewController = self.currentViewController else { return }
        self.remove(asChildViewController: currentViewController)
        self.add(asChildViewController: viewController)
    }
    
    fileprivate func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.insertSubview(viewController.view, belowSubview: createPromptButton)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.constrainEdges(to: self.view)
    }
    
    fileprivate func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
}

//MARK: - View Setup

extension HomeViewController {
    
    func setupBackgroundViewForStatusBar() {
        backgroundViewForStatusBar = UIView()
        backgroundViewForStatusBar.backgroundColor = UIColor.white
        
        view.addSubview(backgroundViewForStatusBar)
        backgroundViewForStatusBar.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(20)
        }
    }
    
    func setupCustomNavigationBar() {
        customNavBar = CustomNavigationBar(leftImage: nil, centerImage: nil, rightImage: #imageLiteral(resourceName: "IC_Profile"))
        customNavBar.rightButton.addTarget(self, action: #selector(didSelectProfileButton), for: .touchUpInside)
//        customNavBar.centerButton.addTarget(self, action: #selector(didSelectPostalCode), for: .touchUpInside)
        
        view.insertSubview(customNavBar, belowSubview: backgroundViewForStatusBar)
        customNavBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(backgroundViewForStatusBar.snp.bottom)
            make.height.equalTo(customNavBar.height)
        }
    }
    
    fileprivate func setupCreatePromptButton() {
        //MARK: - createPromptButton Properties
        createPromptButton = UIButton()
        createPromptButton.backgroundColor = UIColor.black
        createPromptButton.titleLabel?.font = FontBook.AvenirHeavy.of(size: 13)
        createPromptButton.setTitle("Create Prompt", for: .normal)
        createPromptButton.addTarget(self, action: #selector(didSelectCreatePromptButton), for: .touchUpInside)
        
        //MARK: - createPromptButton Constraints
        view.insertSubview(createPromptButton, belowSubview: customNavBar)
        createPromptButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(view)
            make.height.equalTo(60)
        }
    }
    
}



