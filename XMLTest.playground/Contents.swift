import Cocoa
import Foundation

let qcWorkLetter = XMLElement(name: "QCWorkLetter")
let xml = XMLDocument(rootElement: qcWorkLetter)
xml.version = "1.0"
xml.characterEncoding = "UTF-8"
qcWorkLetter.addChild(XMLElement(name: "VesselCode", stringValue: "TVS"))
print(xml.xmlString)
