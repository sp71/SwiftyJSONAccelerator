//
//  GlossModelFile.swift
//  SwiftyJSONAccelerator
//
//  Created by Karthikeya Udupa on 02/06/16.
//  Copyright © 2016 Karthikeya Udupa K M. All rights reserved.
//

import Foundation

/**
 *  Provides support for SwiftyJSON library.
 */
struct GlossModelFile: ModelFile, DefaultModelFileComponent {

    var fileName: String
    var type: ConstructType
    var component: ModelComponent
    var sourceJSON: JSON
    var configuration: ModelGenerationConfiguration?

    // MARK: - Initialisers.
    init() {
        self.fileName = ""
        type = ConstructType.StructType
        component = ModelComponent.init()
        sourceJSON = JSON.init([])
    }

    mutating func setInfo(_ fileName: String, _ configuration: ModelGenerationConfiguration) {
        self.fileName = fileName
        type = configuration.constructType
        self.configuration = configuration
    }

    func moduleName() -> String {
        return "Gloss"
    }

    func baseElementName() -> String? {
        return "Decodable"
    }

    func mainBodyTemplateFileName() -> String {
        return "GlossTemplate"
    }

    mutating func generateAndAddComponentsFor(_ property: PropertyComponent) {
        switch property.propertyType {
        case .ValueType:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.initialisers.append(genInitializerForVariable(property.name, property.type, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.description.append(genDescriptionForPrimitive(property.name, property.type, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
        case .ValueTypeArray:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.initialisers.append(genInitializerForPrimitiveArray(property.name, property.type, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
        case .ObjectType:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.initialisers.append(genInitializerForObject(property.name, property.type, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, false))
            component.description.append(genDescriptionForObject(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, false))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
        case .ObjectTypeArray:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.initialisers.append(genInitializerForObjectArray(property.name, property.type, property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, property.type, true))
            component.description.append(genDescriptionForObjectArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, property.type, property.constantName, true))
            component.encoders.append(genEncoder(property.name, property.type, property.constantName))
        case .EmptyArray:
            component.stringConstants.append(genStringConstant(property.constantName, property.key))
            component.initialisers.append(genInitializerForPrimitiveArray(property.name, "object", property.constantName))
            component.declarations.append(genVariableDeclaration(property.name, "Any", true))
            component.description.append(genDescriptionForPrimitiveArray(property.name, property.constantName))
            component.decoders.append(genDecoder(property.name, "Any", property.constantName, true))
            component.encoders.append(genEncoder(property.name, "Any", property.constantName))
        case .NullType:
            // Currently we do not deal with null values.
            break
        }
    }

    func genPrimitiveVariableDeclaration(_ name: String, _ type: String) -> String {
        return "var \(name): \(type)"
    }

    // MARK: - Customised methods for SWiftyJSON
    // MARK: - Initialisers
    func genInitializerForVariable(_ name: String, _ type: String, _ constantName: String) -> String {
        return "guard let \(name): \(type) = \(constantName) <~~ json else {\n\t\tprint(\"\(fileName) \(name) could not be found\")\n\t\treturn nil\n\t}\n\tself.\(name) = \(name)"
    }

    func genInitializerForObject(_ name: String, _ type: String, _ constantName: String) -> String {
        return "guard let \(name): \(type) = \(constantName) <~~ json else {\n\t\tprint(\"\(fileName) \(name) could not be found\")\n\t\treturn nil\n\t}\n\tself.\(name) = \(name)"
    }

    func genInitializerForObjectArray(_ name: String, _ type: String, _ constantName: String) -> String {
        return "guard let \(name): \(type) = \(constantName) <~~ json else {\n\t\tprint(\"\(fileName) \(name) could not be found\")\n\t\treturn nil\n\t}\n\tself.\(name) = \(name)"
    }

    func genInitializerForPrimitiveArray(_ name: String, _ type: String, _ constantName: String) -> String {
        return "guard let \(name): \(type) = \(constantName) <~~ json else {\n\t\tprint(\"\(fileName) \(name) could not be found\")\n\t\treturn nil\n\t}\n\tself.\(name) = \(name)"
    }

    func genDescriptionForPrimitive(_ name: String, _ type: String, _ constantName: String) -> String {
        if type == VariableType.Bool.rawValue {
            return "dictionary[\(constantName)] = \(name)"
        }
        return "if let value = \(name) { dictionary[\(constantName)] = value }"
    }

}
