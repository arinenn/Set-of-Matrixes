program matrix_generator;
{$H+}
uses
    sysutils;
const Null = 0;
type
    int_t = -1000..1000;
    arr_of_int_t = array of integer;
var
    container: arr_of_int_t;
    rows_array: array of arr_of_int_t;

    output_file: text;
    num_rows, num_columns, num_of_elements,
    control, needed_index, signs, de_signs, counter_i, counter_j: integer;
    matrix_density, needed_number: real;
    name_of_file, mode: string;
    print: boolean;

{Случайное число по модулю < 1}
function Random_low_number(): real;
begin
    Random_low_number := 2*random-1;
end;

{Случайное число от -1000 до 1000 кроме нуля}
function Random_integer_number(): int_t;
var result_number: int_t;
begin
    repeat
        result_number := random(2000) - 999
    until (result_number <> 0) and (result_number <> 1000);
    Random_integer_number := result_number
end;

{Случайное вещественное число от -1000 до 1000 кроме нуля}
function Random_high_number(): real;
begin
    Random_high_number := 2*abs(Random_integer_number) + abs(Random_low_number) - 1000;
end;


procedure Quick_sort(var int_mas: arr_of_int_t; left, right: integer);
var
    new_left, new_right : integer; //границы массива
    temp, pivot : integer;
begin
    new_left := left; new_right := right;
{опорный элемент массива}
    pivot := int_mas[(left + right) div 2];
    repeat
    while (int_mas[new_left] < pivot) do
        new_left := new_left + 1;
    while (int_mas[new_right] > pivot) do
        new_right := new_right - 1;
    if new_left <= new_right then
    begin
{обмен значений}
        temp := int_mas[new_left];
        int_mas[new_left] := int_mas[new_right];
        int_mas[new_right] := temp;
        new_left := new_left + 1;
        new_right := new_right - 1;
    end;
    until new_left > new_right;
{сортировка - для "меньших" элементов}
    if left < new_right then
    Quick_sort(int_mas, left, new_right);
{сортировка - для "больших" элементов}
    if new_left < right then
    Quick_sort(int_mas, new_left, right);
end;

{Возвращает упорядоченный набор индексов}
function Generate_indexes(): arr_of_int_t;
var
    logged_array: arr_of_int_t;
    index_j, random_num: integer;
    logged_char, logged_string: string;
begin
{Дано: num_rows, num_columns, num_of_elements}
    SetLength(logged_array, num_of_elements);
    logged_string := '#';
    for index_j:=0 to num_of_elements-1 do
    begin
        repeat
            random_num := random(num_columns) + 1; {случайный индекс}
            str(random_num, logged_char); {проверка, если уже был}
            logged_char := logged_char + '#';
        until pos(logged_char, logged_string) = 0;
        logged_string := logged_string + logged_char; {обновление буфера}
        logged_array[index_j] := random_num; {обновление контейнера}
    end;
    Quick_sort(logged_array, 0, num_of_elements-1);

    Generate_indexes := logged_array;
end;

procedure Generate_matrix(var rows_array: array of arr_of_int_t);
var
    index_i, index_j: integer;
begin
    if matrix_density = 1 then
        write(output_file, 'dense_matrix', ' ', num_rows, ' ', num_columns)
    else
        write(output_file, 'sparse_matrix', ' ', num_rows, ' ', num_columns);
    for index_i := 0 to num_rows-1 do
    begin
        container := Generate_indexes();
        for index_j := 0 to num_of_elements-1 do
        begin
            rows_array[index_i][index_j] := container[index_j]
        end;
    end;
end;

procedure Print_matrix();
var
    temp_row, temp_column,
    index_i, index_j: integer;
    value: real;
begin
    reset(output_file);
    readln(output_file);
    case mode of
        'one':
            begin
                signs := 0;
                de_signs := 2
            end;
        'all_one':
            begin
                signs := 0;
                de_signs := 2
            end;
        'random_low':
            begin
                signs := 8;
                de_signs := 12
            end;
        'random_high':
            begin
                signs := 8;
                de_signs := 14
            end;
        'random_integers':
            begin
                signs := 0;
                de_signs := 5
            end
    end;
    if matrix_density = 1 then
    begin
        for temp_row := 1 to num_rows do
        begin
            for temp_column := 1 to num_columns do
            begin
                read(output_file, value);
                if (value = 0) then
                    write(Null:de_signs)
                else
                    write(value:de_signs:signs);
                if (temp_column = num_columns) then
                begin
                    readln(output_file);
                    writeln()
                end
            end
        end
    end
    else
    begin
        if (not eof(output_file)) then readln(output_file, index_i, index_j, value);
        for temp_row := 1 to num_rows do
        begin
            for temp_column := 1 to num_columns do
            begin
                if (temp_column = index_j) and (temp_row = index_i) then
                begin
                    write(value:de_signs:signs);
                    if (not eof(output_file)) then readln(output_file, index_i, index_j, value);
                end
                else
                    write(Null:de_signs)
            end;
            writeln();
        end;
    end;
    close(output_file)
end;

begin

    randomize;
    print := False;
    control := 0;
    mode := '';

    if ParamCount > 4 then
    begin
        name_of_file := ParamStr(1);
        Val(ParamStr(2), num_rows, control);
            if (control = 1) or (num_rows < 1) then begin writeln('ERROR: WRONG ROWS'); halt end;
        Val(ParamStr(3), num_columns, control);
            if (control = 1) or (num_columns < 1) then begin writeln('ERROR: WRONG COLUMNS'); halt end;
        mode := ParamStr(4);
            if  ((mode <> 'all_one') and
                (mode <> 'one') and
                (mode <> 'random_low') and
                (mode <> 'random_high') and
                (mode <> 'random_integers')) then
            begin
                writeln('ERROR: WRONG MODE');
                Halt
            end;
        Val(ParamStr(5), matrix_density, control);
            if (control = 1) or (matrix_density < 0) or (matrix_density > 1) then
            begin
                writeln('ERROR: WRONG DENSITY');
                halt
            end;
        if (ParamCount > 5) then if (ParamStr(6) = 'print') then print := true else
        begin
            writeln('ERROR: PRINT?');
            Halt
        end;
    end
    else if (ParamCount > 6) then
    begin
        writeln('ERROR: SPARE PARAMETRES');
        Halt
    end
    else
    begin
        writeln('ERROR: NOT ENOUGH PARAMETRES');
        Halt
    end;

    name_of_file := name_of_file + '.mtr';
    Assign(output_file, './catalogue/' + name_of_file);
    rewrite(output_file);

    if matrix_density = 1 then
    begin
        if mode = 'all_one' then
        begin
            write(output_file, 'dense_matrix',' ',num_rows,' ',num_columns);
            for counter_i:=1 to num_rows do
            begin
                writeln(output_file);
                for counter_j:=1 to num_columns do
                begin
                    write(output_file, 1, ' ')
                end
            end;
            close(output_file);
            if print then Print_matrix;
            Halt
        end;
        if mode = 'one' then
        begin
            if num_rows > num_columns then num_rows := num_columns;
            write(output_file, 'dense_matrix', ' ', num_rows, ' ', num_rows);
            for counter_i:=1 to num_rows do
            begin
                writeln(output_file);
                for counter_j:=1 to num_rows do
                begin
                    if counter_i <> counter_j then
                    begin
                        write(output_file, 0, ' ')
                    end
                    else
                    begin
                        write(output_file, 1, ' ')
                    end
                end
            end;
            close(output_file);
            if print then Print_matrix;
            Halt
        end
    end;

    num_of_elements := trunc( (num_columns) / (1 + (1 / matrix_density)) );
    if num_of_elements = 0 then num_of_elements := 1;
    SetLength(container, num_of_elements);
    SetLength(rows_array, num_rows, num_of_elements);

    case mode of
    'one':
    begin
        if num_rows > num_columns then
            num_rows := num_columns
        else
            num_columns := num_rows;
        num_of_elements := round( (num_columns) / (1 + (1 / matrix_density)) );
        if num_of_elements = 0 then num_of_elements := 1;
        write(output_file, 'sparse_matrix', ' ', num_rows, ' ', num_rows);
        container := Generate_indexes();
        for counter_j := 0 to num_of_elements-1 do
        begin
            writeln(output_file);
            write(output_file, container[counter_j], ' ', container[counter_j], ' ', 1)
        end;
        close(output_file);
        if print then Print_matrix;
        Halt
    end;
    'all_one':
    begin
        write(output_file, 'sparse_matrix', ' ', num_rows, ' ', num_columns);
        for counter_i := 1 to num_rows do
        begin
            container := Generate_indexes();
            for counter_j := 0 to num_of_elements-1 do
            begin
                writeln(output_file);
                write(output_file, counter_i, ' ', container[counter_j], ' ', 1)
            end
        end;
        close(output_file);
        if print then Print_matrix;
        Halt
    end;
    'random_low':
        Generate_matrix(rows_array);
    'random_high':
        Generate_matrix(rows_array);
    'random_integers':
        Generate_matrix(rows_array);
    end;

{на этом месте "all_one" и "one" матрицы уже были бы сгенерированы}
{обработка оставшихся случаев}
{Дано: rows_array, mode, счётчики}
    if matrix_density = 1 then
    begin
        case mode of
            'random_low':
                begin
                    signs := 8;
                    de_signs := 12
                end;
            'random_high':
                begin
                    signs := 8;
                    de_signs := 14
                end;
            'random_integers':
                begin
                    signs := 0;
                    de_signs := 5
                end;
        end;
        for counter_i := 0 to num_rows-1 do
        begin
            writeln(output_file);
            needed_index := 0;
            for counter_j := 0 to num_columns-1 do
            begin
                if counter_j = rows_array[counter_i][needed_index] - 1 then
                begin
                    if needed_index < num_of_elements - 1 then needed_index := needed_index + 1;
                    case mode of
                        'random_low':
                                needed_number := Random_low_number();
                        'random_high':
                                needed_number := Random_high_number();
                        'random_integers':
                                needed_number := Random_integer_number();
                    end;
                    write(output_file, needed_number:de_signs:signs)
                end
                else
                begin
                    write(output_file, Null:de_signs)
                end
            end
        end;
        close(output_file);
        if print then Print_matrix;
        Halt
    end
    else
    begin
        case mode of
            'random_low':
                    signs := 8;
            'random_high':
                    signs := 8;
            'random_integers':
                    signs := 0
        end;
        writeln(output_file);
        for counter_i := 0 to num_rows-1 do
        begin
            for counter_j := 0 to num_of_elements-1 do
            begin
                case mode of
                    'random_low':
                            needed_number := Random_low_number();
                    'random_high':
                            needed_number := Random_high_number();
                    'random_integers':
                            needed_number := Random_integer_number();
                end;
                writeln(output_file, counter_i+1, ' ', rows_array[counter_i][counter_j], ' ', needed_number:0:signs);
            end
        end;
        close(output_file);
{вывод разреженной матрицы в консоль по надобности}
        if print then
        begin
            Print_matrix
        end
    end
end.