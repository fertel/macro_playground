defmodule StructCreator do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro create_struct(do: block) do
    quote do
      Module.register_attribute(__MODULE__, :fields, accumulate: true)
      unquote(block)

      keys = Enum.map(@fields, fn({k, _})->
         k
      end)

      defstruct keys

      def new do
        Enum.reduce(@fields, %__MODULE__{}, fn ({field, opts}, acc)->
          default = opts[:default]
          if default do
            Map.put(acc, field, default_value(default))
          else
            Map.put(acc, field, nil)
          end
        end)
      end
      defp default_value(val) when is_function(val) do
        val.()
      end
      defp default_value(val), do: val
    end
  end

  defmacro field(name, opts \\ []) do
    quote do
      Module.put_attribute(__MODULE__, :fields, {unquote(name), unquote(opts)})
    end
  end
end

defmodule MyStruct do
  use StructCreator

  create_struct do
    field :field1, default: &DateTime.utc_now/0
    field :field2, default: 1
    field :field3
  end

end


