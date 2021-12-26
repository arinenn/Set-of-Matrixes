unit avl_tree;
interface 
    type 
    key_t = record
        index_i: integer;
        index_j: integer;
    end;

    pair_t = record
        first: key_t;
        second: extended;
    end;

    find_res_t = record
        has_value: boolean;
        value: extended;
    end;

    node_ptr_t = ^node_t;
    node_t = record
            height: integer;
            value: pair_t;
            left: node_ptr_t;
            right: node_ptr_t;
        end;

    matrix_t = record
            num_rows, num_columns: integer;
            root: node_ptr_t;
        end;

    function Form_key(index_i, index_j: integer): key_t;
    function Form_pair(index_i, index_j: integer; r: real):pair_t;
    function Is_bigger(k1, k2: key_t): boolean;
    function Is_smaller(k1, k2: key_t): boolean;
    function Is_equal(k1, k2: key_t): boolean;
    function Height(p: node_ptr_t): integer;
    function Balance_factor(p: node_ptr_t): integer;
    procedure Fix_height(p: node_ptr_t);
    function Small_rotate_right(p: node_ptr_t): node_ptr_t;
    function Small_rotate_left(q: node_ptr_t): node_ptr_t;
    function Balance(p: node_ptr_t): node_ptr_t;
    function Insert(p: node_ptr_t; val: pair_t): node_ptr_t;
    function Find(root: node_ptr_t; k: key_t): find_res_t;
    function Search(root: node_ptr_t; k: key_t): extended;

implementation

    function Form_key(index_i, index_j: integer): key_t;
    var your_key: key_t; 
    begin
        your_key.index_i := index_i;
        your_key.index_j := index_j;
        Form_key := your_key;
    end;    

    function Form_pair(index_i, index_j: integer; r: real):pair_t;
    var log_pair: pair_t;
    begin
        log_pair.first.index_i := index_i;
        log_pair.first.index_j := index_j;
        log_pair.second := r;
        Form_pair := log_pair;
    end;

    function Is_bigger(k1, k2: key_t): boolean;
    begin
        if (k1.index_i > k2.index_i) then begin
            Is_bigger := true;
        end else if (k1.index_i < k2.index_i) then begin
            Is_bigger := false;
        end else begin
            if (k1.index_j > k2.index_j) then begin
                Is_bigger := true;
            end else begin
                Is_bigger := false;
            end;
        end;
    end;

    function Is_smaller(k1, k2: key_t): boolean;
    begin  
        if (k2.index_i > k1.index_i) then begin
            Is_smaller := true;
        end else if (k2.index_i < k1.index_i) then begin
            Is_smaller := false;
        end else begin
            if (k2.index_j > k1.index_j) then begin
                Is_smaller := true;
            end else begin
                Is_smaller := false;
            end;
        end;       
    end;

    function Is_equal(k1, k2: key_t): boolean;
    begin
        Is_equal := (not Is_bigger(k1, k2)) and (not Is_smaller(k1, k2));
    end;

    function Height(p: node_ptr_t): integer;
    begin 
        if (p = Nil) then begin
            Height := 0;
            exit;
        end; 
        Height := p^.height; 
        exit;
    end;

    function Balance_factor(p: node_ptr_t): integer;
    begin
        Balance_factor := Height(p^.right) - Height(p^.left);
    end;

    procedure Fix_height(p: node_ptr_t);
    var left_height, right_height, num: integer;
    begin 
        left_height := Height(p^.left);
        right_height := Height(p^.right);
        if (left_height > right_height) then begin
            num := left_height;
        end else begin
            num := right_height;
        end;
        p^.height := num + 1;
    end;

    function Small_rotate_right(p: node_ptr_t): node_ptr_t;
    var q: node_ptr_t;
    begin
        q := p^.left;
        p^.left := q^.right;
        q^.right := p;
        Fix_height(p);
        Fix_height(q);

        Small_rotate_right := q;
    end;

    function Small_rotate_left(q: node_ptr_t): node_ptr_t; 
    var p: node_ptr_t;
    begin
        p := q^.right;
        q^.right := p^.left;
        p^.left := q;
        Fix_height(q);
        Fix_height(p);

        Small_rotate_left := p;
    end;

    function Balance(p: node_ptr_t): node_ptr_t;
    var factor: integer;
    begin
        Fix_height(p);
        factor := Balance_factor(p);
        if (factor = 2) then begin
            if (Balance_factor(p^.right) < 0) then begin
                p^.right := Small_rotate_right(p^.right);
            end;

            Balance := Small_rotate_left(p);
            exit;
        end;

        if (factor = -2) then begin
            if (Balance_factor(p^.left) > 0) then begin
                p^.left := Small_rotate_left(p^.left);
            end;

            Balance := Small_rotate_right(p);
            exit;
        end;

        Balance := p;
        exit;
    end;

        function Insert(p: node_ptr_t; val: pair_t): node_ptr_t;
        var n: node_ptr_t;
        begin
            if (p = Nil) then begin
                new(n);
                n^.left := Nil;
                n^.right := Nil;
                n^.height := 1;
                n^.value := val;
                Insert := n;
                exit;
            end;

            if (Is_smaller(val.first, p^.value.first)) then begin
                p^.left := Insert(p^.left, val);
            end else if (Is_bigger(val.first, p^.value.first)) then begin
                p^.right := Insert(p^.right, val);
            end else begin
                p^.value.second := val.second;
            end;

            Insert := Balance(p);
            exit;
        end;

    function Find(root: node_ptr_t; k: key_t): find_res_t;
    var flag: boolean;
    begin
        flag := false;

        while(root <> Nil) do
        begin
            if (Is_smaller(k, root^.value.first)) then
            begin
                root := root^.left;
            end else if (Is_bigger(k, root^.value.first)) then
            begin
                root := root^.right;
            end else
            begin
                flag := True;
                Find.has_value := flag;
                Find.value := root^.value.second;
                break
            end
        end;

        Find.has_value := flag;
    end;

    function Search(root: node_ptr_t; k: key_t): extended;
    var ans: real;
    begin
        ans := 0;

        while(root <> Nil) do begin
            if (Is_smaller(k, root^.value.first)) then begin
                root := root^.left;
            end else if (Is_bigger(k, root^.value.first)) then begin
                root := root^.right;
            end else begin
                ans := root^.value.second;
                break;
            end;
        end;

        Search := ans;
    end;

end.