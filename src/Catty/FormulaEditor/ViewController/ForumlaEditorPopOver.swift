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

@objc enum FormulaPopOverType: Int {
    case none
    case functions
    case object
    case logic
    case sensors
    case data
}

@objc class FormulaEditorPopOver: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private var navigationBar: UINavigationBar!
    @IBOutlet private var addButton: UIBarButtonItem!
    @objc var formulaEditorVC: FormulaEditorViewController?
    @objc var formulaPopOverType: FormulaPopOverType = .none
    @objc var formulaManager: FormulaManager?
    @objc var spriteObject: SpriteObject?

    private var items = [FormulaEditorItem]()
    private var numberOfSections = 0
    private var numberOfRowsInSection = [Int]()
    private var titlesOfSections = [String]()

    private var variableSourceProject = [UserVariable]()
    private var variableSourceObject = [UserVariable]()
    private var listSourceProject = [UserList]()
    private var listSourceObject = [UserList]()

    private var newVarIsForProject = false

    convenience init(formulaPopOverType: FormulaPopOverType, formulaManager: FormulaManager, spriteObject: SpriteObject) {
        self.init()

        self.formulaPopOverType = formulaPopOverType
        self.formulaManager = formulaManager
        self.spriteObject = spriteObject
    }

    @IBOutlet private weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        self.reloadData()
    }

    private func reloadData() {
        numberOfSections = 0
        titlesOfSections.removeAll()
        self.navigationBar.items?.first?.rightBarButtonItems = nil

        switch formulaPopOverType {
        case .functions:
            self.initFunctionItems()

        case .object:
            self.initObjectItems()

        case .logic:
            self.initLogicItems()

        case .sensors:
            self.initSensorItems()

        case .data:
            self.initDataItems()
            self.navigationBar.items?.first?.rightBarButtonItems = [self.addButton]

        case .none:
            self.presentUnexpectedErrorAlert()
        }

        self.tableView.reloadData()
    }

    @IBAction private func addButtonTapped(_ sender: Any) {
        AlertController(title: kUIFEVarOrList, message: nil, style: .actionSheet)
        .addCancelAction(title: kLocalizedCancel, handler: nil)
        .addDefaultAction(title: kUIFENewVar) {
            self.askProjectOrObject(isList: false)
        }
        .addDefaultAction(title: kUIFENewList) {
        self.askProjectOrObject(isList: true)
        }.build().showWithController(self)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        self.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titlesOfSections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if formulaPopOverType == .data {
            switch section {
            case 0:
                return variableSourceProject.count
            case 1:
                return variableSourceObject.count
            case 2:
                return listSourceProject.count
            case 3:
                return listSourceObject.count
            default:
                return 0
            }
        }

        return self.numberOfRowsInSection[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()

        if self.formulaPopOverType == .data {

            if indexPath.section == 0 {
                tableViewCell.textLabel?.text = variableSourceProject[indexPath.row].name
            } else if indexPath.section == 1 {
                tableViewCell.textLabel?.text = variableSourceObject[indexPath.row].name
            } else if indexPath.section == 2 {
                tableViewCell.textLabel?.text = listSourceProject[indexPath.row].name
            } else if indexPath.section == 3 {
                tableViewCell.textLabel?.text = listSourceObject[indexPath.row].name
            }

        } else {
            var previousRows = 0

            for n in 1..<indexPath.section + 1 {
                previousRows += self.numberOfRowsInSection[n - 1]
            }

            tableViewCell.textLabel?.text = items[previousRows + indexPath.row].title
        }

        return tableViewCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if formulaPopOverType == .data {
            let buttonType: Int32 = indexPath.section <= 1 ? 0 : 11
            let variableName = tableView.cellForRow(at: indexPath)?.textLabel?.text
            self.formulaEditorVC?.internFormula.handleKeyInput(withName: variableName, buttonType: buttonType)
            self.formulaEditorVC?.handleInput()
        } else {
            var previousRows = 0

            for n in 1..<indexPath.section + 1 {
                previousRows += self.numberOfRowsInSection[n - 1]
            }

            self.formulaEditorVC?.formulaEditorItemSelected(item: self.items[previousRows + indexPath.row])
        }

        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if formulaPopOverType == .data {
            let tableViewRowAction = UITableViewRowAction(style: .destructive,
                                                          title: "Delete") { _, indexPath in

                                                            switch indexPath.section {

                                                            case 0:
                                                                let variable = self.variableSourceProject[indexPath.row]
                                                                if !self.isVariableInUse(userVariable: variable) {
                                                                    self.deleteVariable(userVariable: variable, isProjectVariable: true)
                                                                } else {
                                                                    Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                                }

                                                            case 1:
                                                                let variable = self.variableSourceObject[indexPath.row]
                                                                if !self.isVariableInUse(userVariable: variable) {
                                                                    self.deleteVariable(userVariable: variable, isProjectVariable: false)
                                                                } else {
                                                                    Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                                }

                                                            case 2:
                                                                let list = self.listSourceProject[indexPath.row]
                                                                if !self.isListInUse(userList: list) {
                                                                    self.deleteList(userList: list, isProjectList: true)
                                                                } else {
                                                                    Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                                }

                                                            case 3:
                                                                let list = self.listSourceObject[indexPath.row]
                                                                if !self.isListInUse(userList: list) {
                                                                    self.deleteList(userList: list, isProjectList: false)
                                                                } else {
                                                                    Util.showNotification(withMessage: kUIFEDeleteVarBeingUsed)
                                                                }

                                                            default:
                                                                fatalError("Data cannot have section index greater than 3")

                                                            }

            }

            return [tableViewRowAction]
        }

        return nil
    }

    @IBAction private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func askProjectOrObject(isList: Bool) {
        let promptTitle = isList ? kUIFEActionList : kUIFEActionVar

        AlertController(title: promptTitle, message: nil, style: .actionSheet)
            .addCancelAction(title: kLocalizedCancel, handler: nil)
            .addDefaultAction(title: kUIFEActionVarPro) {
                if isList {
                    self.addNewList(isProjectList: true)
                } else {
                    self.addNewVariable(isProjectVariable: true)
                }
            }
            .addDefaultAction(title: kUIFEActionVarObj) {
            if isList {
                self.addNewList(isProjectList: false)
                } else {
                self.addNewVariable(isProjectVariable: false)
                }
            }.build().showWithController(self)
    }

    private func addNewList(isProjectList: Bool) {
        self.newVarIsForProject = isProjectList
        Util.askUser(forVariableNameAndPerformAction: #selector(saveList(name:)),
                     target: self,
                     promptTitle: kUIFENewList,
                     promptMessage: kUIFEListName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: true,
                     andTextField: nil,
                     initialText: "")
    }

    private func addNewVariable(isProjectVariable: Bool) {
        self.newVarIsForProject = isProjectVariable
        Util.askUser(forVariableNameAndPerformAction: #selector(saveVariable(name:)),
                     target: self,
                     promptTitle: kUIFENewVar,
                     promptMessage: kUIFEVarName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: false,
                     andTextField: nil,
                     initialText: "")

    }

    private func askForNewVariableName() {
        Util.askUser(forVariableNameAndPerformAction: #selector(saveVariable(name:)),
                     target: self,
                     promptTitle: kUIFENewVarExists,
                     promptMessage: kUIFEOtherName,
                     minInputLength: UInt(kMinNumOfVariableNameCharacters),
                     maxInputLength: UInt(kMaxNumOfVariableNameCharacters),
                     isList: false,
                     andTextField: nil,
                     initialText: "")
    }

    @objc private func saveVariable(name: String) {
        if self.newVarIsForProject {
            if let project = self.spriteObject?.scene.project {
                for variable in UserDataContainer.allVariables(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            if let object = self.spriteObject {
                for variable in UserDataContainer.objectAndProjectVariables(for: object) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        }

        let userVariable = UserVariable(name: name)
        userVariable.value = Int(0)

        if self.newVarIsForProject {
            self.spriteObject?.scene.project?.userData.add(userVariable)
        } else {
            self.spriteObject?.userData.add(userVariable)
        }

        self.spriteObject?.scene.project?.saveToDisk(withNotification: true)
        self.reloadData()
    }

    @objc private func saveList(name: String) {
        if self.newVarIsForProject {
            if let project = self.spriteObject?.scene.project {
                for variable in UserDataContainer.allLists(for: project) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        } else {
            if let object = self.spriteObject {
                for variable in UserDataContainer.objectAndProjectLists(for: object) where variable.name == name {
                    self.askForNewVariableName()
                    return
                }
            }
        }

        let userList = UserList(name: name)

        if self.newVarIsForProject {
            self.spriteObject?.scene.project?.userData.add(userList)
        } else {
            self.spriteObject?.userData.add(userList)
        }

        self.spriteObject?.scene.project?.saveToDisk(withNotification: true)
        self.reloadData()
    }

    private func isVariableInUse(userVariable: UserVariable) -> Bool {

        guard let project = self.spriteObject?.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userVariable) {

            if let objects = self.spriteObject?.scene.objects() {

                for object in objects {

                    for scriptElement in object.scriptList {
                        if let script = scriptElement as? Script {

                            for brickElement in script.brickList where brickElement is Brick {
                                if let brick = brickElement as? Brick {
                                    if brick.isVariableUsed(variable: userVariable) {
                                        return true
                                    }
                                }
                            }

                        }
                    }

                }
            }
        } else {
            if let object = spriteObject {
                for scriptElement in object.scriptList {
                    if let script = scriptElement as? Script {

                        for brickElement in script.brickList where brickElement is Brick {
                            if let brick = brickElement as? Brick {
                                if brick.isVariableUsed(variable: userVariable) {
                                    return true
                                }
                            }
                        }

                    }
                }
            }
        }

        return false
    }

    private func isListInUse(userList: UserList) -> Bool {

        guard let project = self.spriteObject?.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if project.userData.contains(userList) {

            if let objects = self.spriteObject?.scene.objects() {

                for object in objects {

                    for scriptElement in object.scriptList {
                        if let script = scriptElement as? Script {

                            for brickElement in script.brickList where brickElement is Brick {
                                if let brick = brickElement as? Brick {
                                    if brick.isListUsed(list: userList) {
                                        return true
                                    }
                                }
                            }

                        }
                    }

                }
            }
        } else {
            if let object = spriteObject {
                for scriptElement in object.scriptList {
                    if let script = scriptElement as? Script {

                        for brickElement in script.brickList where brickElement is Brick {
                            if let brick = brickElement as? Brick {
                                if brick.isListUsed(list: userList) {
                                    return true
                                }
                            }
                        }

                    }
                }
            }
        }

        return false
    }

    private func deleteVariable(userVariable: UserVariable, isProjectVariable: Bool) {
        guard let object = self.spriteObject else {
            fatalError("spriteObject is nil")
        }

        guard let project = object.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if !object.userData.removeUserVariable(identifiedBy: userVariable.name) {
            if !project.userData.removeUserVariable(identifiedBy: userVariable.name) {
                fatalError("Could not remove the variable")
            }
        }

        project.saveToDisk(withNotification: true)
        self.reloadData()
    }

    private func deleteList(userList: UserList, isProjectList: Bool) {
        guard let object = self.spriteObject else {
            fatalError("spriteObject is nil")
        }

        guard let project = object.scene.project else {
            fatalError("project of the spriteObject is nil")
        }

        if !object.userData.removeUserList(identifiedBy: userList.name) {
            if !project.userData.removeUserList(identifiedBy: userList.name) {
                fatalError("Could not remove the list")
            }
        }

        project.saveToDisk(withNotification: true)
        self.reloadData()
    }

    private func initFunctionItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForMathSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupMathSubsectionWiseAndGetSize(items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [MathSubsection.maths.title, MathSubsection.texts.title, MathSubsection.lists.title]
    }

    private func initLogicItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForLogicSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupLogicSubsectionWiseAndGetSize(items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [LogicSubsection.logical.title, LogicSubsection.comparison.title]

    }

    private func initObjectItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForObjectSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupObjectSubsectionWiseAndGetSize(items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [ObjectSubsection.general.title, ObjectSubsection.motion.title]

    }

    private func initSensorItems() {
        self.items.removeAll()

        if let object = spriteObject, let manager = formulaManager {
            self.items = manager.formulaEditorItemsForDeviceSection(spriteObject: object)
        }

        self.numberOfRowsInSection = self.groupDeviceSubsectionWiseAndGetSize(items: &items)
        self.numberOfSections = numberOfRowsInSection.count
        self.titlesOfSections = [DeviceSubsection.device.title, DeviceSubsection.touch.title, DeviceSubsection.visual.title, DeviceSubsection.dateAndTime.title]
    }

    private func groupMathSubsectionWiseAndGetSize(items: inout [FormulaEditorItem]) -> [Int] {

        var sizes = [Int]()
        let dict = Dictionary(grouping: items, by: { $0.sections[0].mathSubsection() })
        items.removeAll()

        if let groupedItems = dict[MathSubsection.maths] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[MathSubsection.texts] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[MathSubsection.lists] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        return sizes
    }

    private func groupLogicSubsectionWiseAndGetSize(items: inout [FormulaEditorItem]) -> [Int] {

        var sizes = [Int]()
        let dict = Dictionary(grouping: items, by: { $0.sections[0].logicSubsection() })
        items.removeAll()

        if let groupedItems = dict[LogicSubsection.logical] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[LogicSubsection.comparison] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        return sizes
    }

    private func groupObjectSubsectionWiseAndGetSize(items: inout [FormulaEditorItem]) -> [Int] {

        var sizes = [Int]()
        let dict = Dictionary(grouping: items, by: { $0.sections[0].objectSubsection() })
        items.removeAll()

        if let groupedItems = dict[ObjectSubsection.general] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[ObjectSubsection.motion] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        return sizes
    }

    private func groupDeviceSubsectionWiseAndGetSize(items: inout [FormulaEditorItem]) -> [Int] {

        var sizes = [Int]()
        let dict = Dictionary(grouping: items, by: { $0.sections[0].deviceSubsection() })
        items.removeAll()

        if let groupedItems = dict[DeviceSubsection.device] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[DeviceSubsection.touch] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[DeviceSubsection.visual] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }

        if let groupedItems = dict[DeviceSubsection.dateAndTime] {
            items.append(contentsOf: groupedItems)
            sizes.append(groupedItems.count)
        }
        return sizes
    }

    private func initDataItems() {
        self.variableSourceProject.removeAll()
        self.variableSourceObject.removeAll()
        self.listSourceProject.removeAll()
        self.listSourceObject.removeAll()

        self.updateUserVariablesAndLists()

        numberOfSections = 4
        titlesOfSections = [kUIFEProjectVariables, kUIFEObjectVariables, kUIFEProjectLists, kUIFEObjectLists]
    }

    private func updateUserVariablesAndLists() {

        guard let object = self.spriteObject else {
            self.presentUnexpectedErrorAlert()
            return
        }

        guard let project = object.scene.project else {
            self.presentUnexpectedErrorAlert()
            return
        }

        self.variableSourceProject = project.userData.variables()
        self.listSourceProject = project.userData.lists()
        self.variableSourceObject = UserDataContainer.objectVariables(for: object)
        self.listSourceObject = UserDataContainer.objectLists(for: object)

    }

    private func presentUnexpectedErrorAlert() {
        let alert = UIAlertController(title: "Some unexpected error occured", message: nil, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }

}
