// RUN: tcp-opt <%s -convert-torch-to-tcp -split-input-file -verify-diagnostics | FileCheck %s

// CHECK-LABEL:  func.func @torch.aten.sigmoid(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.sigmoid %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.sigmoid(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.sigmoid %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.addtensor$samerank(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = tcp.add %[[T0]], %[[T1]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T3:.*]] = torch_c.from_builtin_tensor %[[T2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.addtensor$samerank(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.add.Tensor %arg0, %arg1, %int1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.addtensor$alpha(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 2
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<2> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T1]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T1]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T12:.*]] = tcp.mul %[[T11]], %[[T1]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.add %[[T0]], %[[T12]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.addtensor$alpha(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int2 = torch.constant.int 2
  %0 = torch.aten.add.Tensor %arg0, %arg1, %int2 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.addscalar(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 1
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<1> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T0]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T0]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.add %[[T0]], %[[T11]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.addscalar(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.add.Scalar %arg0, %int1, %int1 : !torch.vtensor<[?,?],f32>, !torch.int, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.addtensor$diffrank(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?],f32> -> tensor<?xf32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           [0, 1]
// CHECK-SAME:                           : tensor<?xf32> into tensor<1x?xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]] {axes = [0]} : tensor<1x?xf32>, index -> tensor<?x?xf32>
// CHECK:         %[[ADD:.*]] = tcp.add %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[ADD]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.addtensor$diffrank(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.add.Tensor %arg0, %arg1, %int1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.addtensor$rank0(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[],f32> -> tensor<f32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           []
// CHECK-SAME:                           : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[CONST1:.*]] = arith.constant 1 : index
// CHECK:         %[[DIM1:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST1]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]], %[[DIM1]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[ADD:.*]] = tcp.add %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[ADD]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.addtensor$rank0(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.add.Tensor %arg0, %arg1, %int1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.subtensor(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = tcp.sub %[[T0]], %[[T1]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T3:.*]] = torch_c.from_builtin_tensor %[[T2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.subtensor(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.sub.Tensor %arg0, %arg1, %int1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.subtensor$alpha(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 2
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<2> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T1]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T1]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T12:.*]] = tcp.mul %[[T11]], %[[T1]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.sub %[[T0]], %[[T12]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.subtensor$alpha(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int2 = torch.constant.int 2
  %0 = torch.aten.sub.Tensor %arg0, %arg1, %int2 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.subscalar(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 1
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<1> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T0]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T0]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.sub %[[T0]], %[[T11]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.subscalar(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.sub.Scalar %arg0, %int1, %int1 : !torch.vtensor<[?,?],f32>, !torch.int, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.multensor(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?],f32> -> tensor<?xf32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           [0, 1]
// CHECK-SAME:                           : tensor<?xf32> into tensor<1x?xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]] {axes = [0]} : tensor<1x?xf32>, index -> tensor<?x?xf32>
// CHECK:         %[[MUL:.*]] = tcp.mul %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[MUL]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.multensor(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.mul.Tensor %arg0, %arg1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.mulscalar(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 1
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<1> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T0]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T0]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.mul %[[T0]], %[[T11]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.mulscalar(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.mul.Scalar %arg0, %int1: !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.divtensor(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?],f32> -> tensor<?xf32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           [0, 1]
// CHECK-SAME:                           : tensor<?xf32> into tensor<1x?xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]] {axes = [0]} : tensor<1x?xf32>, index -> tensor<?x?xf32>
// CHECK:         %[[DIV:.*]] = tcp.divf %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[DIV]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.divtensor(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.div.Tensor %arg0, %arg1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.divscalar(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch.constant.int 1
// CHECK:         %[[T4:.*]] = tcp.const {value = dense<1> : tensor<i64>} : tensor<i64>
// CHECK:         %[[T5:.*]] = tcp.cast %[[T4]] {in_int_signedness = #tcp<signedness Signed>} : tensor<i64> -> tensor<f32>
// CHECK:         %[[T6:.*]] = tensor.expand_shape %[[T5]] [] : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[T7:.*]] = arith.constant 0 : index
// CHECK:         %[[T8:.*]] = tensor.dim %[[T0]], %[[T7]] : tensor<?x?xf32>
// CHECK:         %[[T9:.*]] = arith.constant 1 : index
// CHECK:         %[[T10:.*]] = tensor.dim %[[T0]], %[[T9]] : tensor<?x?xf32>
// CHECK:         %[[T11:.*]] = tcp.broadcast %[[T6]], %[[T8]], %[[T10]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[T13:.*]] = tcp.divf %[[T0]], %[[T11]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T14:.*]] = torch_c.from_builtin_tensor %[[T13]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T14]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.divscalar(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int1 = torch.constant.int 1
  %0 = torch.aten.div.Scalar %arg0, %int1: !torch.vtensor<[?,?],f32>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.clamp(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = tcp.clamp %[[T0]] {max_float = 1.024000e+03 : f32, min_float = 1.000000e-01 : f32} : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T3:.*]] = torch_c.from_builtin_tensor %[[T2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.clamp(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %float1.000000e-01 = torch.constant.float 1.000000e-01
  %float1.024000e03 = torch.constant.float 1.024000e+03
  %0 = torch.aten.clamp %arg0, %float1.000000e-01, %float1.024000e03 : !torch.vtensor<[?,?],f32>, !torch.float, !torch.float -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.tanh(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.tanh %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.tanh(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.tanh %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.relu(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = tcp.clamp %[[T0]] {min_float = 0.000000e+00 : f32} : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T3:.*]] = torch_c.from_builtin_tensor %[[T2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.relu(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.relu %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.sqrt(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.sqrt %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.sqrt(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.sqrt %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.sqrt_int(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],si32> -> tensor<?x?xi32>
// CHECK:         %[[T1:.*]] = tcp.sqrt %[[T0]] : tensor<?x?xi32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.sqrt_int(%arg0: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.sqrt %arg0 : !torch.vtensor<[?,?],si32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.ceil(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.ceil %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.ceil(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.ceil %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.floor(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.floor %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.floor(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.floor %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.sin(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.sin %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.sin(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.sin %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.cos(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.cos %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.cos(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.cos %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.abs(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.abs %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.abs(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.abs %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.log(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.log %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.log(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.log %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.neg(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.neg %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.neg(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.neg %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.batch_norm(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,4,?,?],f32>) -> !torch.vtensor<[?,4,?,?],f32> {
// CHECK:              %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,4,?,?],f32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T1:.*]] = tcp.const {value = dense<[5.000000e-01, 4.000000e-01, 3.000000e-01, 6.000000e-01]> : tensor<4xf32>} : tensor<4xf32>
// CHECK:              %[[T2:.*]] = tcp.const {value = dense<[3.000000e+00, 2.000000e+00, 4.000000e+00, 5.000000e+00]> : tensor<4xf32>} : tensor<4xf32>
// CHECK:              %[[T3:.*]] = torch.constant.float 1.000000e-01
// CHECK:              %[[T4:.*]] = torch.constant.float 1.000000e-05
// CHECK:              %[[T5:.*]] = torch.constant.bool true
// CHECK:              %[[T6:.*]] = torch.constant.bool false
// CHECK:              %[[T7:.*]] = tcp.const {value = dense<9.99999974E-6> : tensor<f32>} : tensor<f32>
// CHECK:              %[[T8:.*]] = tensor.expand_shape %[[T1]]
// CHECK-SAME:                      [0, 1, 2, 3]
// CHECK-SAME:                      : tensor<4xf32> into tensor<1x4x1x1xf32>
// CHECK:              %[[T9:.*]] = arith.constant 0 : index
// CHECK:              %[[T10:.*]] = tensor.dim %[[T0]], %[[T9]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T11:.*]] = arith.constant 2 : index
// CHECK:              %[[T12:.*]] = tensor.dim %[[T0]], %[[T11]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T13:.*]] = arith.constant 3 : index
// CHECK:              %[[T14:.*]] = tensor.dim %[[T0]], %[[T13]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T15:.*]] = tcp.broadcast %[[T8]], %[[T10]], %[[T12]], %[[T14]] {axes = [0, 2, 3]} : tensor<1x4x1x1xf32>, index, index, index -> tensor<?x4x?x?xf32>
// CHECK:              %[[T16:.*]] = tensor.expand_shape %[[T2]]
// CHECK-SAME:                      [0, 1, 2, 3]
// CHECK-SAME:                      : tensor<4xf32> into tensor<1x4x1x1xf32>
// CHECK:              %[[T17:.*]] = arith.constant 0 : index
// CHECK:              %[[T18:.*]] = tensor.dim %[[T0]], %[[T17]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T19:.*]] = arith.constant 2 : index
// CHECK:              %[[T20:.*]] = tensor.dim %[[T0]], %[[T19]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T21:.*]] = arith.constant 3 : index
// CHECK:              %[[T22:.*]] = tensor.dim %[[T0]], %[[T21]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T23:.*]] = tcp.broadcast %[[T16]], %[[T18]], %[[T20]], %[[T22]] {axes = [0, 2, 3]} : tensor<1x4x1x1xf32>, index, index, index -> tensor<?x4x?x?xf32>
// CHECK:              %[[T24:.*]] = tensor.expand_shape %[[T2]]
// CHECK-SAME:                      [0, 1, 2, 3]
// CHECK-SAME:                      : tensor<4xf32> into tensor<1x4x1x1xf32>
// CHECK:              %[[T25:.*]] = arith.constant 0 : index
// CHECK:              %[[T26:.*]] = tensor.dim %[[T0]], %[[T25]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T27:.*]] = arith.constant 2 : index
// CHECK:              %[[T28:.*]] = tensor.dim %[[T0]], %[[T27]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T29:.*]] = arith.constant 3 : index
// CHECK:              %[[T30:.*]] = tensor.dim %[[T0]], %[[T29]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T31:.*]] = tcp.broadcast %[[T24]], %[[T26]], %[[T28]], %[[T30]] {axes = [0, 2, 3]} : tensor<1x4x1x1xf32>, index, index, index -> tensor<?x4x?x?xf32>
// CHECK:              %[[T32:.*]] = tensor.expand_shape %[[T1]]
// CHECK-SAME:                      [0, 1, 2, 3]
// CHECK-SAME:                      : tensor<4xf32> into tensor<1x4x1x1xf32>
// CHECK:              %[[T33:.*]] = arith.constant 0 : index
// CHECK:              %[[T34:.*]] = tensor.dim %[[T0]], %[[T33]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T35:.*]] = arith.constant 2 : index
// CHECK:              %[[T36:.*]] = tensor.dim %[[T0]], %[[T35]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T37:.*]] = arith.constant 3 : index
// CHECK:              %[[T38:.*]] = tensor.dim %[[T0]], %[[T37]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T39:.*]] = tcp.broadcast %[[T32]], %[[T34]], %[[T36]], %[[T38]] {axes = [0, 2, 3]} : tensor<1x4x1x1xf32>, index, index, index -> tensor<?x4x?x?xf32>
// CHECK:              %[[T40:.*]] = tensor.expand_shape %[[T7]]
// CHECK-SAME:                      []
// CHECK-SAME:                      : tensor<f32> into tensor<1x1x1x1xf32>
// CHECK:              %[[T41:.*]] = arith.constant 0 : index
// CHECK:              %[[T42:.*]] = tensor.dim %[[T0]], %[[T41]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T43:.*]] = arith.constant 1 : index
// CHECK:              %[[T44:.*]] = arith.constant 4 : index
// CHECK:              %[[T45:.*]] = arith.constant 2 : index
// CHECK:              %[[T46:.*]] = tensor.dim %[[T0]], %[[T45]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T47:.*]] = arith.constant 3 : index
// CHECK:              %[[T48:.*]] = tensor.dim %[[T0]], %[[T47]] : tensor<?x4x?x?xf32>
// CHECK:              %[[T49:.*]] = tcp.broadcast %[[T40]], %[[T42]], %[[T44]], %[[T46]], %[[T48]] {axes = [0, 1, 2, 3]} : tensor<1x1x1x1xf32>, index, index, index, index -> tensor<?x4x?x?xf32>
// CHECK:              %[[T50:.*]] = tcp.sub %[[T0]], %[[T15]] : tensor<?x4x?x?xf32>, tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T51:.*]] = tcp.add %[[T23]], %[[T49]] : tensor<?x4x?x?xf32>, tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T52:.*]] = tcp.sqrt %[[T51]] : tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T53:.*]] = tcp.divf %[[T50]], %[[T52]] : tensor<?x4x?x?xf32>, tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T54:.*]] = tcp.mul %[[T31]], %[[T53]] : tensor<?x4x?x?xf32>, tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T55:.*]] = tcp.add %[[T54]], %[[T39]] : tensor<?x4x?x?xf32>, tensor<?x4x?x?xf32> -> tensor<?x4x?x?xf32>
// CHECK:              %[[T56:.*]] = torch_c.from_builtin_tensor %[[T55]] : tensor<?x4x?x?xf32> -> !torch.vtensor<[?,4,?,?],f32>
// CHECK:              return %[[T56]] : !torch.vtensor<[?,4,?,?],f32>
func.func @torch.aten.batch_norm(%arg0: !torch.vtensor<[?,4,?,?],f32>) -> !torch.vtensor<[?,4,?,?],f32> {
  %0 = torch.vtensor.literal(dense<[5.000000e-01, 4.000000e-01, 3.000000e-01, 6.000000e-01]> : tensor<4xf32>) : !torch.vtensor<[4],f32>
  %1 = torch.vtensor.literal(dense<[3.000000e+00, 2.000000e+00, 4.000000e+00, 5.000000e+00]> : tensor<4xf32>) : !torch.vtensor<[4],f32>
  %float1.000000e-01 = torch.constant.float 1.000000e-01
  %float1.000000e-05 = torch.constant.float 1.000000e-05
  %true = torch.constant.bool true
  %false = torch.constant.bool false
  %2 = torch.aten.batch_norm %arg0, %1, %0, %0, %1, %false, %float1.000000e-01, %float1.000000e-05, %true : !torch.vtensor<[?,4,?,?],f32>, !torch.vtensor<[4],f32>, !torch.vtensor<[4],f32>, !torch.vtensor<[4],f32>, !torch.vtensor<[4],f32>, !torch.bool, !torch.float, !torch.float, !torch.bool -> !torch.vtensor<[?,4,?,?],f32>
  return %2 : !torch.vtensor<[?,4,?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.atan2$samerank(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = tcp.atan2 %[[T0]], %[[T1]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T3:.*]] = torch_c.from_builtin_tensor %[[T2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.atan2$samerank(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.atan2 %arg0, %arg1: !torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.atan2$diffrank(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?],f32> -> tensor<?xf32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           [0, 1]
// CHECK-SAME:                           : tensor<?xf32> into tensor<1x?xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]] {axes = [0]} : tensor<1x?xf32>, index -> tensor<?x?xf32>
// CHECK:         %[[ATAN2:.*]] = tcp.atan2 %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[ATAN2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.atan2$diffrank(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.atan2 %arg0, %arg1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.atan2$rank0(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>,
// CHECK-SAME:         %[[ARG1:.*]]: !torch.vtensor<[],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[TO_BUILTIN0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[TO_BUILTIN1:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[],f32> -> tensor<f32>
// CHECK:         %[[EXPAND_SHAPE:.*]] = tensor.expand_shape %[[TO_BUILTIN1]]
// CHECK-SAME:                           []
// CHECK-SAME:                           : tensor<f32> into tensor<1x1xf32>
// CHECK:         %[[CONST0:.*]] = arith.constant 0 : index
// CHECK:         %[[DIM0:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST0]] : tensor<?x?xf32>
// CHECK:         %[[CONST1:.*]] = arith.constant 1 : index
// CHECK:         %[[DIM1:.*]] = tensor.dim %[[TO_BUILTIN0]], %[[CONST1]] : tensor<?x?xf32>
// CHECK:         %[[BROADCAST:.*]] = tcp.broadcast %[[EXPAND_SHAPE]], %[[DIM0]], %[[DIM1]] {axes = [0, 1]} : tensor<1x1xf32>, index, index -> tensor<?x?xf32>
// CHECK:         %[[ATAN2:.*]] = tcp.atan2 %[[TO_BUILTIN0]], %[[BROADCAST]] : tensor<?x?xf32>, tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[FROM_BUILTIN:.*]] = torch_c.from_builtin_tensor %[[ATAN2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[FROM_BUILTIN]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.atan2$rank0(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.atan2 %arg0, %arg1 : !torch.vtensor<[?,?],f32>, !torch.vtensor<[],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.atan(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T1:.*]] = tcp.atan %[[T0]] : tensor<?x?xf32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.atan(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %0 = torch.aten.atan %arg0 : !torch.vtensor<[?,?],f32> -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.to.dtype(
// CHECK-SAME:      %[[ARG_0:.*]]: !torch.vtensor<[?,?],f16>) -> !torch.vtensor<[?,?],f32> {
// CHECK:           %[[INP:.*]] = torch_c.to_builtin_tensor %[[ARG_0]] : !torch.vtensor<[?,?],f16> -> tensor<?x?xf16>
// CHECK:           %[[CST11:.*]] = torch.constant.int 11
// CHECK:           %[[NONE:.*]] = torch.constant.none
// CHECK:           %[[FALSE:.*]] = torch.constant.bool false
// CHECK:           %[[VAL_2:.*]] = tcp.cast %[[INP]] : tensor<?x?xf16> -> tensor<?x?xf32>
// CHECK:           %[[VAL_3:.*]] = torch_c.from_builtin_tensor %[[VAL_2]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:           return %[[VAL_3]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.to.dtype(%arg0: !torch.vtensor<[?,?],f16>) -> !torch.vtensor<[?,?],f32> {
  %int11 = torch.constant.int 11
  %none = torch.constant.none
  %false = torch.constant.bool false
  %0 = torch.aten.to.dtype %arg0, %int11, %false, %false, %none : !torch.vtensor<[?,?],f16>, !torch.int, !torch.bool, !torch.bool, !torch.none -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.to.dtype(
// CHECK-SAME:      %[[ARG_0:.*]]: !torch.vtensor<[?,?],f16>) -> !torch.vtensor<[?,?],i1> {
// CHECK:           %[[INP:.*]] = torch_c.to_builtin_tensor %[[ARG_0]] : !torch.vtensor<[?,?],f16> -> tensor<?x?xf16>
// CHECK:           %[[CST11:.*]] = torch.constant.int 11
// CHECK:           %[[NONE:.*]] = torch.constant.none
// CHECK:           %[[FALSE:.*]] = torch.constant.bool false
// CHECK:           %[[VAL_2:.*]] = tcp.cast %[[INP]] {out_int_signedness = #tcp<signedness Signless>} : tensor<?x?xf16> -> tensor<?x?xi1>
// CHECK:           %[[VAL_3:.*]] = torch_c.from_builtin_tensor %[[VAL_2]] : tensor<?x?xi1> -> !torch.vtensor<[?,?],i1>
// CHECK:           return %[[VAL_3]] : !torch.vtensor<[?,?],i1>
func.func @torch.aten.to.dtype(%arg0: !torch.vtensor<[?,?],f16>) -> !torch.vtensor<[?,?],i1> {
  %int11 = torch.constant.int 11
  %none = torch.constant.none
  %false = torch.constant.bool false
  %0 = torch.aten.to.dtype %arg0, %int11, %false, %false, %none : !torch.vtensor<[?,?],f16>, !torch.int, !torch.bool, !torch.bool, !torch.none -> !torch.vtensor<[?,?],i1>
  return %0 : !torch.vtensor<[?,?],i1>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.to.dtype(
// CHECK-SAME:      %[[ARG_0:.*]]: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f16> {
// CHECK:           %[[INP:.*]] = torch_c.to_builtin_tensor %[[ARG_0]] : !torch.vtensor<[?,?],si32> -> tensor<?x?xi32>
// CHECK:           %[[CST11:.*]] = torch.constant.int 11
// CHECK:           %[[NONE:.*]] = torch.constant.none
// CHECK:           %[[FALSE:.*]] = torch.constant.bool false
// CHECK:           %[[VAL_2:.*]] = tcp.cast %[[INP]] {in_int_signedness = #tcp<signedness Signed>} : tensor<?x?xi32> -> tensor<?x?xf16>
// CHECK:           %[[VAL_3:.*]] = torch_c.from_builtin_tensor %[[VAL_2]] : tensor<?x?xf16> -> !torch.vtensor<[?,?],f16>
// CHECK:           return %[[VAL_3]] : !torch.vtensor<[?,?],f16>
func.func @torch.aten.to.dtype(%arg0: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f16> {
  %int11 = torch.constant.int 11
  %none = torch.constant.none
  %false = torch.constant.bool false
  %0 = torch.aten.to.dtype %arg0, %int11, %false, %false, %none : !torch.vtensor<[?,?],si32>, !torch.int, !torch.bool, !torch.bool, !torch.none -> !torch.vtensor<[?,?],f16>
  return %0 : !torch.vtensor<[?,?],f16>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.to.dtype(
// CHECK-SAME:      %[[ARG_0:.*]]: !torch.vtensor<[?,?],i1>) -> !torch.vtensor<[?,?],ui8> {
// CHECK:           %[[INP:.*]] = torch_c.to_builtin_tensor %[[ARG_0]] : !torch.vtensor<[?,?],i1> -> tensor<?x?xi1>
// CHECK:           %[[CST11:.*]] = torch.constant.int 11
// CHECK:           %[[NONE:.*]] = torch.constant.none
// CHECK:           %[[FALSE:.*]] = torch.constant.bool false
// CHECK:           %[[VAL_2:.*]] = tcp.cast %[[INP]] {in_int_signedness = #tcp<signedness Signless>, out_int_signedness = #tcp<signedness Unsigned>} : tensor<?x?xi1> -> tensor<?x?xi8>
// CHECK:           %[[VAL_3:.*]] = torch_c.from_builtin_tensor %[[VAL_2]] : tensor<?x?xi8> -> !torch.vtensor<[?,?],ui8>
// CHECK:           return %[[VAL_3]] : !torch.vtensor<[?,?],ui8>
func.func @torch.aten.to.dtype(%arg0: !torch.vtensor<[?,?],i1>) -> !torch.vtensor<[?,?],ui8> {
  %int11 = torch.constant.int 11
  %none = torch.constant.none
  %false = torch.constant.bool false
  %0 = torch.aten.to.dtype %arg0, %int11, %false, %false, %none : !torch.vtensor<[?,?],i1>, !torch.int, !torch.bool, !torch.bool, !torch.none -> !torch.vtensor<[?,?],ui8>
  return %0 : !torch.vtensor<[?,?],ui8>
}
