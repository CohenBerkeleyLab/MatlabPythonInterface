function pdict = struct2pydict( S, force_array )
% STRUCT2PYDICT Converts a structure to a Python dictionary or list of dicts
%   PDICT = STRUCT2PYDICT( S ) converts the Matlab structure S to a Python
%   dictionary, PDICT if S is a scalar structure. If S is not scalar, PDICT
%   will be a Python list of dictionaries. Because Python lists cannot be
%   multidimensional, a warning will be issued if S has 2 or more
%   non-singleton dimensions.
%
%   PDICT = STRUCT2PYDICT( S, FORCE_ARRAY ) passes the value of force_array
%   down to any calls to matarray2numpyarray to require that any scalar
%   values be treated as 1D numpy arrays.



if ~isstruct(S)
    error('pyinterface:badinput','S must be a structure')
elseif ~isvector(S) && ~suppress_warn
    warning('pyinterface:multi_dim_struct','S will be reshaped to a vector in the output list; any higher dimensional shape will be lost')
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MAIN FUNCTION %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

if isscalar(S)
    pdict = convert_one_struct(S, force_array);
else
    pdict = py.list;
    for a=1:numel(S)
        pdict.append(convert_one_struct(S(a), force_array));
    end
end

end

function pdict = convert_one_struct( S, force_array )

fns = fieldnames(S);
datacell = cell(2*numel(fns),1);
for a=1:numel(fns)
    nameind = (a-1)*2+1;
    fieldind = a*2;
    
    datacell{nameind} = fns{a};
    field = matlab2python(S.(fns{a}), force_array);
    datacell{fieldind} = field;
end

pdict = py.dict(pyargs(datacell{:}));

end
