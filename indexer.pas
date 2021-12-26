program indexer;
uses
    avl_tree, matrixes;
var
    name_of_file: string;
    matrix: node_ptr_t;
begin
    if ParamCount = 1 then
    begin
        name_of_file := ParamStr(1);
        matrix := From_mtr_to_tree(name_of_file + '.mtr').root;
        From_tree_to_dot(matrix, name_of_file + '.dot');
        Delete_tree_from_memory(matrix)
    end
    else writeln('ERROR: WRONG PARAMETRES')
end.