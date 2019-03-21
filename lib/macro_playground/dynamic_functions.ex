defmodule DynamicFunctions do
fields = [
  add: :+,
  subtract: :-,
  multiply: :*,
  divide: :/
]

Enum.each(fields, fn({f, method}) ->
  def unquote(f)(left, right) do
    apply(Kernel, unquote(method), [left, right])
  end
end)

end
