# AppClustering

## Usage

```elixir
iex> AppClustering.clusterize("./assets/classifier-sample.json")
```

or with custom Jaccard similarity index (https://en.wikipedia.org/wiki/Jaccard_index)

```elixir
iex> AppClustering.clusterize("./assets/classifier-sample.json", 0.3)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `app_clustering` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:app_clustering, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/app_clustering>.

