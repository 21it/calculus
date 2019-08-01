defmodule User do
  use Calculus
  require Record

  Record.defrecordp(:user,
    id: nil,
    name: nil,
    balance: nil
  )

  defcalculus user(id: id, name: name, balance: balance) = it do
    :get_name ->
      Calculus.new(it, name)

    {:set_name, new_name} ->
      it
      |> user(name: new_name)
      |> Calculus.new(name)

    :get_id ->
      Calculus.new(it, id)

    {:deposit, amount} ->
      it
      |> user(balance: balance + amount)
      |> Calculus.new(:ok)

    {:withdraw, amount} when amount <= balance ->
      it
      |> user(balance: balance - amount)
      |> Calculus.new(:ok)

    {:withdraw, _} ->
      Calculus.new(it, :insufficient_funds)
  end

  def new(id: id, name: name) when is_integer(id) and id > 0 and is_binary(name) do
    user(id: id, name: name, balance: 0)
    |> Calculus.new(:ok)
    |> pure()
  end

  def get_name(it) do
    it
    |> eval(:get_name)
    |> Calculus.returns()
  end

  def set_name(it, name) when is_binary(name) do
    eval(it, {:set_name, name})
  end

  def get_id(it) do
    it
    |> eval(:get_id)
    |> Calculus.returns()
  end

  def deposit(it, amount) when is_integer(amount) and amount > 0 do
    eval(it, {:deposit, amount})
  end

  def withdraw(it, amount) when is_integer(amount) and amount > 0 do
    eval(it, {:withdraw, amount})
  end
end
