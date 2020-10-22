defmodule Shopping.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias Shopping.Repo

  alias Shopping.Checklists.Checklist
  alias Shopping.Items.{Item, ItemsByGot}

  @topic "shopping-items"

  @doc """
  Subscribe to updates to items
  """
  def subscribe do
    Phoenix.PubSub.subscribe(pub_sub(), @topic)
  end

  @doc """
  Returns the list of items.
  """
  @spec list_items :: list(Item.t())
  def list_items do
    Repo.all(Item)
  end

  def list_items(%Checklist{} = checklist) do
    list_items(checklist.id)
  end

  def list_items(checklist_id) do
    Repo.all(from i in Item, where: i.checklist_id == ^checklist_id, order_by: i.lcase_name)
  end

  @doc """
  Gets a single item.

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item on the checklist.
  """
  def create_item(checklist, attrs) do
    %Item{checklist_id: checklist.id}
    |> item_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> item_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    item_changeset(item, attrs)
  end

  def list_by_got(%Checklist{} = checklist) do
    items =
      checklist
      |> list_items()
      |> Enum.group_by(& &1.got?)

    got = items[true] || []
    to_get = sort_in_order_of_importance(items[false] || [])

    %ItemsByGot{got: got, to_get: to_get}
  end

  def change_importance_to(%Item{} = item, value) do
    update_item(item, %{important?: value})
    |> maybe_broadcast("item-change-importance")
  end

  def change_importance_to(item_id, value) do
    item_id
    |> get_item!()
    |> change_importance_to(value)
  end

  def update_importance_in_list_of_items(items, changed_item) do
    case Enum.find_index(items, fn item -> item.id == changed_item.id end) do
      nil ->
        items

      i ->
        List.replace_at(items, i, changed_item)
        |> sort_in_order_of_importance()
    end
  end

  

  defp sort_in_order_of_importance(items) do
    Enum.sort_by(items, &{!&1.important?, &1.lcase_name})
  end

  defp item_changeset(item, attrs) do
    attrs = lcase_name(attrs)
    Item.changeset(item, attrs)
  end

  defp lcase_name(attrs) do
    case Map.get(attrs, :name) do
      nil -> attrs
      name -> Map.put(attrs, :lcase_name, String.downcase(name))
    end
  end

  defp maybe_broadcast({:ok, item} = result, message) do
    broadcast({message, item})
    result
  end

  defp maybe_broadcast(result, _), do: result

  defp pub_sub do
    :shopping_web
    |> Application.fetch_env!(ShoppingWeb.Endpoint)
    |> Keyword.fetch!(:pubsub_server)
  end

  defp broadcast(event) do
    Phoenix.PubSub.broadcast!(pub_sub(), @topic, event)
  end
end
