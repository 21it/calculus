defmodule StackTest do
  use ExUnit.Case

  setup do
    {
      :ok,
      %{stack: Stack.new([1, 2, 3])}
    }
  end

  test "Stack.is?/1 default method", %{stack: x} do
    assert Stack.is?(x)
    refute Stack.is?([1, 2, 3])
  end

  test "Stack.return/1 default method", %{stack: x} do
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

  test "Stack.push/2 method", %{stack: x0} do
    x1 = Stack.push(x0, 99)
    assert Stack.is?(x1)
    assert is_function(x1, 2)
    assert :ok == Stack.return(x1)
    assert x1 != x0
  end

  test "Stack.pop/1 method", %{stack: x0} do
    x1 = Stack.pop(x0)
    assert Stack.is?(x1)
    assert is_function(x1, 2)
    assert {:ok, 1} == Stack.return(x1)
    assert x1 != x0
  end

  test "Can compose methods", %{stack: x0} do
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

  test "Can compose methods with return", %{stack: x} do
    assert {:ok, 99} ==
             x
             |> Stack.push(99)
             |> Stack.pop()
             |> Stack.return()
  end

  test "Can not pop empty stack", %{stack: x0} do
    x1 =
      x0
      |> Stack.pop()
      |> Stack.pop()
      |> Stack.pop()
      |> Stack.pop()

    assert {:error, :empty_stack} == Stack.return(x1)
    assert x1 == Stack.pop(x1)
  end
end
