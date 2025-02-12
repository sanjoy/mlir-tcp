//===-------------------------------------------------------*- tablegen -*-===//
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Also available under a BSD-style license. See LICENSE.
//
//===----------------------------------------------------------------------===//

#ifndef TCP_BASE
#define TCP_BASE

include "mlir/IR/OpBase.td"

include "mlir/Interfaces/SideEffectInterfaces.td"

def Tcp_Dialect : Dialect {
  let name = "tcp";
  let cppNamespace = "::mlir::tcp";
  let description = [{
    Tensor Compute Primitives (TCP) dialect.

    TCP is a mid-level transformation oriented IR for deep learning & similar
    applications.
  }];
  // Dialect attribute parsing hook.
  let extraClassDeclaration = [{        
    Attribute parseAttribute(
        DialectAsmParser &parser, Type type) const override;
    void printAttribute(
        Attribute attr, DialectAsmPrinter &printer) const override;
  }]; 

  let dependentDialects = [];
}

//===----------------------------------------------------------------------===//
// Tcp Type Definitions.
//===----------------------------------------------------------------------===//

// The base class of a quantized type.
// Param tuple is: [bitwidth, zeropt, smantissa, sexp, low_end, high_end].
// Where low and high ends are 0,255 when unsigned, -128,127 when signed, for
// the 8-bit case.
class TCP_QuantizedType<string n, list<int> params, bit signed>
  : Type<And<[CPred<"$_self.isa<mlir::quant::QuantizedType>()">,
              CPred<"$_self.cast<mlir::quant::QuantizedType>()" #
                    ".getStorageTypeIntegralWidth() == " # !head(params)>]>,
    "Q" # !if (signed, "int", "uint") # !head(params) # " type"> {
  string name = n;
  string asTraitArgsStr = !interleave(params, ", ") #
                          !if(signed, ", true", ", false");
}

//===----------------------------------------------------------------------===//
// Quantized Integer Types.
//===----------------------------------------------------------------------===//
//===----------------------------------------------------------------------===//
// Name    Symmetry           Sign
//===----------------------------------------------------------------------===//
// q8ua  : asymmetric         unsigned
// q8sa  : asymmetric         signed
// q8ss  : symmetric          signed
// q16ss : symmetric          signed
//===----------------------------------------------------------------------===//
def TCP_QuantizedInt	: AnyTypeOf<[ TCP_QuantizedType<"q8ua", [8], 0>,
                                     TCP_QuantizedType<"q8sa", [8], 1>,
                                     TCP_QuantizedType<"q8ss", [8, 0], 1>,
                                     TCP_QuantizedType<"q16ss", [16, 0], 1>]>;

def Tcp_Scalar : AnyTypeOf<[AnyFloat, AnySignlessInteger, TCP_QuantizedInt]>;
def Tcp_Tensor : RankedTensorOf<[Tcp_Scalar]>;
def Tcp_TensorOrScalar : AnyTypeOf<[Tcp_Tensor, Tcp_Scalar]>;

def Tcp_FloatTensor : RankedTensorOf<[AnyFloat]>;
def Tcp_FloatOrIntTensor : RankedTensorOf<[AnyFloat, AnySignlessInteger]>;

//===----------------------------------------------------------------------===//
// Tcp Ops Base.
//===----------------------------------------------------------------------===//

class Tcp_Op<string mnemonic, list<Trait> traits = []> :
    Op<Tcp_Dialect, mnemonic, traits> {
}

class Tcp_UnaryElementwiseOp<string mnemonic, list<Trait> traits = []> :
    Tcp_Op<mnemonic, !listconcat(traits, [
        Pure,
        Elementwise,
        SameOperandsAndResultShape])> {
}

class Tcp_BinaryElementwiseOp<string mnemonic, list<Trait> traits = []> :
    Tcp_Op<mnemonic, !listconcat(traits, [
        NoMemoryEffect,
        Elementwise,
        SameOperandsAndResultShape])> {
}

#endif // TCP_BASE
