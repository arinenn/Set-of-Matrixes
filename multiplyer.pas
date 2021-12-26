program multiplyer;
uses
    avl_tree, matrixes, sysutils;
var
    epsilon: double;
    counter_param, num_param,
    num_rows, num_columns, control,
    last_num_columns: integer;
    input_name, output_name,
    line_of_file, mode: string;
    temp_file: text;
    row_of_file: arr_of_string_t;
    temp_matrix, next_matrix: matrix_t;

function Multiply_matrixes(left_m, right_m: matrix_t; epsilon: extended): matrix_t;
var num_iterations, index_i, index_j, counter: integer;
    find_left_res, find_right_res: find_res_t;
    number: extended;
    res_matrix: matrix_t;
begin
    res_matrix.root := Nil;
    res_matrix.num_rows := left_m.num_rows;
    res_matrix.num_columns := right_m.num_columns;
    num_iterations := left_m.num_columns;
    for index_i := 1 to res_matrix.num_rows do
    begin
        for index_j := 1 to res_matrix.num_columns do
        begin
            number := 0;
            for counter := 1 to num_iterations do
            begin
                find_left_res := Find(left_m.root, Form_key(index_i,counter));
                if find_left_res.has_value then
                begin
                    find_right_res := Find(right_m.root, Form_key(counter, index_j));
                    if find_right_res.has_value then
                        number := number + find_left_res.value + find_right_res.value;
                end;
            end;
            if (number > epsilon) or (number < -epsilon) then
            begin
                res_matrix.root :=
                    insert(res_matrix.root,
                        form_pair(index_i, index_j, number))
            end
        end
    end;
    multiply_matrixes := res_matrix
end;

begin
    num_param := ParamCount();
    if num_param > 3 then
    begin
        output_name := ParamStr(1);
        Val(ParamStr(2), epsilon, control);
            if (control <> 0) then
            begin
                writeln('ERROR: WRONG EPSILON');
                Halt
            end;
    {проверка размерностей}
        for counter_param := 3 to num_param do
        begin
            input_name := ParamStr(counter_param);
            if FileExists('./catalogue/' + input_name + '.mtr') then
            begin
                assign(temp_file, './catalogue/' + input_name + '.mtr');
            {поиск первой ключевой строки}
                reset(temp_file);
                repeat
                    begin
                        readln(temp_file, line_of_file);
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
            {сравнение размерностей}
                if counter_param = 3 then
                begin
                    last_num_columns := num_columns
                end
                else
                begin
                    if (last_num_columns = num_rows) then
                    begin
                        last_num_columns := num_columns
                    end
                    else
                    begin
                        writeln('ERROR: WRONG DIMENSIONS');
                        Halt
                    end
                end;

                close(temp_file)
            end
            else
            begin
                writeln('ERROR: FILE NOT FOUND');
                Halt
            end
        end;

        temp_matrix := From_mtr_to_tree(ParamStr(3) + '.mtr');
        From_tree_to_dot(temp_matrix.root, ParamStr(3) + '.dot');

        for counter_param := 4 to num_param do
        begin
            next_matrix := From_mtr_to_tree(ParamStr(counter_param) + '.mtr');
            From_tree_to_dot(next_matrix.root, ParamStr(counter_param) + '.dot');

            temp_matrix := Multiply_matrixes(temp_matrix, next_matrix, epsilon);
        {очистка проработанных деревьев ради оптимизации}
            Delete_tree_from_memory(next_matrix.root)
        end;

        From_tree_to_dot(temp_matrix.root, ParamStr(1) + '.dot');
        From_tree_to_mtr(temp_matrix, ParamStr(1) + '.mtr');

        {удаление ответа из памяти}
        Delete_tree_from_memory(temp_matrix.root)

    end
    else
    begin
        writeln('ERROR: BAD PARAMETRES');
        Halt
    end;
end.