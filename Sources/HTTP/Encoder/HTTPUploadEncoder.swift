//
//  HTTPUploadEncoder.swift
//  Basic
//
//  Created by 李招利 on 2018/9/30.
//


#if canImport(Basic)
import Basic
#endif
import Foundation

private let newLineCRLF = "\r\n".data(using: .utf8)!

extension Data {
    
    fileprivate mutating func append(upload data:Data) {
        append(newLineCRLF)
        append("Content-Length:\(data.count)")
        append(newLineCRLF)    //正文前另起一行
        append(newLineCRLF)    //正文前另起二行
        append(data)
        append(newLineCRLF)    //结束另起一行
    }
}

extension HTTP {
    
    public enum UploadParam {
        case file(URL, name:String?, mime:MIME?)
        case data(Data, name:String?, mime:MIME)
        case date(Date, format:DateFormatter?)
        case text(String)
    }
    
    
    open class UploadEncoder : HTTPPostEncoder {
        
        public typealias Params = (inout Form) -> Void
        public typealias SignParams = [(String, HTTP.UploadParam)]
        
        open func sign(params: inout [(String, HTTP.UploadParam)], url:URL!) {}
        
        open func encode(params: ((inout Form) -> Void)?, request: inout URLRequest) throws -> Data? {
            
            #if DEBUG
            print("HTTP ->", request.url?.absoluteString ?? "nil")
            #endif
            
            var form = Form()
            params?(&form)
            
            if form.params.isEmpty { return nil }
                        
            // 参数加签
            sign(params: &form.params, url: request.url)
            
            // 分隔符标记
            let boundary:String = String(format: "fenfen.net.boundary.%08x%08x", arc4random(), arc4random())
            
            #if DEBUG
            print("POST -> [")
            #endif
            
            var data = Data()
            for (key, val) in form.params {
                
                data.append("--\(boundary)")
                data.append(newLineCRLF)
                data.append("Content-Disposition: form-data; name=\"\(key.encodeURL())\"")
                
                #if DEBUG
                print("--\(boundary)")
                print("Content-Disposition: form-data; name=\"\(key.encodeURL())\"",terminator: "")
                #endif
                switch val {
                    
                case let .file(url, name, mime):
                    if let fileName = name, !name.isEmpty {
                        data.append("; filename=\"\(fileName)\"")
                        #if DEBUG
                        print("; filename=\"\(fileName)\"")
                        #endif
                    } else {
                        #if DEBUG
                        print("")
                        #endif
                    }
                    
                    let mimeType = mime ?? HTTP.MIME(rawValue: url.pathExtension)
                    data.append(newLineCRLF)
                    data.append("Content-Type: \(mimeType.rawValue)")
                    
                    let value = try Data(contentsOf: url, options: .uncachedRead)
                    data.append(upload: value)
                    
                    #if DEBUG
                    print("Content-Type: \(mimeType.rawValue)")
                    print("Content-Length:\(value.count)")
                    print("")
                    print("[\(url.absoluteString)]")
                    #endif
                case let .data(value, name, mime):
                    if let fileName = name, !name.isEmpty {
                        data.append("; filename=\"\(fileName)\"")
                        #if DEBUG
                        print("; filename=\"\(fileName)\"")
                        #endif
                    } else {
                        #if DEBUG
                        print("")
                        #endif
                    }
                    data.append(newLineCRLF)
                    data.append("Content-Type: \(mime.rawValue)")
                    
                    data.append(upload: value)
                    
                    #if DEBUG
                    print("Content-Type: \(mime.rawValue)")
                    print("Content-Length:\(value.count)")
                    print("")
                    print("[data:\(value.count) bytes]")
                    #endif
                case let .date(date, format):
                    let value = format?.string(from: date) ?? date.string()
                    data.append(upload: value.data(using: .utf8)!)
                    
                    #if DEBUG
                    print("")
                    print("Content-Length:\(value.utf8.count)")
                    print("")
                    print(value)
                    #endif
                case let .text(text):
                    let value = text.encodeURL().data(using: .utf8)!
                    data.append(upload: value)
                    
                    #if DEBUG
                    print("")
                    print("Content-Length:\(value.count)")
                    print("")
                    print(text)
                    #endif
                }
            }
            // 添加结束标记
            data.append("--\(boundary)--")
            data.append(newLineCRLF)
            
            #if DEBUG
            print("--\(boundary)--")
            print("] // <- POST END")
            #endif
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            return data
        }
        
        public init() {}
    }
    
    // 默认上传编码器, 可修改
    public static var uploadEncoder = HTTP.UploadEncoder()

}

extension HTTP.UploadEncoder {
    
    public struct Form: Collection, RangeReplaceableCollection {
        
        private static var filenameIndex:UInt32 = 0
        
        public typealias Index = Int
        public typealias Element = (String, HTTP.UploadParam)
        public typealias SubSequence = ArraySlice<Element>
        
        var params:[Element] = []
        public init() {}
        
        public var startIndex: Int { return params.startIndex }
        public var endIndex: Int { return params.endIndex }
        public var count: Int { return params.count }
        
        public func index(after i: Int) -> Int {
            return params.index(after: i)
        }
        
        public subscript(bounds: Int) -> Element {
            get { return params[bounds] }
            set { params[bounds] = newValue }
        }
        
        public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
            params.replaceSubrange(subrange, with: newElements)
        }
        
        public mutating func append(_ key:String, file:URL, name:String = "", mime:HTTP.MIME? = nil) {
            var fileName = name
            if  fileName.isEmpty {
                let now = Date().string(withFormat: "yyyyMMddHHmmss")
                let index = HTTP.UploadEncoder.Form.filenameIndex
                if index < UInt32.max {
                    HTTP.UploadEncoder.Form.filenameIndex += 1
                } else {
                    HTTP.UploadEncoder.Form.filenameIndex = 0
                }
                let num = String(index, radix: 16, uppercase: true)
                fileName = ["\(now)\(num)",file.pathExtension].filter{ !$0.isEmpty }.joined(separator: ".")
            }
            append(key, param: .file(file, name: fileName, mime: mime))
        }
        
        
        public mutating func append(_ key:String, data:Data, name:String? = nil, fileExtension:HTTP.MIMEFileExtension) {
            append(key, data: data, name: name, mime: .common(fileExtension))
        }
        
        public mutating func append(_ key:String, data:Data, name:String? = nil, mime:HTTP.MIME) {
            append(key, param: .data(data, name: name, mime: mime))
        }
        
        public mutating func append(_ key:String, date:Date, format:DateFormatter? = nil) {
            append(key, param: .date(date, format: format))
        }
        
        public mutating func append<C>(_ key:String, values:C) where C : Collection, C.Element : RawRepresentable {
            var iterator = values.makeIterator()
            while let element = iterator.next() {
                append(key, value: element.rawValue)
            }
        }
        
        public mutating func append<C>(_ key:String, values:C) where C : Collection {
            var iterator = values.makeIterator()
            while let element = iterator.next() {
                append(key, value: element)
            }
        }
        
        public mutating func append<T>(_ key:String, value closure: @autoclosure () -> T) where T : RawRepresentable {
            append(key, param: .text(unwrapOptionalToString(closure().rawValue)))
        }
        
        public mutating func append(_ key:String, value closure: @autoclosure () -> Any) {
            append(key, param: .text(unwrapOptionalToString(closure())))
        }

        public mutating func append(_ key:String, param: HTTP.UploadParam) {
            params.append((key, param))
        }

    }
    
}


extension HTTP.Request {
    
    public mutating func upload(_ params:((inout HTTP.UploadEncoder.Form) -> Void)?) {
        post(encoder: HTTP.Encoder.Post.upload, params: params)
    }
    
}
