import UIKit

protocol Module {
    associatedtype InputType
    var view: UIViewController { get }
    var input: InputType { get }
}
