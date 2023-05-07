defmodule Shopping.Categories do
  @moduledoc """
  Context for categories
  """
  import Ecto.Query

  alias Shopping.Categories.Category
  alias Shopping.Repo

  @doc """
  Create a new category
  """
  @spec create_category(map()) :: {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  List  all categories in order of ordering, descending
  """
  def list_all_categories() do
    Repo.all(from c in Category, order_by: [desc: c.ordering])
  end

  def get_category!(category_id) do
    Repo.get!(Category, category_id)
  end
end
