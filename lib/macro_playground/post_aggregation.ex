# This example is taken directly from our druid_client
defmodule DruidClient.PostAggregation do
  @moduledoc """
  Druid PostAgg Builder. Uses macros to parse ast to generate equivalent in structs/json for druid queries

  ## Examples

      iex> PostAggregation.create "foo", do: quotient(field1 / field2 * 1 + (5 - field1 / field2), 20)
      %PostAggregation{
        fn: "quotient",
        name: "foo",
        type: "arithmetic",
        fields: [
          %PostAggregation{
            fn: "+",
            name: "foo",
            type: "arithmetic",
            fields: [
              %PostAggregation{
                fn: "*",
                name: "foo",
                type: "arithmetic",
                fields: [
                  %PostAggregation{
                    fn: "/",
                    name: "foo",
                    type: "arithmetic",
                    fields: [
                      %PostAggregation{field_name: "field1", type: "fieldAccess"},
                      %PostAggregation{field_name: "field2", type: "fieldAccess"}
                    ]
                  },
                  %PostAggregation{type: "constant", value: 1}
                ]
              },
              %PostAggregation{
                fn: "-",
                name: "foo",
                type: "arithmetic",
                fields: [
                  %PostAggregation{type: "constant", value: 5},
                  %PostAggregation{
                    fn: "/",
                    name: "foo",
                    type: "arithmetic",
                    fields: [
                      %PostAggregation{field_name: "field1", type: "fieldAccess"},
                      %PostAggregation{field_name: "field2", type: "fieldAccess"}
                    ]
                  }
                ]
              }
            ]
          },
          %PostAggregation{type: "constant", value: 20}
        ]
      }
  """

  @type t :: %__MODULE__{
          type: String.t(),
          name: String.t() | nil,
          fn: String.t() | nil,
          fields: [__MODULE__.t()] | nil,
          field_name: String.t() | nil,
          value: number() | nil,
          ordering: String.t() | nil
        }
  # todo: cardinality stuff
  defstruct [
    :type,
    :name,
    :fn,
    :fields,
    :field_name,
    :value,
    :ordering
  ]

  @fns [
    :+,
    :-,
    :*,
    :/,
    :quotient
  ]

  @doc """
  Takes anonymous function turns it into a post agg field

  ## Examples

      iex> PostAggregation.create(field1/field2 * field3)
      %PostAggregation{...}
  """
  defmacro create(name, do: expr) do
    name
    |> build_from_expr(expr)
    |> Macro.escape(unquote: true)
  end

  #  {:*, [line: 52],
  # [{:/, [line: 52],
  #   [{:+, [line: 52],
  #     [{:field_name1, [line: 52], nil},
  #     {:field_name2, [line: 52], nil}]}, 1.0]},
  #  50]}

  defp build_from_expr(name, {operator, _, params}) when operator in @fns do
    %__MODULE__{
      type: "arithmetic",
      fn: to_string(operator),
      name: name,
      fields: Enum.map(params, &build_from_expr(name, &1))
    }
  end

  # pretty naive right now
  defp build_from_expr(_, {field, _, nil}) do
    %__MODULE__{
      type: "fieldAccess",
      field_name: to_string(field)
    }
  end

  defp build_from_expr(_, n) when is_number(n) do
    %__MODULE__{
      type: "constant",
      value: n
    }
  end

  defp build_from_expr(f, v) do
    # error?
    {f, v}
  end
end
