//===------------------------------------------------------------*- C++ -*-===//
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Also available under a BSD-style license. See LICENSE.
//
//===----------------------------------------------------------------------===//

#include "IR/TcpDialect.h"
#include "IR/TcpOps.h"

#include "mlir/IR/Attributes.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/IR/OpImplementation.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/SourceMgr.h"

using namespace mlir;
using namespace mlir::tcp;

void TcpDialect::initialize() {
#define GET_OP_LIST
  addOperations<
#include "IR/TcpOps.cpp.inc"
      >();
#define GET_ATTRDEF_LIST
  addAttributes<
#include "IR/TcpAttrs.cpp.inc"
      >();
}

#include "IR/TcpEnums.cpp.inc"
#define GET_ATTRDEF_CLASSES
#include "IR/TcpAttrs.cpp.inc"

#include "IR/TcpDialect.cpp.inc"

Attribute TcpDialect::parseAttribute(DialectAsmParser &parser,
                                     Type type) const {
  StringRef attrKind;
  Attribute attr;
  OptionalParseResult result =
      generatedAttributeParser(parser, &attrKind, type, attr);
  if (result.has_value())
    return attr;

  parser.emitError(parser.getNameLoc(), "unknown Tcp attribute");
  return Attribute();
}

void TcpDialect::printAttribute(Attribute attr,
                                DialectAsmPrinter &printer) const {
  if (succeeded(generatedAttributePrinter(attr, printer)))
    return;
  llvm_unreachable("unhandled Tcp attribute kind");
}
