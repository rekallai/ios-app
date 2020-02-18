//
//  OnboardPageViewController.swift
//  Rekall
//
//  Created by Steve on 10/3/19.
//  Copyright © 2020 Rekall. All rights reserved.
//

import UIKit

protocol OnboardPageDelegate: class {
    func changedPage(_ page: Int)
}

class OnboardPageViewController: UIPageViewController {

    weak var pageDelegate: OnboardPageDelegate?
    
    lazy var subVCs: [UIViewController] = {
        return [
            getViewController(id: "InterestsViewController"),
            getViewController(id: "LocationServicesViewController"),
            getViewController(id: "PushNotificationsViewController")
        ]
    }()
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subVCs[0]], direction: .forward, animated: true, completion: nil)
        configPageControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    func getViewController(id: String)->UIViewController {
        let sb = UIStoryboard(name: "Onboarding", bundle: nil)
        return sb.instantiateViewController(withIdentifier: id)
    }
    
    func configPageControl() {
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = UIColor(named: "ButtonBackground")
        pageControl.pageIndicatorTintColor = .lightGray
    }
    
    func toNextPage() {
        guard let vc = viewControllers?.first else { return }
        guard let nextVC = dataSource?.pageViewController(self, viewControllerAfter: vc) else { return }
        currentIndex += 1
        setViewControllers([nextVC], direction: .forward, animated: true) { _ in
            self.pageDelegate?.changedPage(self.currentIndex)
        }
    }

}

extension OnboardPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subVCs.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = subVCs.firstIndex(of: viewController) else { return nil }
        return (index <= 0) ? nil : subVCs[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = subVCs.firstIndex(of: viewController) else { return nil }
        return (index >= subVCs.count - 1) ? nil : subVCs[index + 1]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = viewControllers?.first else { return }
        guard let vcIndex = subVCs.firstIndex(of: vc) else { return }
        if completed {
            currentIndex = vcIndex
            self.pageDelegate?.changedPage(currentIndex)
        }
    }
    
}
