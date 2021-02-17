defmodule AssistABot do
  @moduledoc """
  Documentation for `AssistABot`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AssistABot.hello()
      :world

  """
  def hello do
    :world
  end

  def start_scheduler do
    Taskerville.start()
  end
end
