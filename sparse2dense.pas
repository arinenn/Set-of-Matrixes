program sparse2dense;
uses
    avl_tree, matrixes, sysutils;
const
    Null = 0;
var

    key_i, key_j, counter_i, counter_j,
    num_rows, num_columns, num_elements, control, max_length: integer;
    row_of_file: arr_of_string_t;
    flaggie: boolean;

    value: extended;
    keys_indexes: key_t;
    pair_node: pair_t;
    matrix_tree: node_ptr_t;
    result_of_find: find_res_t;

    input_name, output_name, line_of_file, mode: string;
    dense_matrix, sparse_matrix: text;
begin
    if ParamCount = 2 then
    begin

        input_name := ParamStr(1);
        if FileExists('./catalogue/' + input_name + '.mtr') then
            assign(sparse_matrix, './catalogue/' + input_name + '.mtr')
        else
        begin
            writeln('ERROR: FILE NOT FOUND');
            Halt
        end;

        reset(sparse_matrix);

        repeat
            begin
                readln(sparse_matrix, line_of_file);
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

        matrix_tree := Nil;
        if (mode = 'sparse_matrix') then
        begin
            num_elements := 0;
            max_length := 0;
            flaggie := False;
            for counter_i := 1 to num_rows do
            begin
                for counter_j := 1 to num_columns do
                begin
                    if not flaggie then
                        repeat
                            begin
                                if eof(sparse_matrix) then
                                begin
                                    flaggie := True;
                                    Break
                                end;
                                readln(sparse_matrix, line_of_file);
                                row_of_file := Divide_by_words(line_of_file);
                            end;
                        until (row_of_file[0] <> '')
                    else Break;

                    if Length(row_of_file) <> 3 then Drop_exception();

                    if Length(row_of_file[2]) > max_length then max_length := Length(row_of_file[2]);

                    Val(row_of_file[0], key_i, control);
                        if (control <> 0) or (key_i > num_rows) then Drop_exception();
                    Val(row_of_file[1], key_j, control);
                        if (control <> 0) or (key_j > num_columns) then Drop_exception();
                    Val(row_of_file[2], value, control);
                        if (control <> 0) then Drop_exception();

                    pair_node := form_pair(key_i, key_j, value);
                    matrix_tree := Insert(matrix_tree, pair_node);
                    num_elements := num_elements + 1
                end
            end
        end
        else Drop_exception();

        close(sparse_matrix);

        output_name := ParamStr(2);
        assign(dense_matrix, './catalogue/' + output_name + '.mtr');
        rewrite(dense_matrix);
        writeln(dense_matrix, 'dense_matrix ', num_rows, ' ', num_columns);

        for counter_i := 1 to num_rows do
        begin
            for counter_j := 1 to num_columns do
            begin
                keys_indexes := form_key(counter_i, counter_j);
                result_of_find := find(matrix_tree, keys_indexes);
                if result_of_find.has_value then
                begin
                    value := result_of_find.value;
                    if (value-int(value) < 0.00001) and (value-int(value) > -0.00001)
                    then
                        write(dense_matrix, value:(max_length+4):0)
                    else
                        write(dense_matrix, value:(max_length+4):4)
                end
                else
                    write(dense_matrix, Null:(max_length+4));
                if counter_j = num_columns then writeln(dense_matrix)
            end
        end;
        close(dense_matrix)
    end
    else
    begin
        writeln('ERROR: BAD PARAMETRES')
    end
end.
