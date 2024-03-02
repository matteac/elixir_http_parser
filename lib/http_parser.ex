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
      |> String.split("\r\n\r\n")
      |> Enum.map(&String.trim/1)

    [method, path, version] =
      head
      |> String.split("\r\n")
      |> Enum.at(0)
      |> String.split(" ")

    headers =
      head
      |> String.split("\r\n")
      |> Enum.drop(1)
      |> Enum.map(&HttpHeader.parse/1)

    HttpRequest.new(method, path, version, headers, body)
  end
end
