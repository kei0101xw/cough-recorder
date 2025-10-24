import SwiftUI

enum AppUI {

    private enum Phone {
        static let titleFont: CGFloat         = 20
        static let sectionHeaderFont: CGFloat = 18
        static let fieldFont: CGFloat         = 15
        static let fieldHeight: CGFloat       = 35
        static let pickFormHeight: CGFloat    = 23
        static let buttonFont: CGFloat        = 16
        static let buttonHeight: CGFloat      = 40
        static let sentenceFont: CGFloat      = 14
    }

    private enum Pad {
        static let titleFont: CGFloat         = 30
        static let sectionHeaderFont: CGFloat = 24
        static let fieldFont: CGFloat         = 22
        static let fieldHeight: CGFloat       = 70
        static let pickFormHeight: CGFloat    = 45
        static let buttonFont: CGFloat        = 32
        static let buttonHeight: CGFloat      = 60
        static let sentenceFont: CGFloat      = 20
    }

    static func titleFontSize(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.titleFont : Pad.titleFont
    }
    static func sectionHeaderFontSize(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.sectionHeaderFont : Pad.sectionHeaderFont
    }
    static func fieldFontSize(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.fieldFont : Pad.fieldFont
    }
    static func fieldHeight(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.fieldHeight : Pad.fieldHeight
    }
    static func pickFormHeight(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.pickFormHeight : Pad.pickFormHeight
    }
    static func buttonFontSize(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.buttonFont : Pad.buttonFont
    }
    static func buttonHeight(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.buttonHeight : Pad.buttonHeight
    }
    static func sentenceFontSize(hSize: UserInterfaceSizeClass?) -> CGFloat {
        (hSize == .compact) ? Phone.sentenceFont : Pad.sentenceFont
    }
}
