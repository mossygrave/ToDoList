-module(todo_app).
-export([start/0, add_task/1, view_tasks/0, delete_task/1, mark_completed/1, loop/1]).

% File to store tasks
-define(TODO_FILE, "todo_list.txt").

% Start the application loop
start() ->
    io:format("Welcome to the Erlang To-Do List!~n"),
    loop(read_tasks()).

% Application loop: Handles user input and calls appropriate functions
loop(Tasks) ->
    io:format("~nOptions:~n 1. Add Task~n 2. View Tasks~n 3. Delete Task~n 4. Mark Task as Completed~n 5. Exit~n"),
    Input = io:get_line("Choose an option: "),
    case string:trim(Input) of
        "1" ->
            Task = io:get_line("Enter task: "),
            NewTasks = add_task(string:trim(Task)),
            loop(NewTasks);
        "2" ->
            view_tasks(),
            loop(Tasks);
        "3" ->
            view_tasks(),
            Index = io:get_line("Enter task number to delete: "),
            case catch list_to_integer(string:trim(Index)) of
                N when is_integer(N) ->
                    NewTasks = delete_task(N),
                    loop(NewTasks);
                _ ->
                    io:format("Invalid input. Please enter a number.~n"),
                    loop(Tasks)
            end;
        "4" ->
            view_tasks(),
            Index = io:get_line("Enter task number to mark as completed: "),
            case catch list_to_integer(string:trim(Index)) of
                N when is_integer(N) ->
                    NewTasks = mark_completed(N),
                    loop(NewTasks);
                _ ->
                    io:format("Invalid input. Please enter a number.~n"),
                    loop(Tasks)
            end;
        "5" ->
            io:format("Goodbye!~n");
        _ ->
            io:format("Invalid choice. Try again.~n"),
            loop(Tasks)
    end.

% Read tasks from the file. Returns an empty list if the file doesn't exist
read_tasks() ->
    case file:read_file(?TODO_FILE) of
        {ok, Bin} ->
            binary_to_term(Bin);
        _ ->
            []
    end.

% Write tasks to the file for persistence
write_tasks(Tasks) ->
    file:write_file(?TODO_FILE, term_to_binary(Tasks)).

% Add a task to the list and save it
add_task(Task) ->
    Tasks = read_tasks(),
    NewTasks = Tasks ++ [{Task, false}], % False indicates the task is not completed
    write_tasks(NewTasks),
    io:format("Task added: ~s~n", [Task]),
    NewTasks.

% Display the tasks with their completion status
view_tasks() ->
    Tasks = read_tasks(),
    lists:foldl(fun({Task, Completed}, Index) -> 
        Status = if Completed -> "[X]"; true -> "[ ]" end,
        io:format("~w. ~s ~s~n", [Index, Status, Task]) 
    end, 1, Tasks).

% Delete a task by its index and update the file
delete_task(Index) ->
    Tasks = read_tasks(),
    case lists:nth(Index, Tasks) of
        {Task, _} ->
            NewTasks = lists:delete({Task, false}, Tasks) ++ lists:delete({Task, true}, Tasks),
            write_tasks(NewTasks),
            io:format("Task deleted: ~s~n", [Task]),
            NewTasks;
        _ ->
            io:format("Invalid task number.~n"),
            Tasks
    end.

% Mark a task as completed
mark_completed(Index) ->
    Tasks = read_tasks(),
    case lists:nth(Index, Tasks) of
        {Task, false} -> % If the task is not yet completed
            NewTasks = lists:sublist(Tasks, Index - 1) ++ [{Task, true}] ++ lists:nthtail(Index, Tasks),
            write_tasks(NewTasks),
            io:format("Task marked as completed: ~s~n", [Task]),
            NewTasks;
        {Task, true} ->
            io:format("Task is already completed.~n"), Tasks;
        _ ->
            io:format("Invalid task number.~n"),
            Tasks
    end.

-export([]).
