//
//  Matrix.swift
//  Silverback
//
//  Created by Christian Otkjær on 14/12/15.
//  Copyright © 2015 Christian Otkjær. All rights reserved.
//

import Accelerate

public struct Matrix
{
    let data: NSData?
    var pointer: UnsafePointer <CGFloat>
    public let columns: Int // TODO: Rename to columnCount? Or combined as a size
    public let rows: Int // TODO: Rename to rowCount?
    let stride: Int
    
    public init(data: NSData, columns: Int, rows: Int, start: Int = 0, stride: Int = 1) {
        assert(columns >= 0)
        assert(rows >= 0)
        assert(stride >= 1)
        assert(columns * rows * stride + start <= data.length / sizeof(CGFloat))
        
        self.data = data
        self.pointer = UnsafePointer <CGFloat> (data.bytes).advancedBy(start)
        self.columns = columns
        self.rows = rows
        self.stride = stride
    }
    
    /**
     Note this form is unsafe because there is no upper bound to pointer.
     */
    public init(pointer: UnsafePointer <CGFloat>, columns: Int, rows: Int, start: Int = 0, stride: Int = 1) {
        assert(columns >= 0)
        assert(rows >= 0)
        assert(stride >= 1)
        
        self.data = nil
        self.pointer = pointer.advancedBy(start)
        self.columns = columns
        self.rows = rows
        self.stride = stride
    }
    
    public subscript (cell: (column: Int, row: Int)) -> CGFloat {
        assert(cell.column >= 0)
        assert(cell.column < columns)
        assert(cell.row >= 0)
        assert(cell.row < rows)
        
        let index = (cell.column + cell.row * columns) * stride
        return pointer[index]
    }
    
}

// MARK: Arithmetic

public func * (lhs: Matrix, rhs: Matrix) -> Matrix {
    let resultRows = lhs.rows
    let resultColumns = rhs.columns
    var resultData = NSMutableData(length: resultRows * resultColumns * sizeof(CGFloat))!
    
    #if arch(arm64) || arch(x86_64)
        assert(sizeof(Double) == sizeof(CGFloat))
        let resultPointer = UnsafeMutablePointer <Double> (resultData.mutableBytes)
        vDSP_mmulD(UnsafePointer <Double> (lhs.pointer), lhs.stride, UnsafePointer <Double> (rhs.pointer), rhs.stride, resultPointer, 1, vDSP_Length(lhs.rows), vDSP_Length(rhs.columns), vDSP_Length(lhs.columns))
        return Matrix(data: resultData, columns: resultColumns, rows: resultRows, stride: 1)
    #elseif arch(arm) || arch(i386)
        assert(sizeof(Float) == sizeof(CGFloat))
        let resultPointer = UnsafeMutablePointer <Float> (resultData.mutableBytes)
        vDSP_mmul(UnsafePointer <Float> (lhs.pointer), lhs.stride, UnsafePointer <Float> (rhs.pointer), rhs.stride, resultPointer, 1, vDSP_Length(lhs.rows), vDSP_Length(rhs.columns), vDSP_Length(lhs.columns))
        return Matrix(data: resultData, columns: resultColumns, rows: resultRows, stride: 1)
    #endif
}

// MARK: Equatable

extension Matrix: Equatable {
}

public func == (lhs: Matrix, rhs: Matrix) -> Bool {
    
    // Fail early if size is not the same
    if lhs.columns != rhs.columns || lhs.rows != rhs.rows {
        return false
    }
    
    // Note: .values is a rather expensive operation but does take stride into consideration - which is good.
    if lhs.values != rhs.values {
        return false
    }
    
    return true
}


// MARK: Printable

extension Matrix: CustomStringConvertible {
    public var description: String {
        
        let strings: [String] = (0..<rows).map() {
            let strings: [String] = self.row($0).map() { "\($0)" }
            let string = strings.joinWithSeparator(", ")
            return "[\(string)]"
        }
        
        let string = "[" + strings.joinWithSeparator(", ") + "]"
        
        return "Matrix(columns: \(columns), rows: \(rows), values: \(string))"
    }
}

// MARK: Convenience inits

public extension Matrix {
    init(values: Array <CGFloat>, columns: Int, rows: Int) {
        let data = NSData(bytes: values, length: values.count * sizeof(CGFloat))
        self.init(data: data, columns: columns, rows: rows)
    }
}

// MARK: Special accessors.

extension Matrix {
    
    /// Get all values in matrix as a 1 dimensional array
    public var values: [CGFloat] {
        var values: [CGFloat] = []
        for rowIndex in 0..<rows {
            for colIndex in 0..<columns {
                let value = self[(colIndex, rowIndex)]
                values.append(value)
            }
        }
        return values
    }
    
    /**
     Get a row of values from the matrix as an array of CGFloats
     */
    public func row(rowIndex: Int) -> [CGFloat] {
        assert(rowIndex >= 0)
        assert(rowIndex < rows)
        
        var row: [CGFloat] = []
        for colIndex in 0..<columns {
            let value = self[(colIndex, rowIndex)]
            row.append(value)
        }
        return row
    }
}