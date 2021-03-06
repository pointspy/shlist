//
//  SceneDelegate.swift
//  Shlist
//
//  Created by Pavel Lyskov on 09.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import Storez
import UIKit

struct ProductsNamespace: Namespace {
    static let id = "products"
}

let store = UserDefaultsStore(suite: "io.pointspy.shlist")
var productsLastStoreValue = Key<ProductsNamespace, [Product]>(id: "lastitems", defaultValue: [])
var productsStoreValue = Key<ProductsNamespace, [Product]>(id: "saveitems", defaultValue: [])
var productsDictionaryValue = Key<ProductsNamespace, [Product]>(
    id: "dictionaryitems", defaultValue: [])

var categoryDictionaryValue = Key<ProductsNamespace, [Product]>(
    id: "categoryDictionaryItems", defaultValue: [])

var colorsDictionaryValue = Key<ProductsNamespace, [ColorTypeWrapper]>(
    id: "colorsdictionaryitems", defaultValue: [])

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        let itemsLast = store.get(productsLastStoreValue)

        Settings.Store.lastSearchDataSource.set(items: itemsLast)

        let items = store.get(productsStoreValue)

        Settings.Store.productsRepo.set(items: items)

        let dictionaryItems = store.get(productsDictionaryValue)

        if dictionaryItems.isEmpty {
            Settings.Store.Category.createDictionary()
        } else {
            Settings.Store.productDictionaryRepository.set(items: dictionaryItems)
        }

        let categoryDictionary = store.get(categoryDictionaryValue)

        if categoryDictionary.isEmpty {
            Settings.Store.selectedCategoryDataSource.initialCreate()
        } else {
            Settings.Store.selectedCategoryDataSource.setItems(categoryDictionary)
        }

        let colorsDictionary = store.get(colorsDictionaryValue)

        if colorsDictionary.isEmpty {
            Settings.Store.colorsDS.setInitial()
        } else {
            Settings.Store.colorsDS.set(items: colorsDictionary)
        }

//        if let vc = UIViewController.dl_topViewController() as? IconCollectionViewController {
//            vc.collectionView.reloadData()
//        }
        
        Settings.Store.saveItems(Settings.Store.productsRepo.allItems)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else {
            return
          }
        
        let items = Settings.Store.loadItems(from: urlContext.url)
        
        Settings.Store.productsRepo.set(items: items)
        
        store.set(productsStoreValue, value: items)
    }
}
