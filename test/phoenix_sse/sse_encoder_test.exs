defmodule PhoenixSseWeb.SSEEncoderTest do
  use ExUnit.Case

  alias PhoenixSse.SSEEncoder

  test "writing an id" do
    encoded = SSEEncoder.encode(id: "abc")
    assert encoded == "id: abc\n\n"
  end

  test "writing an event" do
    encoded = SSEEncoder.encode(event: "update")
    assert encoded == "event: update\n\n"
  end

  test "writing data" do
    encoded = SSEEncoder.encode(data: "body")
    assert encoded == "data: body\n\n"
  end

  test "writing a comment" do
    encoded = SSEEncoder.encode(comment: "hi there")
    assert encoded == ":hi there\n\n"
  end

  test "writing only an id and a body" do
    encoded = SSEEncoder.encode(id: "id", data: "body")
    assert encoded == "id: id\ndata: body\n\n"
  end

  test "writing all the fields" do
    encoded =
      SSEEncoder.encode(
        id: "abc",
        event: "update",
        data: "body",
        comment: "rawr"
      )

    assert encoded == "id: abc\ndata: body\nevent: update\n:rawr\n\n"
  end
end
