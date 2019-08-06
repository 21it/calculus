defmodule UserTest do
  use ExUnit.Case

  @id 1
  @name "Jessy"

  setup do
    {
      :ok,
      %{x: User.new(id: @id, name: @name)}
    }
  end

  test "User.is?/1 default method", %{x: x} do
    assert User.is?(x)
    refute User.is?(id: @id, name: @name)
  end

  test "User.return/1 default method", %{x: x} do
    assert :ok == User.return(x)
  end

  test "User.new/1 smart constructor success" do
    x = User.new(id: @id, name: @name)
    assert User.is?(x)
    assert is_function(x, 2)
  end

  test "User.new/1 smart constructor fail" do
    assert_raise FunctionClauseError,
                 "no function clause matching in User.new/1",
                 fn ->
                   User.new(id: :BANG, name: @name)
                 end

    assert_raise RuntimeError,
                 "invalid User name \"jessy\"",
                 fn ->
                   User.new(id: @id, name: "jessy")
                 end
  end

  test "User.get_name/1 and User.get_id/1 getters", %{x: x} do
    assert @name == User.get_name(x)
    assert @id == User.get_id(x)
  end

  test "User.set_name/2 smart setter success", %{x: x0} do
    new_name = "Bob"
    x1 = User.set_name(x0, new_name)
    assert User.is?(x1)
    assert @name == User.return(x1)
    assert new_name == User.get_name(x1)
  end

  test "User.set_name/2 smart setter fail", %{x: x} do
    assert_raise RuntimeError,
                 "invalid User name \"jessy\"",
                 fn ->
                   User.set_name(x, "jessy")
                 end
  end

  test "User.deposit/2 and User.withdraw/2 methods", %{x: x0} do
    x1 = User.withdraw(x0, 50)
    assert :insufficient_funds == User.return(x1)
    x2 = User.deposit(x1, 100)
    assert :ok == User.return(x2)
    x3 = User.withdraw(x2, 50)
    assert :ok == User.return(x3)
    x4 = x3 |> User.withdraw(25) |> User.withdraw(25)
    assert :ok == User.return(x4)
    assert :insufficient_funds == x4 |> User.withdraw(1) |> User.return()
  end

  test "Value encapsulation", %{x: x} do
    assert_raise RuntimeError,
                 "For value of the type User got unsupported METHOD={:withdraw, 100} with SECURITY_KEY=nil",
                 fn ->
                   x.({:withdraw, 100}, nil)
                 end
  end

  test "Module encapsulation" do
    assert_raise RuntimeError,
                 "Value of the type User can't be created in other module UserTest",
                 fn ->
                   User.return(&{&1, &2})
                 end
  end
end
