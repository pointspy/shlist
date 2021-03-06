//
//  PyException.swift
//  SwiftyPyString
//

public enum PyException: Error {
    case AttributeError(String)
    case BaseException(String)
    case Exception(String)
    case ValueError(String)
    case KeyError(String)
    case IndexError(String)
    case TypeError(String)
    case SystemError(String)
    case OverflowError(String)
}

extension PyException: CustomStringConvertible {
    public var description: String {
        switch self {
        case .AttributeError(let msg):
            return "AttributeError: \(msg)"
        case .BaseException(let msg):
            return "BaseException: \(msg)"
        case .Exception(let msg):
            return "Exception: \(msg)"
        case .IndexError(let msg):
            return "IndexError: \(msg)"
        case .KeyError(let msg):
            return "KeyError: \(msg)"
        case .OverflowError(let msg):
            return "OverflowError: \(msg)"
        case .SystemError(let msg):
            return "SystemError: \(msg)"
        case .TypeError(let msg):
            return "TypeError: \(msg)"
        case .ValueError(let msg):
            return "ValueError: \(msg)"
        }
    }
}
