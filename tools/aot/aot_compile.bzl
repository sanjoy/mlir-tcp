def aot_compile(name, tcp_source):
    """
    AOT compiles `tcp_source` to a CPU library.

    Exposes a target named `aot_compiled_${name}` that has one global function
    for every function in `tcp_source`.  Each of the functions in `tcp_source`
    must consume and return tensors.  The ABI of the generated code is exposed
    in abi.h.
    """
    native.genrule(
        name = "_internal_gen_asm_" + name,
        srcs = [tcp_source],
        outs = ["_internal_" + name + ".S"],
        cmd = "./$(location //:tcp-opt) -lower-tcp-to-llvm $(SRCS) | ./$(location @llvm-project//mlir:mlir-translate) -mlir-to-llvmir | ./$(location @llvm-project//llvm:llc) -O3 > \"$@\"",
        tools = [
            "//:tcp-opt",
            "@llvm-project//mlir:mlir-translate",
            "@llvm-project//llvm:llc",
        ],
    )

    native.cc_library(
        name = "aot_compiled_" + name,
        srcs = ["_internal_" + name + ".S"],
        testonly = True,
    )
