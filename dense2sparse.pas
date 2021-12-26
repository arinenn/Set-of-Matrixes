program dense2sparse;
{$H+}
uses
    matrixes, sysutils;
var
    input_name, output_name, line_of_file, mode: string;
    dense_matrix, sparse_matrix: text;

    key_i, key_j, counter_j,
    num_rows, num_columns, num_elements, control: integer;
    value, epsilon: extended;
    row_of_file: arr_of_string_t;
begin
    if ParamCount = 3 then
    begin

        input_name := ParamStr(1);
        if FileExists('./catalogue/' + input_name + '.mtr') then
            assign(dense_matrix, './catalogue/' + input_name + '.mtr')
        else
        begin
            writeln('ERROR: FILE NOT FOUND');
            Halt
        end;

        Val(ParamStr(3), epsilon, control);
            if (control <> 0) or (epsilon < 0) then
            begin
                writeln('ERROR: WRONG EPSILON');
                Halt
            end;

        reset(dense_matrix);

        repeat
            begin
                readln(dense_matrix, line_of_file);
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

        if (mode = 'dense_matrix') then
        begin
            output_name := ParamStr(2);
            assign(sparse_matrix, './catalogue/' + output_name + '.mtr');
            rewrite(sparse_matrix);
            writeln(sparse_matrix, 'sparse_matrix ', num_rows, ' ', num_columns);
        end
        else Drop_exception();

    {создание sparse_matrix}
        for key_i := 1 to num_rows do
        begin
            num_elements := num_columns;
            key_j := 0;
            repeat
            begin
                repeat
                    begin
                        if eof(dense_matrix) then Drop_exception();
                        readln(dense_matrix, line_of_file);
                        row_of_file := Divide_by_words(line_of_file)
                    end;
                until row_of_file[0] <> '';

                for counter_j := 1 to Length(row_of_file) do
                begin
                    Val(row_of_file[counter_j-1], value, control);
                        if (control <> 0) then Drop_exception();
                    if (value <> 0) and (not ((value < epsilon) and (value > -epsilon))) then
                    begin
                        writeln(sparse_matrix, key_i, ' ', (key_j+counter_j), ' ', value:0:4);
                    end;
                end;
                key_j := counter_j;

                num_elements := num_elements - Length(row_of_file);
            end
            until (num_elements < 1);
            if num_elements < 0 then Drop_exception();
        end;

        close(dense_matrix);
        close(sparse_matrix);
    end
    else
    begin
        writeln('ERROR: BAD PARAMETERS')
    end
end.