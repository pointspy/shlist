//
//  RT_Objects+Mirror.swift
//  OnLime
//
//  Created by Лысков Павел on 12.03.2020.
//  Copyright © 2020 Dart-IT. All rights reserved.
//
import UIKit


public final class TestVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
    }
}


// DITableViewItem

//
@objc
public final class ObjectiveLogger: NSObject {
    @objc static var shared = ObjectiveLogger()

    static var isConsoleCreated: Bool = false

    static var highlightr: Highlightr? = {
        guard let highlightr = Highlightr() else {
            return nil
        }
        highlightr.setTheme(to: "monokai-sublime")
        return highlightr
    }()

    static var consoleVC: UIViewController = UIViewController()
    static var window: RTWindow = {
        let w = RTWindow(with: UIViewController())
        w.isAbleToReceiveTouches = true
        w.backgroundColor = .clear
        return w
    }()

    @objc static func logJson(forReflected item: AnyObject) {
        if let dict = SuperMirrorLogger.toJsonDictionary(for: item) {
            let json = dict.json

            print("JSON for instanse of type \(type(of: item)) \n")
            print(json)
            print("-------")
        }
    }

    /**
     Log to tiny console.
      - **main** method for log in tiny console. Supports *Swift* and *Objective-C*.
      - Parameter item: any type comform for **JSONSerializable**.
      - Parameter debugTitle: text label for debug.
     */

    @objc static func logToTiny(forReflected item: Any?, debugTitle: String? = nil) {
        DispatchQueue.main.async {
            setConsoleVC()

            TinyConsole.setHeight(height: UIScreen.main.bounds.height - 60)

            if let title = debugTitle {
                var attrTitle = "\(title)".at.attributed {
                    $0.foreground(color: .systemPink).font(.systemFont(ofSize: 15, weight: .semibold))
                }
                let head = "\n## Debug title: ".at.attributed {
                    $0.foreground(color: UIColor(white: 0.7, alpha: 1)).font(.systemFont(ofSize: 15, weight: .semibold))
                }
                attrTitle = head + attrTitle
                TinyConsole.printWithoutTime(attrTitle)
            }
        }

        guard let item = item else {
            DispatchQueue.main.async {
                let errorMessage = "Item is NIL".at.attributed {
                    $0.foreground(color: UIColor.systemRed).font(.systemFont(ofSize: 16, weight: .bold))
                }
                TinyConsole.printWithoutTime(errorMessage)
            }

            return
        }

        let codeStart = "```json\n".at.attributed {
            $0.font(SuperMirrorLogger.Fonts.comment).foreground(color: SuperMirrorLogger.Colors.comment)
        }

        let codeEnd = "\n```".at.attributed {
            $0.font(SuperMirrorLogger.Fonts.comment).foreground(color: SuperMirrorLogger.Colors.comment)
        }

        DispatchQueue.main.async {
            if let dict = SuperMirrorLogger.toJsonDictionary(for: item) {
                let json = dict.json
                if let highlightr = self.highlightr, let highlightedJson = highlightr.highlight(json, as: "json") {
                    var final = "\n### Instance of type ".at.attributed {
                        $0.font(SuperMirrorLogger.Fonts.comment).foreground(color: SuperMirrorLogger.Colors.comment)
                    }
                    final = final + "\(type(of: item)) : \n".at.attributed {
                        $0.foreground(color: SuperMirrorLogger.Colors.number).font(SuperMirrorLogger.Fonts.title)
                    }

                    final = final + codeStart + highlightedJson + codeEnd
                    TinyConsole.printWithoutTime(final)
                }

            } else if let item = item as? [NSObject] {
                  
                do {
                    let json = try item.toJSON()
                    if let jsonStr = json as? String {
                        if let highlightr = self.highlightr, let highlightedJson = highlightr.highlight(
                            jsonStr,
                            as: "json"
                        ) {
                            var final = "\n### Instance of type ".at.attributed {
                                $0.font(SuperMirrorLogger.Fonts.comment)
                                    .foreground(color: SuperMirrorLogger.Colors.comment)
                            }
                            final = final + "\(type(of: item)) : \n".at.attributed {
                                $0.foreground(color: SuperMirrorLogger.Colors.number)
                                    .font(SuperMirrorLogger.Fonts.title)
                            }

                            final = final + codeStart + highlightedJson + codeEnd
                            TinyConsole.printWithoutTime(final)
                        }
                    }
                } catch {}
            }
        }
    }

    

    

    @objc static func setConsoleVC() {
//        if !isConsoleCreated {
        let tempVC = consoleVC
        DispatchQueue.main.async {
            ObjectiveLogger.window.rootViewController = TinyConsole.createViewController(rootViewController: tempVC)

            ObjectiveLogger.window.makeKeyAndVisible()
        }

        isConsoleCreated = true
//        }
    }
}


class RT_Egg: NSObject, JSONSerializable {
    let from: NSDate
    let to: Date

    init(from: NSDate, to: Date) {
        self.from = from
        self.to = to
    }
}

struct YY: JSONSerializable {
    let y: Double
    let color: UIColor = UIColor.systemBlue
}

struct Sample: JSONSerializable {
    let text: String = "JSONSerializable"
    let attr: NSAttributedString = "JSONSerializable".at.attributed {
        $0.font(.boldSystemFont(ofSize: 15)).foreground(color: .orange)
    }
}

class MirrorTest: NSObject, JSONSerializable {
    @objc let x: NSNumber
    @objc let y: NSNumber
    let sample: Sample = Sample()
    var items: [RT_Egg] = [
        RT_Egg(from: NSDate(), to: Date()),
        RT_Egg(from: NSDate(timeInterval: 100, since: Date()), to: Date(timeInterval: 10000, since: Date())),
    ]
    let yy: YY = YY(y: -456.0)

    init(x: Int, y: Int) {
        self.x = NSNumber(value: x)
        self.y = NSNumber(value: y)
        super.init()
    }
}
