defmodule Using do
  defmacro __using__(_) do
    quote do
      alias Calendar.ISO
      @field "hi"
      def my_module() do
        __MODULE__
      end
      def macro_module() do
        unquote(__MODULE__)
      end
    end
  end
end

defmodule TestUsing do
  use Using
  def field do
    @field
  end

  def aliased? do

  end
end


