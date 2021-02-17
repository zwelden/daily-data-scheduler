defmodule AssistABotTest do
  use ExUnit.Case
  doctest AssistABot

  test "greets the world" do
    assert AssistABot.hello() == :world
  end
end
