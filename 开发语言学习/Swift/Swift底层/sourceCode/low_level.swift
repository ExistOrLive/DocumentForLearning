//
//  main.swift
//  SwiftTest
//
//  Created by 朱猛 on 2020/11/2.
//

import Foundation

// low level structure

// HeapObject ClassMetadata ClassDescription
struct HeapObject{
    var metadata : UnsafePointer<ClassMetadata>
    var refCount1 : Int32
    var refCount2 : Int32
}

struct ClassMetadata{
    var kind: UnsafeRawPointer
    var superClass:UnsafeRawPointer
    var cacheData1:UnsafeRawPointer
    var cacheData2:UnsafeRawPointer
    var data:UnsafeRawPointer

    var flags:UInt32
    var instanceAddressOffset:UInt32
    var instanceSize:UInt32
    var instanceAlignMask:UInt16
    var reserved:UInt16

    var classSize:UInt32
    var classAddressOffset:UInt32
    var Description:UnsafeMutablePointer<ClassDescription>
}

struct ClassDescription{
    var Flags : Int32
    var Parent : RelativePointer<UnsafeRawPointer>
    var Name : RelativePointer<CChar>
    var AccessFunctionPtr : RelativePointer<UnsafeRawPointer>
    var Fields : RelativePointer<FieldDescrition>
    var SuperclassType : RelativePointer<CChar>
    var NumImmediateMembers : UInt32
    var NumFields : UInt32
    var FieldOffsetVectorOffset : UInt32
}

// StructMetadata  StructDescription
struct StructMetadata{
    var kind: UnsafeRawPointer
    var Description:UnsafeMutablePointer<StructDescription>
}

struct StructDescription{
    var Flags : Int32
    var Parent : RelativePointer<UnsafeRawPointer>
    var Name : RelativePointer<CChar>
    var AccessFunctionPtr : RelativePointer<UnsafeRawPointer>
    var Fields : RelativePointer<FieldDescrition>
    var NumFields : UInt32
    var FieldOffsetVectorOffset : UInt32
}



// EnumMetadata  EnumDescription
struct EnumMetadata{
    var kind: UnsafeRawPointer
    var Description:UnsafeMutablePointer<EnumDescription>
}

struct EnumDescription{
    var Flags : Int32
    var Parent : RelativePointer<UnsafeRawPointer>
    var Name : RelativePointer<CChar>
    var AccessFunctionPtr : RelativePointer<UnsafeRawPointer>
    var Fields : RelativePointer<FieldDescrition>
    var NumPayloadCasesAndPayloadSizeOffset : UInt32
    var NumEmptyCases : UInt32
}

struct RelativePointer<T> {
    var offset : Int32

    mutating func get() -> UnsafeMutablePointer<T> {
        let tmpOffset = offset
        return withUnsafePointer(to: &self) {
            UnsafeMutableRawPointer(mutating: $0).advanced(by: Int(tmpOffset)).assumingMemoryBound(to: T.self)
        }
    }
}


struct FieldDescrition{
    var MangledTypeName : RelativePointer<CChar>
    var superClasss : RelativePointer<CChar>
    var FieldDescriptorKind : UInt16
    var FieldRecordSize : UInt16
    var NumFields : UInt32

    mutating func getFieldRecordPtr() -> UnsafeMutablePointer<FieldRecord> {
        return withUnsafeMutablePointer(to: &self) {
            let ptr = $0.advanced(by: 1)
            return UnsafeMutableRawPointer(ptr).assumingMemoryBound(to: FieldRecord.self)
        }
    }
}

struct FieldRecord {
    var flag : UInt32
    var MangledTypeName : RelativePointer<CChar>
    var FieldName : RelativePointer<CChar>
}



//// test class/struct/enum
//
//class LGTeacher {
//    var name : String = "dasda"
//    var age : Int = 11
//    var subject : String = "Math"
//    var sex : Sex = .male
//}
//
//struct Student{
//    var name : String = "dasda"
//    var age : Int = 11
//    var sex : Sex = .male
//}
//
//enum Sex{
//    case male
//    case female
//}
//
//
//// class metadata
//let obj1 = LGTeacher()
//
//let obj1Ptr =  Unmanaged.passUnretained(obj1).toOpaque()
//
//let obj1Ptr1 = obj1Ptr.bindMemory(to: HeapObject.self, capacity: 1)
//
//print("LGTeacher Class Info")
//
//let ClassMetadataDescriptionPtr = obj1Ptr1.pointee.metadata.pointee.Description
//
//print("Name : \(String(cString:ClassMetadataDescriptionPtr.pointee.Name.get()))")
//
//let FieldNum = ClassMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
//print("FieldNum : \(FieldNum)")
//
//print("   ")
//
//let fieldRecordPtr = ClassMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()
//
//for i in 0..<Int(FieldNum){
//    let tmpPtr = fieldRecordPtr.advanced(by: i)
//    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
//  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
//}
//
//print("   ")
//
//print("LGTeacher Class end")
//
//print("   ")
//
//// struct metadata
//
//
//
//let structPtr = unsafeBitCast(Student.self as Any.Type, to: UnsafePointer<StructMetadata>.self)
//
//print("Student Struct Info")
//
//let StructMetadataDescriptionPtr = structPtr.pointee.Description
//
//print("Name : \(String(cString:StructMetadataDescriptionPtr.pointee.Name.get()))")
//
//let FieldNum1 = StructMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
//print("FieldNum : \(FieldNum1)")
//
//print("   ")
//
//let fieldRecordPtr1 = StructMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()
//
//for i in 0..<Int(FieldNum1){
//    let tmpPtr = fieldRecordPtr1.advanced(by: i)
//    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
//  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
//}
//
//print("   ")
//
//print("Student end")
//
//print("   ")
//
//
//
//// enum metadata
//
//
//let enumPtr = unsafeBitCast(Sex.self as Any.Type, to: UnsafePointer<StructMetadata>.self)
//
//print("Sex Enum Info")
//
//let enumMetadataDescriptionPtr = enumPtr.pointee.Description
//
//print("Name : \(String(cString:enumMetadataDescriptionPtr.pointee.Name.get()))")
//
//let FieldNum2 = enumMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
//print("FieldNum : \(FieldNum2)")
//
//print("   ")
//
//let fieldRecordPtr2 = enumMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()
//
//for i in 0..<Int(FieldNum2){
//    let tmpPtr = fieldRecordPtr2.advanced(by: i)
//    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
//  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
//}
//
//print("   ")
//
//print("Sex end")
//
//print("   ")


class LGTeacher {
    var name : String = "dasda"
    var age : Int = 11
    var subject : String = "Math"
    var sex : LGSex = .male
}

struct LGStudent{
    var name : String = "dasda"
    var age : Int = 11
    var sex : LGSex = .male
}

enum LGSex{
    case male
    case female
}


enum Result{
    case success(statusCode : Int)
    case fail(statusCode : Int, error : String)
    case unknown
}


// 对象的内存占用
//print("class LGTeacher : \(class_getInstanceSize(LGTeacher.self))")
//
//print("struct LGStudent Size : \(MemoryLayout<LGStudent>.size)")
//print("struct LGStudent Stride : \(MemoryLayout<LGStudent>.stride)")
//
//print("enum LGSex Size : \(MemoryLayout<LGSex>.size)")
//print("enum LGSex Stride : \(MemoryLayout<LGSex>.stride)")
//
//print("enum Result Size : \(MemoryLayout<Result>.size)")
//print("enum Result Stride : \(MemoryLayout<Result>.stride)")

// 对象的结构
//var teacher = LGTeacher()
//var student = LGStudent()
//var sex = LGSex.female
//var result = Result.fail(statusCode: 408, error: "超时")
//
//let teacherPtr = Unmanaged.passUnretained(teacher).toOpaque()
//let studentPtr = withUnsafePointer(to: &student) { $0}
//let sexPtr = withUnsafePointer(to: &sex) { $0}
//let resultPtr = withUnsafePointer(to: &result) { $0}

// metadata的结构


let teacherMetadataPtr = unsafeBitCast(LGTeacher.self as Any.Type, to: UnsafePointer<ClassMetadata>.self)
let studentMetadataPtr = unsafeBitCast(LGStudent.self as Any.Type, to: UnsafePointer<StructMetadata>.self)
let sexMetadataPtr = unsafeBitCast(LGSex.self as Any.Type, to: UnsafePointer<EnumMetadata>.self)
let resultMetadataPtr = unsafeBitCast(Result.self as Any.Type, to: UnsafePointer<EnumMetadata>.self)

//print("Metadata:\n\n")
//print("LGTeacher: \(teacherMetadataPtr.pointee)")
//print("LGStudent: \(studentMetadataPtr.pointee)")
//print("LGSex: \(sexMetadataPtr.pointee)")
//print("Result: \(resultMetadataPtr.pointee)")


print("LGTeacher Class Info")

let ClassMetadataDescriptionPtr = teacherMetadataPtr.pointee.Description

print("Name : \(String(cString:ClassMetadataDescriptionPtr.pointee.Name.get()))")

let FieldNum = ClassMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
print("FieldNum : \(FieldNum)")

print("   ")

let fieldRecordPtr = ClassMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()

for i in 0..<Int(FieldNum){
    let tmpPtr = fieldRecordPtr.advanced(by: i)
    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
}

print("   ")

print("LGTeacher Class end")

print("   ")




print("Student Struct Info")

let StructMetadataDescriptionPtr = studentMetadataPtr.pointee.Description

print("Name : \(String(cString:StructMetadataDescriptionPtr.pointee.Name.get()))")

let FieldNum1 = StructMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
print("FieldNum : \(FieldNum1)")

print("   ")

let fieldRecordPtr1 = StructMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()

for i in 0..<Int(FieldNum1){
    let tmpPtr = fieldRecordPtr1.advanced(by: i)
    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
}

print("   ")

print("Student end")

print("   ")



// enum metadata

print("Sex Enum Info")

let enumMetadataDescriptionPtr = sexMetadataPtr.pointee.Description

print("Name : \(String(cString:enumMetadataDescriptionPtr.pointee.Name.get()))")

let FieldNum2 = enumMetadataDescriptionPtr.pointee.Fields.get().pointee.NumFields
print("FieldNum : \(FieldNum2)")

print("   ")

let fieldRecordPtr2 = enumMetadataDescriptionPtr.pointee.Fields.get().pointee.getFieldRecordPtr()

for i in 0..<Int(FieldNum2){
    let tmpPtr = fieldRecordPtr2.advanced(by: i)
    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
}

print("   ")

print("Sex end")

print("   ")


print("Result Enum Info")

let enumMetadataDescriptionPtr1 = resultMetadataPtr.pointee.Description

print("Name : \(String(cString:enumMetadataDescriptionPtr1.pointee.Name.get()))")

let FieldNum3 = enumMetadataDescriptionPtr1.pointee.Fields.get().pointee.NumFields
print("FieldNum : \(FieldNum2)")

print("   ")

let fieldRecordPtr3 = enumMetadataDescriptionPtr1.pointee.Fields.get().pointee.getFieldRecordPtr()

for i in 0..<Int(FieldNum3){
    let tmpPtr = fieldRecordPtr3.advanced(by: i)
    print("FieldName : \(String(cString:tmpPtr.pointee.FieldName.get()))")
  //  print("MangledTypeName : \(String(cString:tmpPtr.pointee.MangledTypeName.get()))")
}

print("   ")

print("Result end")



print("   ")

print("end")







