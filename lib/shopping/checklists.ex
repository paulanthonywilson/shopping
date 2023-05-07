defmodule Shopping.Checklists do
  @moduledoc """
  The Checklists context.
  """

  import Ecto.Query, warn: false
  alias Shopping.Repo

  alias Shopping.Checklists.Checklist

  @doc """
  Returns the list of checklists.

  ## Examples

      iex> list_checklists()
      [%Checklist{}, ...]

  """
  def list_checklists do
    Repo.all(Checklist)
  end

  @doc """
  Gets a single checklist.

  Raises `Ecto.NoResultsError` if the Checklist does not exist.

  ## Examples

      iex> get_checklist!(123)
      %Checklist{}

      iex> get_checklist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_checklist!(id), do: Repo.get!(Checklist, id)

  @doc """
  Creates a checklist.

  ## Examples

      iex> create_checklist(%{field: value})
      {:ok, %Checklist{}}

      iex> create_checklist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_checklist(attrs \\ %{}) do
    %Checklist{}
    |> Checklist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a checklist.

  ## Examples

      iex> update_checklist(checklist, %{field: new_value})
      {:ok, %Checklist{}}

      iex> update_checklist(checklist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_checklist(%Checklist{} = checklist, attrs) do
    checklist
    |> Checklist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a checklist.

  ## Examples

      iex> delete_checklist(checklist)
      {:ok, %Checklist{}}

      iex> delete_checklist(checklist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_checklist(%Checklist{} = checklist) do
    Repo.delete(checklist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking checklist changes.

  ## Examples

      iex> change_checklist(checklist)
      %Ecto.Changeset{data: %Checklist{}}

  """
  def change_checklist(%Checklist{} = checklist, attrs \\ %{}) do
    Checklist.changeset(checklist, attrs)
  end
end
