defmodule DiskSpace do
  defstruct index: nil, size: 0, is_empty: false 

  @type t() :: %__MODULE__{
    index: non_neg_integer(),
    size: non_neg_integer(),
    is_empty: boolean()
  }
end