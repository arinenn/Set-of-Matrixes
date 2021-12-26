unit matrixes;
{$H+}
interface

    uses
        avl_tree, sysutils;

    type
        arr_of_string_t = array of string;

    procedure Drop_exception();
{разделение строки на слова - выцепляем нужную информацию}
    function Divide_by_words(your_row: string): arr_of_string_t;
    procedure Print_childs(matrix_tree: node_ptr_t; counter: Int64);
    procedure Print_relations(indexer: Int64);
{запись дерева поиска в .dot файл}
    procedure From_tree_to_dot(matrix_tree: node_ptr_t; name_of_file: string);
{построение дерева поиска по данных .mtr файла}
    function From_mtr_to_tree(name_of_file: string): matrix_t;
{вывод дерева в .mtr как разреженную матрицу}
    procedure Write_node_to_mtr(matrix_tree: node_ptr_t);
    procedure From_tree_to_mtr(your_matrix: matrix_t; name_of_file: string);
{удаление дерева из памяти}
    procedure Delete_tree_from_memory(matrix_tree: node_ptr_t);

implementation

    var
        number_of_elem: Int64;
        relations: string;
        graph_file, matrix_file: text;

    procedure Drop_exception();
    begin
        writeln('ERROR: INCORRECT FILE');
        Halt
    end;

    function Divide_by_words(your_row: string): arr_of_string_t;
    var
        logged_char: char;
        logged_string: string;
        logged_array: arr_of_string_t;
        counter, length_of_array: integer;
        flaggie_comm, flaggie: boolean;
    begin
        flaggie := False;
        flaggie_comm := False;
        length_of_array := 0;
        logged_string := '';
        for counter:=1 to Length(your_row) do
        begin
            logged_char := your_row[counter];
            if (logged_char = '#') then flaggie_comm := True;
            if (not flaggie_comm) then
            begin
                if (not ((ord(logged_char) = 13) or (ord(logged_char) = 9)
                    or   (ord(logged_char) = 32) or (ord(logged_char) = 10)))
                then
                begin
                    flaggie := False;
                    logged_string := logged_string + logged_char;
                    if (counter = Length(your_row)) then
                    begin
                        length_of_array := length_of_array + 1;
                        SetLength(logged_array, length_of_array);
                        logged_array[length_of_array-1] := logged_string;
                    end
                end
                else
                begin
                    if (not flaggie) and (logged_string <> '') then
                    begin
                        length_of_array := length_of_array + 1;
                        SetLength(logged_array, length_of_array);
                        logged_array[length_of_array-1] := logged_string;
                        logged_string := '';
                        flaggie := True;
                    end
                end
            end
            else
            begin
                if logged_string <> '' then
                begin
                    length_of_array := length_of_array + 1;
                    SetLength(logged_array, length_of_array);
                    logged_array[length_of_array-1] := logged_string;
                end;
                Break
            end
        end;
        if (length_of_array = 0) then
        begin
            SetLength(logged_array, 1);
            logged_array[0] := '';
        end;
        Divide_by_words := logged_array
    end;

    procedure Print_childs(matrix_tree: node_ptr_t; counter: Int64);
    var temp_number: Int64;
    begin
        if matrix_tree^.left <> nil then
        begin
            temp_number := 2*counter;
            if temp_number > number_of_elem then
                number_of_elem := temp_number;
            writeln(graph_file, '    ',temp_number,
                ' [label="', matrix_tree^.left^.value.first.index_i,
                ' ', matrix_tree^.left^.value.first.index_j, '\n',
                matrix_tree^.left^.value.second:0:4, '"];');
            relations := relations + IntToStr(temp_number) + '#';
            Print_childs(matrix_tree^.left, temp_number)
        end;
        if matrix_tree^.right <> nil then
        begin
            temp_number := 2*counter + 1;
            if temp_number > number_of_elem then number_of_elem := temp_number;
            writeln(graph_file, '    ',temp_number,
                ' [label="', matrix_tree^.right^.value.first.index_i,
                ' ', matrix_tree^.right^.value.first.index_j, '\n',
                matrix_tree^.right^.value.second:0:4, '"];');
            relations := relations + IntToStr(temp_number) + '#';
            Print_childs(matrix_tree^.right, temp_number)
        end
    end;

    procedure Print_relations(indexer: Int64);
    var
        the_number_left, the_number_right: Int64;
    begin
        the_number_left := indexer*2;
        the_number_right := indexer*2 + 1;
        if (pos(IntToStr(the_number_left), relations) <> 0) and
           (pos(IntToStr(the_number_right), relations) <> 0) then
            writeln(graph_file, '    ',
                indexer, ' -> ', the_number_left, ' [label="L"]; ',
                indexer, ' -> ', the_number_right,' [label="R"];')
        else if pos(IntToStr(the_number_left), relations) <> 0 then
            writeln(graph_file, '    ',
                indexer, ' -> ', the_number_left, ' [label="L"];')
        else if pos(IntToStr(the_number_right), relations) <> 0 then
            writeln(graph_file, '    ',
                indexer, ' -> ', the_number_right, ' [label="R"];')
    end;

    procedure From_tree_to_dot(matrix_tree: node_ptr_t; name_of_file: string);
    var
        node_index: Int64; 
    begin
        assign(graph_file, './catalogue/' + name_of_file);
        rewrite(graph_file);
        relations := '#';

        writeln(graph_file, 'digraph');
        writeln(graph_file, '{');

        number_of_elem := 0;
        writeln(graph_file, '    ', 1,
            ' [label="', matrix_tree^.value.first.index_i,
                ' ', matrix_tree^.value.first.index_j, '\n',
                        matrix_tree^.value.second:0:4, '"];');

        Print_childs(matrix_tree, 1);

        writeln(graph_file);
        writeln(graph_file, '//edges');
        writeln(graph_file);
        
        node_index := 0;
        repeat
        begin
            node_index := node_index + 1;
            Print_relations(node_index);
        end;
        until node_index = number_of_elem;
        writeln(graph_file, '}');
        close(graph_file);

    end;

    function From_mtr_to_tree(name_of_file: string): matrix_t;
    var
        key_i, key_j, counter_i, counter_j,
        num_rows, num_columns, num_elements, control: integer;
        line_of_file, mode: string;
        row_of_file: arr_of_string_t;
        flaggie: boolean;

        value: real;
        pair_node: pair_t;
        matrix_tree: node_ptr_t;
    begin
        if FileExists('./catalogue/' + name_of_file) then
            assign(matrix_file, './catalogue/' + name_of_file)
        else
        begin
            writeln('ERROR: FILE NOT FOUND');
            Halt
        end;

    {поиск первой ключевой строки}
        reset(matrix_file);
        repeat
            begin
                readln(matrix_file, line_of_file);
                row_of_file := Divide_by_words(line_of_file);
            end;
        until row_of_file[0] <> '';

    {обработка ошибок}
        if (Length(row_of_file) <> 3) then Drop_exception()
        else
        begin
            mode := row_of_file[0];
            Val(row_of_file[1], num_rows, control);
                if (control <> 0) or (num_rows < 1) then Drop_exception();
            Val(row_of_file[2], num_columns, control);
                if (control <> 0) or (num_columns < 1) then Drop_exception();
        end;

    {создание дерева}
        matrix_tree := Nil;
        if (mode = 'dense_matrix') then
        begin
            for key_i := 1 to num_rows do
            begin
                num_elements := num_columns;
                key_j := 0;
                repeat
                begin
                    repeat
                        begin
                            if eof(matrix_file) then Drop_exception();
                            readln(matrix_file, line_of_file);
                            row_of_file := Divide_by_words(line_of_file)
                        end;
                    until row_of_file[0] <> '';

                    for counter_j := 1 to Length(row_of_file) do
                    begin
                        Val(row_of_file[counter_j-1], value, control);
                            if (control <> 0) then Drop_exception();
                        if value <> 0 then
                        begin
                            pair_node :=
                                form_pair(key_i, (key_j+counter_j), value);
                            matrix_tree := Insert(matrix_tree, pair_node)
                        end;
                    end;
                    key_j := counter_j;

                    num_elements := num_elements - Length(row_of_file);
                end
                until (num_elements < 1);
                if num_elements < 0 then Drop_exception();
            end;
        end
        else if (mode = 'sparse_matrix') then
        begin
            flaggie := False;
            for counter_i := 1 to num_rows do
            begin
                for counter_j := 1 to num_columns do
                begin
                    if not flaggie then
                        repeat
                            begin
                                if eof(matrix_file) then
                                begin
                                    flaggie := True;
                                    Break
                                end;
                                readln(matrix_file, line_of_file);
                                row_of_file := Divide_by_words(line_of_file);
                            end;
                        until (row_of_file[0] <> '')
                    else Break;

                    if Length(row_of_file) <> 3 then Drop_exception();

                    Val(row_of_file[0], key_i, control);
                        if (control <> 0) or (key_i > num_rows) then
                            Drop_exception();
                    Val(row_of_file[1], key_j, control);
                        if (control <> 0) or (key_j > num_columns) then
                            Drop_exception();
                    Val(row_of_file[2], value, control);
                        if (control <> 0) then Drop_exception();
                    
                    pair_node := form_pair(key_i, key_j, value);
                    matrix_tree := Insert(matrix_tree, pair_node)
                end
            end
        end;

        close(matrix_file);
        From_mtr_to_tree.root := matrix_tree;
        From_mtr_to_tree.num_rows := num_rows;
        From_mtr_to_tree.num_columns := num_columns
    end;

    procedure Write_node_to_mtr(matrix_tree: node_ptr_t);
    var temp_ptr: node_ptr_t;
    begin
        if matrix_tree^.left <> nil then
        begin
            temp_ptr := matrix_tree^.left;
            writeln(matrix_file, temp_ptr^.value.first.index_i, ' ',
                                 temp_ptr^.value.first.index_j, ' ',
                                 temp_ptr^.value.second:0:4);
            Write_node_to_mtr(matrix_tree^.left)
        end;
        if matrix_tree^.right <> nil then
        begin
            temp_ptr := matrix_tree^.right;
            writeln(matrix_file, temp_ptr^.value.first.index_i, ' ',
                                 temp_ptr^.value.first.index_j, ' ',
                                 temp_ptr^.value.second:0:4);
            Write_node_to_mtr(matrix_tree^.right)
        end
    end;

    procedure From_tree_to_mtr(your_matrix: matrix_t; name_of_file: string);
    begin
        assign(matrix_file, './catalogue/' + name_of_file);
        rewrite(matrix_file);
        writeln(matrix_file, 'sparse_matrix ',
            your_matrix.num_rows, ' ',
            your_matrix.num_columns);
        Write_node_to_mtr(your_matrix.root);
        close(matrix_file)
    end;

    procedure Delete_tree_from_memory(matrix_tree: node_ptr_t);
    begin
        if matrix_tree <> nil then
        begin
            Delete_tree_from_memory(matrix_tree^.left);
            Delete_tree_from_memory(matrix_tree^.right);
            dispose(matrix_tree);
            matrix_tree := nil
        end
    end;

end.