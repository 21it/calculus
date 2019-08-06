defmodule StackTest do
  use ExUnit.Case

  setup do
    {
      :ok,
      %{x: Stack.new([1, 2, 3])}
    }
  end

  test "Stack.is?/1 default method", %{x: x} do
    assert Stack.is?(x)
    refute Stack.is?([1, 2, 3])
  end

  test "Stack.return/1 default method", %{x: x} do
    assert :ok == Stack.return(x)
  end

  test "Stack.new/1 smart constructor success" do
    x = Stack.new([1, 2, 3])
    assert Stack.is?(x)
    assert is_function(x, 2)
  end

  test "Stack.new/1 smart constructor fail" do
    assert_raise FunctionClauseError,
                 "no function clause matching in Stack.new/1",
                 fn ->
                   Stack.new(:BANG)
                 end
  end

  test "Stack.push/2 method", %{x: x0} do
    x1 = Stack.push(x0, 99)
    assert Stack.is?(x1)
    assert is_function(x1, 2)
    assert :ok == Stack.return(x1)
    assert x1 != x0
  end

  test "Stack.pop/1 method", %{x: x0} do
    x1 = Stack.pop(x0)
    assert Stack.is?(x1)
    assert is_function(x1, 2)
    assert {:ok, 1} == Stack.return(x1)
    assert x1 != x0
  end

  test "Can compose methods", %{x: x0} do
    x1 =
      x0
      |> Stack.pop()
      |> Stack.pop()
      |> Stack.pop()

    assert Stack.is?(x1)
    assert is_function(x1, 2)
    assert {:ok, 3} == Stack.return(x1)
    assert x1 != x0
  end

  test "Can compose methods with return", %{x: x} do
    assert {:ok, 99} ==
             x
             |> Stack.push(99)
             |> Stack.pop()
             |> Stack.return()
  end

  test "Can not pop empty stack", %{x: x0} do
    x1 =
      x0
      |> Stack.pop()
      |> Stack.pop()
      |> Stack.pop()
      |> Stack.pop()

    assert {:error, :empty_stack} == Stack.return(x1)
    assert x1 == Stack.pop(x1)
  end

  test "Value encapsulation", %{x: x} do
    assert_raise RuntimeError,
                 "For value of the type Stack got unsupported METHOD=:pop with SECURITY_KEY=nil",
                 fn ->
                   x.(:pop, nil)
                 end
  end

  test "Module encapsulation" do
    assert_raise RuntimeError,
                 "Value of the type Stack can't be created in other module StackTest",
                 fn ->
                   Stack.return(&{&1, &2})
                 end
  end
end
