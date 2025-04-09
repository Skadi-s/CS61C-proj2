from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()
    
    def test_invalid_length(self):
        t = AssemblyTest(self, "relu.s")
        # Test length validation
        t.input_scalar("a2", 0)
        t.call("relu")
        t.execute(code=78)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        # raise NotImplementedError("TODO")
        array0 = t.array([1, -2, 3, -4, 5, -6, 7, -8, 9])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 8)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_invalid_length(self):
        t = AssemblyTest(self, "argmax.s")
        # Test length validation
        t.input_scalar("a2", 0)
        t.call("argmax")
        t.execute(code=77)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # Test basic dot product with stride 1
        v0 = t.array([1, 2, 3])
        v1 = t.array([4, 5, 6])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.check_scalar("a0", 32)  # 1 * 4 + 2 * 5 + 3 * 6 = 32
        t.execute()

    def test_stride_handling(self):
        t = AssemblyTest(self, "dot.s")
        # Test different strides (v0 stride=2, v1 stride=1)
        v0 = t.array([1, 0, 2, 0, 3, 0])
        v1 = t.array([4, 5, 6])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 2)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.check_scalar("a0", 32)  # 1 * 4 + 2 * 5 + 3 * 6 = 32
        t.execute()

    def test_negative_values(self):
        t = AssemblyTest(self, "dot.s")
        # Test with negative numbers
        v0 = t.array([-1, 2, -3])
        v1 = t.array([4, -5, 6])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.check_scalar("a0", -32)  # -1 * 4 + 2*-5 + -3 * 6 = -32
        t.execute()

    def test_single_element(self):
        t = AssemblyTest(self, "dot.s")
        # Test single element vectors
        v0 = t.array([5])
        v1 = t.array([6])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 1)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.check_scalar("a0", 30)
        t.execute()

    def test_invalid_length(self):
        t = AssemblyTest(self, "dot.s")
        # Test length validation
        t.input_scalar("a2", 0)
        t.call("dot")
        t.execute(code=75)

    def test_invalid_stride_v0(self):
        t = AssemblyTest(self, "dot.s")
        # Test v0 stride validation
        v0 = t.array([1])
        v1 = t.array([2])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 1)
        t.input_scalar("a3", 0)
        t.input_scalar("a4", 1)
        t.call("dot")
        t.execute(code=76)

    def test_invalid_stride_v1(self):
        t = AssemblyTest(self, "dot.s")
        # Test v1 stride validation
        v0 = t.array([1])
        v1 = t.array([2])
        t.input_array("a0", v0)
        t.input_array("a1", v1)
        t.input_scalar("a2", 1)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 0)
        t.call("dot")
        t.execute(code=76)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)

class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        t.include("dot.s")  # Include dependent dot product implementation

        # Create array buffers in memory
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))  # Initialize output with zeros

        # Load arguments into registers
        t.input_array("a0", array0)   # m0 pointer
        t.input_scalar("a1", m0_rows)  # m0 rows
        t.input_scalar("a2", m0_cols)  # m0 columns
        t.input_array("a3", array1)    # m1 pointer
        t.input_scalar("a4", m1_rows)  # m1 rows
        t.input_scalar("a5", m1_cols)  # m1 columns
        t.input_array("a6", array_out) # Result matrix pointer

        t.call("matmul")  # Invoke matrix multiplication

        # Verify output contents (only if successful execution)
        t.check_array(array_out, result)

        # Execute and validate exit code
        t.execute(code=code)

    def test_simple(self):
        m0 = [1, 2, 3, 4]    # 2x2 matrix
        m1 = [5, 6, 7, 8]    # 2x2 matrix
        expected = [19, 22, 43, 50]  # Result
        self.do_matmul(m0, 2, 2, m1, 2, 2, expected)

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
