defmodule Shopping.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias Shopping.Repo

  alias Shopping.Categories
  alias Shopping.Categories.Category
  alias Shopping.Checklists.Checklist
  alias Shopping.Items.{Item, ItemsByGot}

  @type id :: pos_integer()

  @topic "shopping-items"

  @doc """
  Subscribe to updates to items
  """
  def subscribe(%Checklist{id: checklist_id}) do
    Phoenix.PubSub.subscribe(pub_sub(), topic(checklist_id))
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
    Repo.all(
      from i in Item,
        where: i.checklist_id == ^checklist_id,
        order_by: i.lcase_name,
        preload: :category
    )
  end

  @doc """
  Gets a single item.

  """
  def get_item!(id) do
    Repo.one!(from i in Item, where: i.id == ^id, preload: :category)
  end

  @doc """
  Creates a item on the checklist.
  """
  def create_item(checklist, attrs) do
    %Item{checklist_id: checklist.id}
    |> item_changeset(attrs)
    |> Repo.insert()
    |> preload_category()
    |> maybe_broadcast("item-created")
  end

  defp preload_category({:ok, item}), do: {:ok, Repo.preload(item, :category)}
  defp preload_category(err), do: err

  def create_changeset(checklist) do
    Item.changeset(%Item{checklist_id: checklist.id}, %{})
  end

  defp update_item(%Item{} = item, attrs) do
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
    item
    |> Repo.delete()
    |> maybe_broadcast("item-deleted")
  end

  def delete_item(id) do
    id
    |> get_item!()
    |> delete_item()
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

    got = sort_for_display(items[true] || [])
    to_get = sort_for_display(items[false] || [])

    %ItemsByGot{got: got, to_get: to_get}
  end

  @doc """
  Change whether an item has been got or not. Also resets `important?` to
  false
  """
  @spec change_got_to(Item.t() | id(), boolean) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def change_got_to(%Item{} = item, value) do
    item
    |> update_item(change_got_attrs(value))
    |> maybe_broadcast("item-changed-got")
  end

  def change_got_to(item_id, value) do
    item_id
    |> get_item!()
    |> change_got_to(value)
  end

  defp change_got_attrs(true) do
    %{important?: false, got?: true, last_got: DateTime.utc_now()}
  end

  defp change_got_attrs(false) do
    %{important?: false, got?: false}
  end

  @doc """
  Marks an item as important
  """
  @spec change_importance_to(Item.t() | id(), boolean) ::
          {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def change_importance_to(%Item{} = item, value) do
    item
    |> update_item(%{important?: value})
    |> maybe_broadcast("item-changed-importance")
  end

  def change_importance_to(item_id, value) do
    item_id
    |> get_item!()
    |> change_importance_to(value)
  end

  def set_category(%Item{} = item, %Category{} = category) do
    with {:ok, item} <- update_item(item, %{category_id: category.id}) do
      {:ok, %{item | category: category}}
    end
    |> maybe_broadcast("item-changed-category")
  end

  def set_category(%Item{} = item, category_id) do
    set_category(item, Categories.get_category!(category_id))
  end

  @doc """
  Remove the item matching the id of this item in the list of items
  """
  @spec remove_item_from_list(list(Item.t()), Item.t()) :: list(Item.t())
  def remove_item_from_list(items, remove_me) do
    case remove_item_from_list(items, remove_me, []) do
      {:found, new_items} -> new_items
      :notfound -> items
    end
  end

  defp remove_item_from_list([], _remove_me, _acc) do
    :notfound
  end

  defp remove_item_from_list([%{id: id} | t], %{id: id}, acc) do
    {:found, Enum.reverse(acc, t)}
  end

  defp remove_item_from_list([h | tail], remove_me, acc) do
    remove_item_from_list(tail, remove_me, [h | acc])
  end

  def add_to_list(item_list, item) do
    [item | item_list]
    |> Enum.uniq_by(& &1.id)
    |> sort_for_display()
  end

  @doc """
  Replace the item matching the id in the list of items
  """
  @spec update_in_list_of_items(list(Item.t()), Item.t()) :: list(Item.t())
  def update_in_list_of_items(items, changed_item) do
    case update_in_list_of_items(items, changed_item, []) do
      :notfound -> items
      {:found, new_items} -> new_items
    end
  end

  defp update_in_list_of_items([], _changed_item, _acc) do
    :notfound
  end

  defp update_in_list_of_items([%{id: id} | t], %{id: id} = changed_item, acc) do
    {:found,
     [changed_item | acc]
     |> Enum.reverse(t)
     |> sort_for_display()}
  end

  defp update_in_list_of_items([h | t], changed_item, acc) do
    update_in_list_of_items(t, changed_item, [h | acc])
  end

  def sort_for_display(items) do
    Enum.sort_by(items, &{-item_ordering(&1), !&1.important?, &1.name})
  end

  defp item_ordering(item) do
    item.category.ordering
  end

  defp item_changeset(item, attrs) do
    attrs = lcase_name(attrs)

    item
    |> Map.update!(:category_id, fn
      nil -> 0
      id -> id
    end)
    |> Item.changeset(attrs)
  end

  defp lcase_name(%{name: name} = attrs) when not is_nil(name) do
    Map.put(attrs, :lcase_name, String.downcase(name))
  end

  defp lcase_name(%{"name" => name} = attrs) when not is_nil(name) do
    Map.put(attrs, "lcase_name", String.downcase(name))
  end

  defp lcase_name(attrs), do: attrs

  defp maybe_broadcast({:ok, %Item{checklist_id: checklist_id} = item} = result, message) do
    Phoenix.PubSub.broadcast!(pub_sub(), topic(checklist_id), {message, item})
    result
  end

  defp maybe_broadcast(result, _), do: result

  defp pub_sub do
    :shopping_web
    |> Application.fetch_env!(ShoppingWeb.Endpoint)
    |> Keyword.fetch!(:pubsub_server)
  end

  defp topic(checklist_id), do: "#{@topic}_#{checklist_id}"
end
