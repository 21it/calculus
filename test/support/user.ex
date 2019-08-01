defmodule User do
  use Calculus
  require Record

  Record.defrecordp(:user,
    id: nil,
    name: nil,
    balance: nil
  )

  defcalculus user(id: id, name: name, balance: balance) = state do
    :get_name ->
      calculus(
        state: state,
        return: name
      )

    {:set_name, new_name} ->
      calculus(
        state: user(state, name: new_name),
        return: name
      )

    :get_id ->
      calculus(
        state: state,
        return: id
      )

    {:deposit, amount} ->
      calculus(
        state: user(state, balance: balance + amount),
        return: :ok
      )

    {:withdraw, amount} when amount <= balance ->
      calculus(
        state: user(state, balance: balance - amount),
        return: :ok
      )

    {:withdraw, _} ->
      calculus(
        state: state,
        return: :insufficient_funds
      )
  end

  def new(id: id, name: name) when is_integer(id) and id > 0 and is_binary(name) do
    user(id: id, name: name, balance: 0)
    |> construct()
  end

  def get_name(it) do
    it
    |> eval(:get_name)
    |> return()
  end

  def set_name(it, name) when is_binary(name) do
    it
    |> eval({:set_name, name})
  end

  def get_id(it) do
    it
    |> eval(:get_id)
    |> return()
  end

  def deposit(it, amount) when is_integer(amount) and amount > 0 do
    it
    |> eval({:deposit, amount})
  end

  def withdraw(it, amount) when is_integer(amount) and amount > 0 do
    it
    |> eval({:withdraw, amount})
  end
end
