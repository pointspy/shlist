//
//  Rx+Ext.swift
//  Shlist
//
//  Created by Pavel Lyskov on 17.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import RxCocoa
import RxSwift

public final class RxSearchResultsUpdatingProxy: DelegateProxy<UISearchController, UISearchResultsUpdating>, UISearchResultsUpdating
{
    lazy var searchPhraseSubject = PublishSubject<String>()

    init(searchController: UISearchController) {
        super.init(parentObject: searchController, delegateProxy: RxSearchResultsUpdatingProxy.self)
    }

    public func updateSearchResults(for searchController: UISearchController) {
        searchPhraseSubject.onNext(searchController.searchBar.text ?? "")
    }
}

extension RxSearchResultsUpdatingProxy: DelegateProxyType {
    public static func currentDelegate(for object: UISearchController) -> UISearchResultsUpdating? {
        return object.searchResultsUpdater
    }

    public static func setCurrentDelegate(
        _ delegate: UISearchResultsUpdating?, to object: UISearchController
    ) {
        object.searchResultsUpdater = delegate
    }

    public static func registerKnownImplementations() {
        register { RxSearchResultsUpdatingProxy(searchController: $0) }
    }
}

extension Reactive where Base: UISearchController {
    public var delegate: DelegateProxy<UISearchController, UISearchResultsUpdating> {
        return RxSearchResultsUpdatingProxy.proxy(for: base)
    }

    public var searchPhrase: Observable<String> {
        return RxSearchResultsUpdatingProxy.proxy(for: base).searchPhraseSubject.asObservable()
    }
}
