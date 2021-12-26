program index_draw;
{$H+}
uses
    avl_tree, matrixes, sysutils;
type
    id_to_node_t = record
                    id: Int64;
                    node_info: pair_t;
                end;
    arr_of_id_t = array of id_to_node_t;
var
    counter: integer;
    matrix_file: text;
    mode, name_of_file: string;
    matrix_tree: node_ptr_t;
    str_container: arr_of_string_t;

procedure Sort_container_by_id(var id_array: arr_of_id_t);
var
    temp: id_to_node_t;
    count_i, count_j: integer;
begin
    for count_i := 0 to length(id_array) - 2 do
    begin
        count_j := count_i + 1;
        while (id_array[count_j].id < id_array[count_j-1].id) and (count_j > 0) do
        begin
            temp := id_array[count_j];
            id_array[count_j] := id_array[count_j-1];
            id_array[count_j-1] := temp;
            count_j := count_j - 1;
        end;
    end;
end;

function Get_label_id(log_str: arr_of_string_t): integer; 
var
    answer, control: integer;
begin
    Val(log_str[0], answer, control);
        if (control <> 0) then Drop_exception;

    Get_label_id := answer;
end;    

function Get_label_node(container: arr_of_string_t): pair_t;
var
    counter, control: integer;
    logged_str, number_string: string;
    answer: pair_t;
begin
    if length(container) <> 3 then
        Drop_exception()
    else
    begin
    {первая координата}
        logged_str := container[1];
        number_string := '';
        for counter := 9 to Length(logged_str) do
        begin
            number_string := number_string + logged_str[counter]
        end;
        Val(number_string, answer.first.index_i, control);
            if (control <> 0) then Drop_exception();
    {вторая координата}
        logged_str := container[2];
        number_string := '';
        counter := 1;
        repeat
            begin
                number_string := number_string + logged_str[counter];
                counter := counter + 1;
            end;
        until logged_str[counter] = '\';
        Val(number_string, answer.first.index_j, control);
            if (control <> 0) then Drop_exception();
    {вещественное число}
        number_string := '';
        counter := counter + 2;
        repeat
            begin
                number_string := number_string + logged_str[counter];
                counter := counter + 1;
            end;
        until logged_str[counter] = '"';
        Val(number_string, answer.second, control);
            if (control <> 0) then Drop_exception();
    end;

    Get_label_node := answer;
end;

function From_dot_to_tree(name_of_file: string): node_ptr_t;
var
    answer: node_ptr_t;
    line_of_file: string;
    counter, id: integer;
    node_info: pair_t;
    node_container: arr_of_id_t;
    str_container: arr_of_string_t;
begin

    if FileExists('./catalogue/' + name_of_file) then
    begin
        assign(matrix_file, './catalogue/' + name_of_file);
        reset(matrix_file)
    end
    else
    begin
        writeln('ERROR: FILE NOT FOUND');
        Halt
    end;

    SetLength(node_container, 0);
    repeat
        begin
            repeat
            begin
                readln(matrix_file, line_of_file);
                str_container := Divide_by_words(line_of_file);
            end;
            until str_container[0] <> '';
            
            if (str_container[0] = 'digraph') or
               (str_container[0] = '{') then Continue;

            if (str_container[0] = '}') then
            begin
                writeln('ERROR: NO INFO');
                Halt
            end;

            if (str_container[0] = '//edges') then Break;

            id := Get_label_id(str_container);
            node_info := Get_label_node(str_container);

            SetLength(node_container, Length(node_container) + 1);
            node_container[Length(node_container) - 1].id := id;
            node_container[length(node_container) - 1].node_info := node_info;
        end
    until eof(matrix_file);
    close(matrix_file);

    Sort_container_by_id(node_container);

    answer := nil;
    for counter := 0 to Length(node_container)-1 do
    begin
        answer := Insert(answer, node_container[counter].node_info)
    end;
    From_dot_to_tree := answer
end;

function Write_node(matrix_node: node_ptr_t; id: integer): string;
var
    answer, ind_i, ind_j, value, num_id: string;
begin
{150: (2,3) 33.5 152 NULL}
    Str(id, num_id);
    Str(matrix_node^.value.first.index_i, ind_i);
    Str(matrix_node^.value.first.index_j, ind_j);
    Str(matrix_node^.value.second:1:1, value);
    answer := '{' + num_id + ' (' + ind_i + ', ' + ind_j + ') ' + value;
    if (matrix_node^.left <> Nil) then
    begin
        Str(id*2, num_id);
        answer := answer + ' ' + num_id;
    end
    else
    begin
        answer := answer + ' NULL';
    end;

    if (matrix_node^.right <> Nil) then
    begin
        Str(id*2+1, num_id);
        answer := answer + ' ' + num_id;
    end
    else
    begin
        answer := answer + ' NULL';
    end;

    answer := answer + '}';
    write_node := answer;
end;

procedure Write_root_left_right(matrix_tree: node_ptr_t; indexer: integer);
begin
    writeln(Write_node(matrix_tree, indexer));

    if (matrix_tree^.left <> Nil) then
    begin
        Write_root_left_right(matrix_tree^.left, indexer*2);
    end;

    if (matrix_tree^.right <> Nil) then
    begin
        Write_root_left_right(matrix_tree^.right, indexer*2+1)
    end
end;

procedure Write_left_root_right(matrix_tree: node_ptr_t; indexer: integer);
begin
    if (matrix_tree^.left <> Nil) then
    begin
        Write_left_root_right(matrix_tree^.left, indexer*2);
    end;

    writeln(write_node(matrix_tree, indexer));

    if (matrix_tree^.right <> Nil) then
    begin
        Write_left_root_right(matrix_tree^.right, indexer*2+1)
    end
end;

procedure Write_right_root_left(matrix_tree: node_ptr_t; indexer: integer);
begin
    if (matrix_tree^.right <> Nil) then
    begin
        Write_right_root_left(matrix_tree^.right, indexer*2+1);
    end;

    writeln(write_node(matrix_tree, indexer));

    if (matrix_tree^.left <> Nil) then
    begin
        Write_right_root_left(matrix_tree^.left, indexer*2);
    end;
end;

procedure Write_levels(matrix_tree: node_ptr_t; id, cluster_point: integer;
                       var str_container: arr_of_string_t);
begin
    str_container[cluster_point] := str_container[cluster_point] + ' ' +
                                Write_node(matrix_tree, id);

    if (matrix_tree^.left <> nil) then
    begin
        Write_levels(matrix_tree^.left, id*2, cluster_point+1, str_container);
    end;
    if (matrix_tree^.right <> nil) then
    begin
        Write_levels(matrix_tree^.right, id*2+1, cluster_point+1, str_container);
    end
end;

procedure Write_height(matrix_tree: node_ptr_t);
begin 
    writeln(Height(matrix_tree));
end;

begin

    if ParamCount <> 2 then
    begin
        writeln('ERROR: BAD PARAMETRES');
        Halt
    end;

    name_of_file := ParamStr(1);
    mode := ParamStr(2);

    matrix_tree := From_dot_to_tree(name_of_file + '.dot');

    if (mode = 'root-left-right') then
    begin
        Write_root_left_right(matrix_tree, 1)
    end else if (mode = 'left-root-right') then
    begin
        Write_left_root_right(matrix_tree, 1)
    end else if (mode = 'right-root-left') then
    begin
        Write_right_root_left(matrix_tree, 1)
    end else if (mode = 'levels') then
    begin
        SetLength(str_container, Height(matrix_tree) + 1);
        for counter:=0 to Height(matrix_tree) do
        begin
            str_container[counter] := '';
        end;
        Write_levels(matrix_tree, 1, 0, str_container);
        for counter:=0 to Height(matrix_tree) do
        begin
            writeln(str_container[counter]);
        end
    end else if (mode = 'height') then
    begin
        Write_height(matrix_tree)
    end else
    begin
        writeln('ERROR: WRONG MODE');
    end;

    Delete_tree_from_memory(matrix_tree)

end.