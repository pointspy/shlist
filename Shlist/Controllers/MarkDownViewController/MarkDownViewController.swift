//
//  MarkDownViewController.swift
//  Shlist
//
//  Created by Pavel Lyskov on 01.03.2021.
//  Copyright © 2021 Pavel Lyskov. All rights reserved.
//

import MarkdownView
import UIKit
import WebKit

final class MarkDownViewController: UIViewController {
    @IBOutlet weak var mdView: MarkdownView!
    
    lazy var closeButton = UIBarButtonItem(barButtonSystemItem: .close, handler: { [weak self] in
        guard let self = self else { return }
        self.dismiss(animated: true, completion: nil)
    })
    
    lazy var shareButton: UIBarButtonItem = {
        let image = UIImage(systemName: "square.and.arrow.up")
        
        let barButton = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(self.shareAction))
        
        return barButton
    }()
    
    var contentMd: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.mdView.load(markdown: self.contentMd)
            }
        }
    }
    
    var originalMarkDown: String = ""
    
    @objc func shareAction() {
        let sheet = UIAlertController(title: "\(NSLocalizedString("common.export", comment: ""))", message: "", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "\(NSLocalizedString("HomeViewcontroller.actionSheet.cancel", comment: ""))", style: .cancel, handler: nil)
        
        sheet.addAction(cancelAction)
        
        let copyAction = UIAlertAction(title: "\(NSLocalizedString("common.copy", comment: ""))", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            UIPasteboard.general.string = self.originalMarkDown
        })
        
        sheet.addAction(copyAction)
        
        let exportMdFileAction = UIAlertAction(title: "\(NSLocalizedString("markdown.export.file", comment: ""))", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
             
            var filesToShare = [Any]()

            // Add the path of the text file to the Array
            filesToShare.append(Settings.Store.tasksMarkDownURL)

            // Make the activityViewContoller which shows the share-view
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            // Show the share-view
            self.present(activityViewController, animated: true, completion: nil)

        })
        
        let exportTextAction = UIAlertAction(title: "\(NSLocalizedString("markdown.export.text", comment: ""))", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
             
            var filesToShare = [Any]()

            // Add the path of the text file to the Array
            filesToShare.append(self.originalMarkDown)

            // Make the activityViewContoller which shows the share-view
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            // Show the share-view
            self.present(activityViewController, animated: true, completion: nil)

        })
        
        
        sheet.addAction(exportTextAction)
        sheet.addAction(exportMdFileAction)
        
        if #available(iOS 14, *) {
            let exportPdfAction = UIAlertAction(title: "\(NSLocalizedString("markdown.export.pdf", comment: ""))", style: .default, handler: { [weak self] _ in
                guard let self = self, let webView = self.mdView.webView else { return }
            
                let config = WKPDFConfiguration()
            
                webView.createPDF(configuration: config) { result in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let data):
                        do {
                            try self.savePdf(with: data)
                            self.loadPDFAndShare()
                        } catch {
                            print("error")
                        }
                    }
                }
                
            })
            sheet.addAction(exportPdfAction)
        }
        
        self.present(sheet, animated: true, completion: nil)
    }
    
    func savePdf(with data: Data) throws {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let pdfDocURL = documentsURL.appendingPathComponent("shlistexportfile.pdf")
        
        try data.write(to: pdfDocURL)
    }
    
    func loadPDFAndShare() {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let pdfDocURL = documentsURL.appendingPathComponent("shlistexportfile.pdf")
                
            let document = NSData(contentsOf: pdfDocURL)
            let activityViewController = UIActivityViewController(activityItems: [document!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
            
        } catch {
            print("document was not found")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Markdown"
        navigationItem.rightBarButtonItems = [self.closeButton, self.shareButton]
//        navigationItem.leftBarButtonItem = shareButton
        
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension MarkDownViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.dark)
                
            } else {
                Settings.Colors.themeService.switch(Settings.Colors.ThemeType.light)
            }
            view.backgroundColor = .systemBackground
        }
    }
}
