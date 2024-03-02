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

    %__MODULE__{
      name:
        name
        |> String.trim(),
      value:
        value
        |> String.trim()
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
end

defmodule HttpParser do
  @spec parse_request(String.t()) :: HttpRequest.t()
  def parse_request(request) do
    [head, body] =
      request
      |> split_request

    [method, path, version] =
      head
      |> split_head

    headers =
      head
      |> parse_headers

    HttpRequest.new(method, path, version, headers, body)
  end

  @spec split_request(String.t()) :: [String.t()]
  def split_request(request) do
    case String.split(request, "\r\n\r\n", parts: 2) do
      [head, body] ->
        [String.trim(head), String.trim(body)]

      [head] ->
        [String.trim(head), ""]

      [] ->
        ["", ""]
    end
  end

  @spec split_head(String.t()) :: [String.t()]
  def split_head(head) do
    head
    |> String.split("\r\n")
    |> Enum.at(0)
    |> String.split(" ")
  end

  @spec parse_headers(String.t()) :: [HttpHeader.t()]
  def parse_headers(head) do
    head
    |> String.split("\r\n")
    |> Enum.drop(1)
    |> Enum.map(&HttpHeader.parse/1)
  end
end
