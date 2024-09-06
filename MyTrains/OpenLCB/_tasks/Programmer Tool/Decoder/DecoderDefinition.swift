// -----------------------------------------------------------------------------
// DecoderDefinition.swift
// MyTrains
//
// Copyright © 2024 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     31/08/2024  Paul Willmott - DecoderDefinition.swift created.
//     03/09/2024  Paul Willmott - esuPhysicalOutputs, offsetMethod added.
//     04/09/2024  Paul Willmott - esuOutputModes added.
// -----------------------------------------------------------------------------

import Foundation

public struct DecoderDefinition : Codable {
  
  var decoderType        : DecoderType
  var firmwareVersion    : [[Int]]
  var esuProductIds      : [UInt32]
  var cvs                : [CV]
  var defaultValues      : [UInt8]
  var mapping            : [Int:Set<CV>]
  var properties         : Set<ProgrammerToolSettingsProperty>
  var esuPhysicalOutputs : Set<ESUDecoderPhysicalOutput>
  var offsetMethod       : ESUPhysicalOutputCVIndexOffsetMethod
  var esuOutputModes     : [ESUDecoderPhysicalOutput:Set<ESUPhysicalOutputMode>]
  
}
