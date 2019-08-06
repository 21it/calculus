defmodule User do
  use Calculus
  require Record

  @moduledoc """
  OOP-like `User` data type example.

  Internal representation of the `state` is record,
  but it's completely hidden inside this module.

  This data type have:

  - public mutable `name` field (`get_name/1`, `set_name/2` methods)
  - protected immutable `id` field (`get_id/1` method)
  - private `balance` field (used internally in `deposit/2` and `withdraw/2` methods)
  """

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

  @type id :: pos_integer
  @type name :: String.t()

  defmacrop with_valid_name(name, do: code) do
    quote location: :keep do
      name = unquote(name)

      ~r/^[A-Z][a-z]+$/
      |> Regex.match?(name)
      |> case do
        true -> unquote(code)
        false -> raise("invalid User name #{inspect(name)}")
      end
    end
  end

  @spec new(id: id, name: name) :: t
  def new(id: id, name: name) when is_integer(id) and id > 0 and is_binary(name) do
    with_valid_name name do
      user(id: id, name: name, balance: 0)
      |> construct()
    end
  end

  @spec get_name(t) :: name
  def get_name(it) do
    it
    |> eval(:get_name)
    |> return()
  end

  @spec set_name(t, name) :: t
  def set_name(it, name) when is_binary(name) do
    with_valid_name name do
      it
      |> eval({:set_name, name})
    end
  end

  @spec get_id(t) :: id
  def get_id(it) do
    it
    |> eval(:get_id)
    |> return()
  end

  @spec deposit(t, pos_integer) :: t
  def deposit(it, amount) when is_integer(amount) and amount > 0 do
    it
    |> eval({:deposit, amount})
  end

  @spec withdraw(t, pos_integer) :: t
  def withdraw(it, amount) when is_integer(amount) and amount > 0 do
    it
    |> eval({:withdraw, amount})
  end
end
