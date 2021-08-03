/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

public class DSStore
{
    private var rootBlock: RootBlock
    
    public convenience init?( path: String ) throws
    {
        try self.init( url: URL( fileURLWithPath: path ) )
    }
    
    public init?( url: URL ) throws
    {
        guard let stream = BinaryFileStream( url: url ) else
        {
            return nil
        }
        
        let align   = try stream.readUInt32( endianness: .big )
        let magic   = try stream.readUInt32( endianness: .big )
        let offset1 = try stream.readUInt32( endianness: .big )
        let size    = try stream.readUInt32( endianness: .big )
        let offset2 = try stream.readUInt32( endianness: .big )
        
        guard align == 0x01, magic == 0x42756431 else
        {
            throw NSError( title: "Invalid .DS_Store File", message: "Invalid header magic bytes" )
        }
        
        guard offset1 == offset2, offset1 > 0 else
        {
            throw NSError( title: "Invalid .DS_Store File", message: "Invalid root block offset" )
        }
        
        guard size > 0 else
        {
            throw NSError( title: "Invalid .DS_Store File", message: "Invalid root block size" )
        }
        
        self.rootBlock = try RootBlock( stream: stream, offset: size_t( offset1 ), size: size_t( size ) )
    }
}
