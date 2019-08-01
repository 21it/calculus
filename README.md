# Calculus

Encapsulation. One of the basic principles of modern software development. We hide implementation details of the entity and expose to outer world just safe interface for this entity. That's great idea because of many reasons. Erlang and Elixir ecosystem supports this principle a lot: we have private functions and macros inside our modules, we have internal states inside our processes. But unfortunately there is one place where encapsulation is completely broken at the moment (Erlang/OTP 22, Elixir 1.9.1). This place is term of user defined data type, like record or structure.

This package introduces another way to define a new data type and safe interface for it. Inspired by Alonzo Church. Powered by Lambda Calculus.

<img src="priv/img/logo.png" width="300"/>

## Problem

First of all, let's figure out what's wrong with Elixir structs. For instance let's consider `URI` data type which is part of standard library (Elixir 1.9.1).

First statement:

- **default data constructor `%URI{}` is always public**

Indeed, nothing stops you to write in any place or your program something like this:

```elixir
iex> uri = %URI{host: :BANG}
%URI{
  authority: nil,
  fragment: nil,
  host: :BANG,
  path: nil,
  port: nil,
  query: nil,
  scheme: nil,
  userinfo: nil
}
```

Is `uri` term valid instance of the `URI` type? Probably not, let's try to do something with it:

```elixir
iex> URI.to_string(uri)

** (FunctionClauseError) no function clause matching in String.contains?/2
```

Oops, our self-made instance of `URI` type caused exception. Default constructor does not validate arguments, and this is a problem in our case because `host` at least have to be instance of `String.t` type. As a solution of this problem, developers introduced concept of [smart constructors](https://wiki.haskell.org/Smart_constructors). Do we have a smart constructor for `URI` type? Probably here it is:

```elixir
iex> uri = URI.parse("https://hello.world")
%URI{
  authority: "hello.world",
  fragment: nil,
  host: "hello.world",
  path: nil,
  port: 443,
  query: nil,
  scheme: "https",
  userinfo: nil
}
```

Beautiful. We have a smart constructor which creates instance of the type `URI` properly. But remember our first statement? Default constructor is always public, which means that we can just **HOPE** that people will use smart constructor instead of default one. Concept of the smart constructors implies fact that we will hide default unsafe constructors. But we can't reach it with Elixir structs.

Second statement:

- **all fields of `URI` instance are public**

That's also true, because we can access any field of `URI` type instance in any place of our program (where this instance exists):

```elixir
iex> uri = URI.parse("https://hello.world")
iex> %URI{host: host} = url
iex> host
"hello.world"
```

Concept of Elixir structs does not distinguish fields which are meant to be used in external world and fields which are meant only for internal usage. Sad but true, we just can write some documentation and **HOPE** that people will read it and follow our guidelines.

Third statement:

- **all fields of `URI` instance are mutable (in functional meaning)**

This sentence looks weird because all Erlang/Elixir terms are immutable, isn't it? I will explain what I meant by example:

```elixir
iex> uri = URI.parse("https://hello.world")
iex> uri = %URI{uri | port: -80}
iex> URI.to_string(uri)
"https://hello.world:-80"
```

Let's consider what happened here:

- We create proper `uri` value with smart constructor
- We create new value based on `uri` by replacing the port with -80
- We apply `to_string` function to new `uri` value (and what scares - it worked)

This means that even if smart constructor has been used to create proper value of the type `URI`, we can just **HOPE** that this proper value will not be corrupted later.

We have 3 statements about Elixir structures. Don’t you think that we rely on **HOPE** too much when we are using structures? As we know, `Hope is Not a Strategy ©`. What if I will say you that we can have `real smart constructors`, `real private fields`, `real immutable fields` and many other fun things almost for free? And we can do it without any relatively expensive stuff like processes? Well, we really can, and all that we need - just one simple thing. It is lambda function.

## Installation

The package can be installed by adding `calculus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calculus, "~> 0.1.0"}
  ]
end
```
