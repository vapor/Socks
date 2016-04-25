//
//  InternetSocket.swift
//  Socks
//
//  Created by Honza Dvorsky on 3/20/16.
//
//

/*
public class InternetSocket: Socket {
    
    public let rawSocket: RawSocket
    public let address: InternetAddress //change to ResolvedInternetAddress
    // NOT public let address : addrinfo
    
    public var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    public init(rawSocket: RawSocket, address: /*Resolved*/InternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    /*
    public init(rawSocket: RawSocket, address: InternetAddress) {
        //1. calls the resolver, takes the first matching resolved address
        //2. calls the init above
    }
    */
 
    public func close() throws {
        try self.rawSocket.close()
    }
}
*/

public class InternetSocket: Socket {
    
    public let rawSocket: RawSocket
    public let address: ResolvedInternetAddress 
    
    public var descriptor: Descriptor {
        return self.rawSocket.descriptor
    }
    
    public init(rawSocket: RawSocket, address: ResolvedInternetAddress) {
        self.rawSocket = rawSocket
        self.address = address
    }
    
    
    public convenience init(socketConfig: SocketConfig, address: Internet_Address) throws {

        let resolver = Resolver(config: socketConfig)
        
        let resolvedInternetAddressList = resolver.resolve(internetAddress: address)
        
        // Let's observe the addresses
        //for singleResolvedInternetAddress in resolvedInternetAddressList {
        //    print(singleResolvedInternetAddress.resolvedCTypeAddress)
        //}
        
        guard resolvedInternetAddressList.count != 0 else {throw Error(.IPAddressValidationFailed) }
        
        // We made it here => address resolution was successul
        let raw = try! RawSocket(socketConfig: socketConfig, resolvedInternetAddress: resolvedInternetAddressList[0])
        
        self.init(rawSocket: raw, address: resolvedInternetAddressList[0])
     }
    
    
    public func close() throws {
        try self.rawSocket.close()
    }
}

