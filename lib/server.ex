defmodule TodoServer do

  def start do
    spawn(TodoServer, :loop, [TodoList.new()])
  end

  def add_entry(server_pid, entry) do
    send(server_pid, {:add_entry, entry})
  end

  def entries(server_pid, date) do
    send(server_pid, {:entries, self(), date})

    receive do
      {:entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(server_pid, entry) when is_map(entry) do
    send(server_pid, {:update_entry, self(), entry})

    receive do
      :ok -> :ok
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(server_pid, id, update_fun) do
    send(server_pid, {:update_entry, self(), id, update_fun})

    receive do
      :ok -> :ok
    after
      5000 -> {:error, :timeout}
    end
  end

  def delete_entry(server_pid, id) do
    send(server_pid, {:delete_entry, self(), id})

    receive do
      :ok -> :ok
    after
      5000 -> {:error, :timeout}
    end
  end

  def loop(todo_list) do
    new_todo_list = 
      receive do
        message -> process_message(message, todo_list)
      end

    loop(new_todo_list)
  end

  defp process_message({:add_entry, entry}, todo_list) do
    TodoList.add_entry(todo_list, entry)
  end

  defp process_message({:entries, client_pid, date}, todo_list) do
    entries = TodoList.entries(todo_list, date)
    send(client_pid, {:entries, entries})
    todo_list
  end

  defp process_message({:update_entry, client_pid, entry}, todo_list) do
    list = TodoList.update_entry(todo_list, entry)
    send(client_pid, :ok)
    list
  end

  defp process_message({:update_entry, client_pid, id, fun}, todo_list) do
    list = TodoList.update_entry(todo_list, id, fun)
    send(client_pid, :ok)
    list
  end

  defp process_message({:delete_entry, client_pid, id}, todo_list) do
    list = TodoList.delete_entry(todo_list, id)
    send(client_pid, :ok)
    list
  end

  defp process_message(m, _) do
    # error
  end
end
