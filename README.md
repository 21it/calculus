# Calculus

Encapsulation. One of the basic principles of modern software development. We hide implementation details of the entity and expose to outer world just safe interface for this entity. That's great idea because of many reasons. Erlang and Elixir ecosystem supports this principle a lot: we have private functions and macros inside our modules, we have internal states inside our processes. But unfortunately there is one place where encapsulation is completely broken at the moment (Erlang/OTP 22, Elixir 1.9.1). This place is term of user defined data type, like record or structure.

This package introduces another way to define a new data type and safe interface for it. Inspired by Alonzo Church. Powered by Lambda Calculus.

<img src="priv/img/logo.png" width="300"/>

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `calculus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calculus, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/calculus](https://hexdocs.pm/calculus).
