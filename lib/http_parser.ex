defmodule HttpHeader do
  @enforce_keys [:name, :value]
  defstruct [:name, :value]

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t()
        }

  @spec new(String.t(), String.t()) :: t
  def new(name, value) do
    %__MODULE__{
      name:
        name
        |> String.trim(),
      value:
        value
        |> String.trim()
    }
  end

  @spec parse(String.t()) :: t
  def parse(header) do
    [name, value] =
      header
      |> String.split(":")
      |> Enum.map(&String.trim/1)

    %__MODULE__{
      name: name,
      value: value
    }
  end

  @spec to_string(%__MODULE__{name: String.t(), value: String.t()}) :: String.t()
  def to_string(%__MODULE__{name: name, value: value}) do
    "#{name}: #{value}"
  end
end

defmodule HttpRequest do
  @enforce_keys [:method, :path, :version, :headers, :body]
  defstruct [:method, :path, :version, :headers, :body]

  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          version: String.t(),
          headers: [HttpHeader.t()],
          body: String.t()
        }

  @spec new(String.t(), String.t(), String.t(), [HttpHeader.t()], String.t()) :: t
  def new(method, path, version, headers, body) do
    %__MODULE__{
      method:
        method
        |> String.trim(),
      path:
        path
        |> String.trim(),
      version:
        version
        |> String.trim(),
      headers: headers,
      body:
        body
        |> String.trim()
    }
  end

  @spec to_string(%__MODULE__{
          method: String.t(),
          path: String.t(),
          version: String.t(),
          headers: [HttpHeader.t()],
          body: String.t()
        }) ::
          String.t()
  def to_string(%__MODULE__{
        method: method,
        path: path,
        version: version,
        headers: headers,
        body: body
      }) do
    headers = headers |> Enum.map(&HttpHeader.to_string/1) |> Enum.join("\r\n")
    "#{method} #{path} #{version}\r\n#{headers}\r\n\r\n#{body}"
  end

  @spec split_request(String.t()) :: [String.t()]
  defp split_request(request) do
    case String.split(request, "\r\n\r\n", parts: 2) do
      [head, body] ->
        [head, body]

      [head] ->
        [head, ""]

      [] ->
        ["", ""]
    end
    |> Enum.map(&String.trim/1)
  end

  @spec split_head(String.t()) :: [String.t()]
  defp split_head(head) do
    head
    |> String.split("\r\n")
    |> Enum.at(0)
    |> String.split(" ")
  end

  @spec parse_headers(String.t()) :: [HttpHeader.t()]
  defp parse_headers(head) do
    head
    |> String.split("\r\n")
    |> Enum.drop(1)
    |> Enum.map(&HttpHeader.parse/1)
  end

  @spec parse(String.t()) :: t
  def parse(request) do
    [head, body] =
      request
      |> split_request

    [method, path, version] =
      head
      |> split_head

    headers =
      head
      |> parse_headers

    new(method, path, version, headers, body)
  end
end

defmodule HttpParser do
  def parse_request(request) do
    request
    |> HttpRequest.parse()
  end
end

# POST / HTTP/1.1\r\nHost: example.com\r\nContent-Length: 3\r\n\r\nHi!
