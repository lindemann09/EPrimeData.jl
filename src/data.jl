const re_frame_end = r"\*\*\* LogFrame End \*\*\*"
const re_frame_start = r"\*\*\* LogFrame Start \*\*\*"
const re_header_start = r"\*\*\* Header Start \*\*\*"
const re_header_end = r"\*\*\* Header End \*\*\*"
const re_key_value = r"\s*(.+):\s(.+)"
const re_level = r"Level:\s(\d+)"
const re_subject = r"Subject:\s(\d+)"
const re_experiment = r"Experiment:\s(\w+)"
const re_datetime = r"SessionStartDateTimeUtc:\s(.+)";


function data(eprime_file::EPrimeLogFile; level::Int,
	varnames_without_dots::Bool = true)
	level > 0 || throw(ArgumentError("level must be > 0"))
	lvl = 0 #current
	data = TRowData[]
	row = TRowData()
	for l in eprime_file.content
		if lvl == 0
			# search for new level level
			new_level = match(re_level, l)
			if new_level != nothing
				lvl = parse(Int, new_level.captures[1])
			end
		elseif match(re_frame_start, l) != nothing
			row = TRowData()
		elseif match(re_frame_end, l) != nothing
			if length(row) > 0
				push!(data, row)
				row = TRowData()
			end
			lvl = 0
		elseif lvl == level
			# data
			kv = key_value(l; varnames_without_dots)
			if kv != nothing
				key = unique_key(row, kv.first)
				row[key] = kv.second
			end
		end # level
	end # next line
	return reconcile(data)
end;

