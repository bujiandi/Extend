//
//  JSON.swift
//  TestJSON
//
//  Created by 李招利 on 2019/1/7.
//  Copyright © 2019 jwl. All rights reserved.
//

#if swift(>=4.2)

@dynamicMemberLookup
public enum JSON {
    
    case object (Object)
    case array  (Array)
    case string (String)
    case number (Number)
    case bool   (Bool)
    case null
    case error  (Error, ignore:[String])
    
    public subscript(dynamicMember member: String) -> JSON {
        get { return self[member] }
        set { self[member] = newValue }
    }
}

#else

public enum JSON {

case object (Object)
case array  (Array)
case string (String)
case number (Number)
case bool   (Bool)
case null
case error  (Error, ignore:[String])

}

#endif
