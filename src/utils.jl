TRowData = OrderedDict{Symbol, Any}

function all_keys(dat::Vector{TRowData})
	"""all keys that occur in the list of NamedTuple"""
	rtn = Set{Symbol}()
	for row in dat
		for col in keys(row)
			push!(rtn, col)
		end
	end
	return rtn
end

function key_value(txt::AbstractString;	varnames_without_dots::Bool = true)
	"""get key-value as pair, if they exist"""
	kv = match(re_key_value, txt)
	if kv != nothing
		value = tryparse_to_number(kv.captures[2])
		key = kv.captures[1]
		if varnames_without_dots
			key = replace(key, "." => "_")
		end
        return Symbol(key) => value
	else
        return nothing
    end
end


function unique_key(d::AbstractDict, key::Symbol)
	cnt = 0
	new_key = key
	while haskey(d, new_key)
		cnt += 1
		new_key = Symbol(string(key) * string(cnt))
	end
	return new_key
end

function reconcile(dat::Vector{TRowData}; missing_value = missing)
	"""harmonizing list of dict, so that all dicts have the same keys"""
	columns = all_keys(dat)
	rtn = TRowData[]
	for row in dat
		new_row = copy(row)
		for col in columns
			if !haskey(new_row, col)
				new_row[col] = missing_value
			end
		end
		push!(rtn, new_row)
	end
	return rtn
end

function tryparse_to_number(txt::AbstractString)
	rtn = tryparse(Int, txt)
	if rtn == nothing
		rtn = tryparse(Float64, txt)
		if rtn == nothing
			rtn = strip(txt)
		end
	end
	return rtn
end;

