/**
 *  Copyright (C) 2010-2020 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

protocol FormulaEditorSubsection {
    var title: String { get }
}

enum MathSubsection: FormulaEditorSubsection {
    var title: String {
        switch self {
        case .maths:
            return kUIFESubsectionMaths

        case .lists:
            return kUIFESubsectionLists

        case .texts:
            return kUIFESubsectionTexts

        default:
            return ""
        }
    }

    case none
    case maths
    case texts
    case lists
}

enum ObjectSubsection: FormulaEditorSubsection {
    var title: String {
        switch self {
        case .general:
            return kUIFESubsectionGeneral

        case .motion:
            return kUIFESubsectionMotion

        default:
            return ""
        }
    }

    case none
    case general
    case motion
}

enum LogicSubsection: FormulaEditorSubsection {
    var title: String {
        switch self {
        case .logical:
            return kUIFESubsectionLogical

        case .comparison:
            return kUIFESubsectionComprison

        default:
            return ""
        }
    }

    case none
    case logical
    case comparison
}

enum DeviceSubsection: FormulaEditorSubsection {
    var title: String {
        switch self {
        case .device:
            return kUIFESubsectionDeviceSensors

        case .touch:
            return kUIFESubsectionTouchDetection

        case .visual:
            return kUIFESubsectionVisualSensors

        case .dateAndTime:
            return kUIFESubsectionDataAndTime

        default:
            return ""
        }
    }

    case none
    case device
    case touch
    case visual
    case dateAndTime
}
